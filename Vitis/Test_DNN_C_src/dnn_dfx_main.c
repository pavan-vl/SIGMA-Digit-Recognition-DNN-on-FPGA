/*****************************************************************************
 * dnn_dfx_main.c
 *
 * Loads three DFX partial bitstreams from SD card one at a time via
 * devcfg/PCAP, and runs the same 12-frame test suite (test_frames.h)
 * against each:
 *
 *     sigf.bin -> Sig5
 *     sige.bin -> Sig8
 *     sigt.bin -> Sig10
 *
 * Per-frame data path, unchanged from dnn_main.c:
 *   DDR pixel buffer -> AXI DMA (MM2S) -> DNN S00_AXIS (16-bit stream)
 *   DNN result       -> AXI-Lite S00_AXI -> PS
 *
 * New in this version:
 *   SD card (FatFs) -> DDR bitstream buffer -> devcfg/PCAP -> reconfigures
 *   the RP slot at DNN_BASEADDR with whichever variant's logic.
 *
 * ---------------------------------------------------------------------
 * Assumptions this file makes about your design -- check these before
 * trusting the output:
 *
 *  1. axi_dma_0 and the PS7/DevCfg blocks sit in the STATIC region, so
 *     they stay valid and do not need re-init across a partial reconfig.
 *     Your block design confirmed this (axi_dma_0 under "sr"; DNN + its
 *     axi_smc under "rp") -- so Dma_Init() and Dcfg_Init() run once,
 *     outside the per-variant loop.
 *
 *  2. All three RP variants were packaged with an IDENTICAL port list at
 *     the partition boundary -- required for DFX, and it is what lets
 *     one fixed base address (DNN_BASEADDR) work for whichever variant
 *     is currently loaded.
 *
 *  3. Each .bin was generated with -bin_file from that variant's own
 *     implementation run, sized for the same pblock.
 *
 *  4. DNN_BASEADDR is hardcoded to 0x43C00000, taken from your earlier
 *     xparameters.h (XPAR_DNN_DIGIT_RECOG_SIG12_0_BASEADDR). This is
 *     deliberate: whichever variant's BSP you last generated from only
 *     defines ONE of the three variant-specific macros, not all three,
 *     so a symbolic name would silently be wrong for the other two.
 *
 *  5. The BSP has "xilffs" enabled with SD card support, so a FatFs
 *     diskio glue exists for drive "0:/". If f_mount() fails, that
 *     library is very likely missing -- check BSP settings, the same
 *     place xilfpga was missing earlier (xilfpga itself is NOT used
 *     here; Zynq-7000 reconfiguration goes through xdevcfg instead).
 *****************************************************************************/

#include "xaxidma.h"
#include "xdevcfg.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "sleep.h"
#include "ff.h"
#include <stdint.h>

#include "test_frames.h"   /* NUM_TEST_FRAMES, test_frames[] */

/*---------------------------------------------------------------------------
 * Hardware constants
 *-------------------------------------------------------------------------*/

#define DMA_BASEADDR     XPAR_XAXIDMA_0_BASEADDR   /* static region, 0x40400000 */
#define DEVCFG_BASEADDR  XPAR_XDCFG_0_BASEADDR      /* 0xF8007000 */

/* RP slot address -- see assumption #4 above. */
#define DNN_BASEADDR     0x43C00000u

#define DNN_REG_CTRL     0x00   /* slv_reg0 */
#define DNN_REG_DIGIT    0x04   /* slv_reg1 */
#define DNN_REG_DONE     0x08   /* slv_reg2 */

#define DNN_RUN          0x00000001u
#define DNN_HOLD_RESET   0x00000000u

#define NUM_PIXELS       784
#define PIXEL_BYTES      2
#define FRAME_BYTES      (NUM_PIXELS * PIXEL_BYTES)

#define TX_BUFFER_BASE   (XPAR_PS7_DDR_0_BASEADDRESS + 0x01000000u)

/* Bitstream staging buffer -- kept well clear of TX_BUFFER_BASE.
 * 4 MB ceiling is generous for a single-pblock partial bitstream on a
 * 7z020; raise BIT_BUFFER_MAX if your RP is large enough to exceed it. */
#define BIT_BUFFER_BASE  (XPAR_PS7_DDR_0_BASEADDRESS + 0x02000000u)
#define BIT_BUFFER_MAX   (4u * 1024u * 1024u)

#define DMA_TIMEOUT_US   1000000U
#define PCAP_TIMEOUT_US  5000000U   /* reconfig takes longer than a DMA beat */

/*---------------------------------------------------------------------------
 * Bitstream table
 *-------------------------------------------------------------------------*/

typedef struct {
    const char *filename;
    const char *label;
} bitstream_t;

static const bitstream_t bitstreams[] = {
    { "sigf.bin", "Sig5"  },
    { "sige.bin", "Sig8"  },
    { "sigt.bin", "Sig10" },
};
#define NUM_BITSTREAMS (sizeof(bitstreams) / sizeof(bitstreams[0]))

/*---------------------------------------------------------------------------
 * Globals
 *-------------------------------------------------------------------------*/

static XAxiDma AxiDma;
static XDcfg   Dcfg;
static FATFS   FatFs;

static uint8_t  *BitBuffer = (uint8_t  *)BIT_BUFFER_BASE;
static uint16_t *TxBuffer  = (uint16_t *)TX_BUFFER_BASE;

/*---------------------------------------------------------------------------
 * DNN register access
 *-------------------------------------------------------------------------*/

static inline void DNN_WriteReg(u32 offset, u32 value)
{
    Xil_Out32(DNN_BASEADDR + offset, value);
}

static inline u32 DNN_ReadReg(u32 offset)
{
    return Xil_In32(DNN_BASEADDR + offset);
}

/* slv_reg0 clears to 0 on AXI reset (and on every partial reconfig, since
 * the RP's registers come up at their post-configuration default), which
 * holds DNN_SOFT_RESETN low until this runs. */
static void DNN_Reset(void)
{
    DNN_WriteReg(DNN_REG_CTRL, DNN_HOLD_RESET);
    usleep(10);
    DNN_WriteReg(DNN_REG_CTRL, DNN_RUN);
    usleep(10);
}

/*---------------------------------------------------------------------------
 * AXI DMA init -- static region, called once
 *-------------------------------------------------------------------------*/

static int Dma_Init(void)
{
    XAxiDma_Config *CfgPtr;
    int Status;

#ifdef SDT
    CfgPtr = XAxiDma_LookupConfig(DMA_BASEADDR);
#else
    CfgPtr = XAxiDma_LookupConfigBaseAddr(DMA_BASEADDR);
#endif
    if (!CfgPtr) {
        xil_printf("No DMA config found at 0x%08X\r\n", DMA_BASEADDR);
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) {
        xil_printf("DMA init failed: %d\r\n", Status);
        return XST_FAILURE;
    }

    if (XAxiDma_HasSg(&AxiDma)) {
        xil_printf("DMA is in SG mode; expected simple mode\r\n");
        return XST_FAILURE;
    }

    /* MM2S-only build (INCLUDE_S2MM = 0) -- do not touch S2MM. */
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    return XST_SUCCESS;
}

/*---------------------------------------------------------------------------
 * DevCfg / PCAP init -- called once
 *-------------------------------------------------------------------------*/

static int Dcfg_Init(void)
{
    XDcfg_Config *CfgPtr;
    int Status;

#ifdef SDT
    CfgPtr = XDcfg_LookupConfig(DEVCFG_BASEADDR);
#else
    /* Classic (non-SDT) BSP fallback. Your BSP has been SDT-style
     * throughout this project, so this branch is included only for
     * portability and is not what actually compiles for you. */
    CfgPtr = XDcfg_LookupConfig(XPAR_XDCFG_0_DEVICE_ID);
#endif
    if (!CfgPtr) {
        xil_printf("No DevCfg config found\r\n");
        return XST_FAILURE;
    }

    Status = XDcfg_CfgInitialize(&Dcfg, CfgPtr, CfgPtr->BaseAddr);
    if (Status != XST_SUCCESS) {
        xil_printf("DevCfg init failed: %d\r\n", Status);
        return XST_FAILURE;
    }

    XDcfg_Unlock(&Dcfg);

    /* Route reconfiguration through PCAP (not ICAP). */
    XDcfg_SelectPcapInterface(&Dcfg);
    XDcfg_EnablePCAP(&Dcfg);

    return XST_SUCCESS;
}

/*---------------------------------------------------------------------------
 * SD card -> DDR
 *-------------------------------------------------------------------------*/

static int Sd_Mount(void)
{
    FRESULT rc = f_mount(&FatFs, "0:/", 1);
    if (rc != FR_OK) {
        xil_printf("f_mount failed: %d "
                   "(check xilffs + SD support are enabled in the BSP)\r\n",
                   (int)rc);
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}

/* Reads filename from the SD card root into BitBuffer.
 * Returns the byte count read, or 0 on failure. */
static u32 Sd_ReadFile(const char *filename)
{
    FIL fil;
    FRESULT rc;
    UINT bytesRead = 0;
    FSIZE_t fsize;

    rc = f_open(&fil, filename, FA_READ);
    if (rc != FR_OK) {
        xil_printf("f_open(%s) failed: %d\r\n", filename, (int)rc);
        return 0;
    }

    fsize = f_size(&fil);
    if (fsize == 0 || fsize > BIT_BUFFER_MAX) {
        xil_printf("%s: size %lu out of range (max %u)\r\n",
                   filename, (unsigned long)fsize, BIT_BUFFER_MAX);
        f_close(&fil);
        return 0;
    }

    rc = f_read(&fil, BitBuffer, (UINT)fsize, &bytesRead);
    f_close(&fil);

    if (rc != FR_OK || bytesRead != (UINT)fsize) {
        xil_printf("f_read(%s) failed: rc=%d got=%u want=%lu\r\n",
                   filename, (int)rc, bytesRead, (unsigned long)fsize);
        return 0;
    }

    return (u32)bytesRead;
}

/*---------------------------------------------------------------------------
 * PCAP partial reconfiguration
 *-------------------------------------------------------------------------*/

static int Pcap_LoadBitstream(const uint8_t *buf, u32 lenBytes)
{
    u32 wordLen;
    u32 status;
    int timeout;

    if (lenBytes % 4u != 0u) {
        xil_printf(".bin length %u is not word-aligned -- wrong file, "
                   "or not generated with -bin_file\r\n", lenBytes);
        return XST_FAILURE;
    }
    wordLen = lenBytes / 4u;

    /* PCAP's DMA reads DDR directly; the ARM cache must not be holding
     * dirty lines the DMA engine can't see. */
    Xil_DCacheFlushRange((UINTPTR)buf, lenBytes);

    XDcfg_IntrClear(&Dcfg, XDCFG_IXR_ALL_MASK);

    status = XDcfg_Transfer(&Dcfg,
                            (void *)buf, wordLen,
                            (void *)XDCFG_DMA_INVALID_ADDRESS, 0,
                            XDCFG_NON_SECURE_PCAP_WRITE);
    if (status != XST_SUCCESS) {
        xil_printf("XDcfg_Transfer failed: %lu\r\n", (unsigned long)status);
        return XST_FAILURE;
    }

    timeout = PCAP_TIMEOUT_US;
    while (timeout > 0) {
        u32 isr = XDcfg_IntrGetStatus(&Dcfg);
        if ((isr & XDCFG_IXR_D_P_DONE_MASK) == XDCFG_IXR_D_P_DONE_MASK) {
            break;
        }
        timeout--;
        usleep(1U);
    }

    XDcfg_IntrClear(&Dcfg, XDCFG_IXR_D_P_DONE_MASK);

    if (timeout == 0) {
        xil_printf("PCAP reconfiguration timed out\r\n");
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}

static int Dfx_LoadVariant(const char *filename, const char *label)
{
    u32 lenBytes;

    xil_printf("\r\n--- Loading %s (%s) ---\r\n", label, filename);

    lenBytes = Sd_ReadFile(filename);
    if (lenBytes == 0) {
        return XST_FAILURE;
    }
    xil_printf("%s: %u bytes read from SD\r\n", filename, lenBytes);

    if (Pcap_LoadBitstream(BitBuffer, lenBytes) != XST_SUCCESS) {
        return XST_FAILURE;
    }

    /* Let the RP settle, then bring the DNN out of reset -- every
     * register in the partition is at its post-configuration default
     * until this runs. */
    usleep(1000U);
    DNN_Reset();

    xil_printf("%s: reconfiguration complete\r\n", label);
    return XST_SUCCESS;
}

/*---------------------------------------------------------------------------
 * Inference (same as dnn_main.c)
 *-------------------------------------------------------------------------*/

static int DNN_Infer(const uint16_t *pixels, u32 *digit_out)
{
    int Status;
    int TimeOut;
    u32 i;

    for (i = 0; i < NUM_PIXELS; i++) {
        TxBuffer[i] = pixels[i];
    }

    Xil_DCacheFlushRange((UINTPTR)TxBuffer, FRAME_BYTES);

    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)TxBuffer,
                                    FRAME_BYTES, XAXIDMA_DMA_TO_DEVICE);
    if (Status != XST_SUCCESS) {
        xil_printf("MM2S transfer failed: %d\r\n", Status);
        return XST_FAILURE;
    }

    TimeOut = DMA_TIMEOUT_US;
    while (TimeOut) {
        if (!XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE)) {
            break;
        }
        TimeOut--;
        usleep(1U);
    }
    if (TimeOut == 0) {
        xil_printf("MM2S timed out\r\n");
        return XST_FAILURE;
    }

    /* Pipeline drain settle -- digit_Val is not meaningful until all
     * 4 layers + hardmax have finished, and hardmax_output_valid is a
     * single-cycle pulse with no capture register to poll instead. */
    usleep(100U);

    *digit_out = DNN_ReadReg(DNN_REG_DIGIT) & 0xF;

    return XST_SUCCESS;
}

/*---------------------------------------------------------------------------
 * Per-variant test run
 *-------------------------------------------------------------------------*/

static void Run_TestSuite(const char *variant_label)
{
    int i;
    int right = 0, wrong = 0;
    u32 seen_mask = 0;
    u32 digit;
    int Status;

    xil_printf("\r\nRunning %d frame(s) on %s\r\n\r\n",
               NUM_TEST_FRAMES, variant_label);

    for (i = 0; i < NUM_TEST_FRAMES; i++) {

        /* Reset between frames so layer FSMs/accumulators start clean. */
        DNN_Reset();

        Status = DNN_Infer(test_frames[i].pixels, &digit);
        if (Status != XST_SUCCESS) {
            xil_printf("[%s] %-22s INFERENCE FAILED\r\n",
                       variant_label, test_frames[i].name);
            wrong++;
            continue;
        }

        seen_mask |= (1u << (digit & 0xF));

        if ((int)digit == test_frames[i].expected) {
            right++;
            xil_printf("[%s] %-22s got %d  exp %d   ok\r\n",
                       variant_label, test_frames[i].name,
                       (int)digit, test_frames[i].expected);
        } else {
            wrong++;
            xil_printf("[%s] %-22s got %d  exp %d   WRONG\r\n",
                       variant_label, test_frames[i].name,
                       (int)digit, test_frames[i].expected);
        }
    }

    xil_printf("\r\n[%s] %d/%d correct\r\n",
               variant_label, right, NUM_TEST_FRAMES);

    if (NUM_TEST_FRAMES > 1) {
        int distinct = 0;
        for (i = 0; i < 16; i++) {
            if (seen_mask & (1u << i)) {
                distinct++;
            }
        }
        if (distinct == 1) {
            xil_printf("[%s] WARNING: every frame returned the same digit -- "
                       "output is not tracking input.\r\n", variant_label);
        } else {
            xil_printf("[%s] %d distinct digit(s) output\r\n",
                       variant_label, distinct);
        }
    }
}

/*---------------------------------------------------------------------------
 * main
 *-------------------------------------------------------------------------*/

int main(void)
{
    u32 v;

    xil_printf("\r\n=== DNN DFX multi-variant test ===\r\n");
    xil_printf("%d bitstream variant(s), %d frame(s) each\r\n",
               (int)NUM_BITSTREAMS, NUM_TEST_FRAMES);

    if (Sd_Mount() != XST_SUCCESS) {
        return XST_FAILURE;
    }

    if (Dcfg_Init() != XST_SUCCESS) {
        return XST_FAILURE;
    }

    /* Static region -- initialized once, reused across all variants. */
    if (Dma_Init() != XST_SUCCESS) {
        return XST_FAILURE;
    }

    for (v = 0; v < NUM_BITSTREAMS; v++) {
        if (Dfx_LoadVariant(bitstreams[v].filename, bitstreams[v].label)
            != XST_SUCCESS) {
            xil_printf("Skipping %s due to load failure\r\n",
                       bitstreams[v].label);
            continue;
        }
        Run_TestSuite(bitstreams[v].label);
    }

    xil_printf("\r\n=== all variants done ===\r\n");

    return XST_SUCCESS;
}
