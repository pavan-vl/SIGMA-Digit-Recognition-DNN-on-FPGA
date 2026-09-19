#include "xaxidma.h"
#include "xdevcfg.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "sleep.h"
#include <stdint.h>

/******************************************************************
 * Hardware Constants
 ******************************************************************/

#define DMA_BASEADDR     XPAR_XAXIDMA_0_BASEADDR   // static region, 0x40400000 
#define DEVCFG_BASEADDR  XPAR_DEVCFG_BASEADDR      // 0xF8007000 

// PBlock Base Address for DFX
#define DNN_BASEADDR        0x40000000U

// DNN Control register offsets
#define DNN_SOFT_RESET      0x00   // slv_reg0 
#define DNN_REG_DIGIT       0x04   // slv_reg1 
#define DNN_REG_DONE        0x08   // slv_reg2 

#define DNN_RUN             0x00000001u
#define DNN_HOLD_RESET      0x00000000u


#define NUM_PIXELS       784
#define PIXEL_BYTES      2
#define FRAME_BYTES      (NUM_PIXELS * PIXEL_BYTES)

static uint16_t TxBufferMem[NUM_PIXELS] __attribute__((aligned(64)));
static uint16_t *TxBuffer = TxBufferMem;

#define DMA_TIMEOUT_US   1000000U
#define PCAP_TIMEOUT_US  5000000U   // Reconfiguration takes longer than a DMA beat

// DNN specific AXI Lite Register access functions 

#define DNN_WriteReg(RegOffset, Data) \
  	Xil_Out32((DNN_BASEADDR) + (RegOffset), (u32)(Data))

#define DNN_ReadReg(RegOffset) \
    Xil_In32((DNN_BASEADDR) + (RegOffset))

/***********************************************************
 * Global Variables
 **********************************************************/


static XAxiDma AxiDma;
static XDcfg   Dcfg;

/**
 *
 * @name DNN_Reset
 *
 * Perform soft reset for the DNN using AXI Lite interface
 *
 * @return  None.
 *
 * @note Enables soft reset and then disables it after 10us  delay.
 *
 *
 */

void DNN_Reset(void)
{
    // Step 1: Provide signal for soft reset

    DNN_WriteReg(DNN_SOFT_RESET, DNN_HOLD_RESET);

        // Step 1.1: Hold soft reset state for 10us.

        usleep(10);

    // Step 2: Disbale soft reset

    DNN_WriteReg(DNN_SOFT_RESET, DNN_RUN);

}


/**
 *
 * @name Dma_Init
 *
 * Initialize AXI DMA
 *
 * @return  XST_SUCCESS if the operation was successful else, XST_FAILURE.
 *
 * @note Enables soft reset and then disables it after 10us  delay.
 * 
 *
 */

int Dma_Init(void)
{
    XAxiDma_Config *CfgPtr;
    int Status;

    // Step 1: Store current AXI DMA configuration information using lookup

#ifdef SDT
    CfgPtr = XAxiDma_LookupConfig(DMA_BASEADDR);
#else
    CfgPtr = XAxiDma_LookupConfigBaseAddr(DMA_BASEADDR);
#endif

        // Step 1.1: Verify if configuration lookup was successful
        
        if (!CfgPtr) {
            xil_printf("No DMA config found at 0x%08X\r\n", DMA_BASEADDR);
            return XST_FAILURE;
        }

    // Step 2: Initialize the DMA with previously fetched configuration

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);

        // Step 2.1: Verify if intialization was successful
    
        if (Status != XST_SUCCESS) {
            xil_printf("DMA init failed: %d\r\n", Status);
            return XST_FAILURE;
        }

    // Step 3: Disable Interrupt from DMA

    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    return XST_SUCCESS;
}


/**
 *
 * @name Dcfg_Init
 *
 * Initialize Device configuration (DFX) for partial bitstream / .bin file loading
 *
 * @return  XST_SUCCESS if the operation was successful else, XST_FAILURE.
 *
 * @note This is the replacement for XFpga driver functions (only from Zynq Ultrascale+ onwards) for Arty-Z7 20.
 * 
 *
 */


int Dcfg_Init(void)
{
    XDcfg_Config *CfgPtr;
    int Status;

    // Step 1: Store current DeviceConfig configuration information using lookup

#ifdef SDT
    CfgPtr = XDcfg_LookupConfig(DEVCFG_BASEADDR);
#else
    CfgPtr = XDcfg_LookupConfig(XPAR_XDCFG_0_DEVICE_ID);
#endif

        // Step 1.1: Verify if configuration lookup was successful

        if (!CfgPtr) {
            xil_printf("No DevCfg config found\r\n");
            return XST_FAILURE;
        }

    // Step 2: Initialize the DMA with previously fetched configuration

    Status = XDcfg_CfgInitialize(&Dcfg, CfgPtr, CfgPtr->BaseAddr);

        // Step 2.1: Verify if intialization was successful
        
        if (Status != XST_SUCCESS) {
            xil_printf("DevCfg init failed: %d\r\n", Status);
            return XST_FAILURE;
        }

    // Step 3: Unlock the DeviceConfig registers so PCAP writes are actually accepted

    XDcfg_Unlock(&Dcfg);

    // Step 4: Route reconfiguration through PCAP instead of ICAP

    XDcfg_SelectPcapInterface(&Dcfg);

    // Step 5: Power up/enable the PCAP interface for the transfer

    XDcfg_EnablePCAP(&Dcfg);

    return XST_SUCCESS;
}


/**
 *
 * @name Pcap_LoadBitstream
 *
 * Transfer partial bitsream (.bin) using PCAP interface to DeviceConfig (DevCfg)
 *
 * @param   data pointer to .bin file stored in DDR. 
 *
 * @param   lenBytes stores the length of .bin file in bytes
 *
 * @return  XST_SUCCESS if the operation was successful else, XST_FAILURE.
 *
 * @note None.
 * 
 *
 */

 int Pcap_LoadBitstream(uint8_t *data, uint32_t lenBytes)
{
    u32 wordLen;
    u32 status;
    int timeout;

    // Step 1: Check if it is a valid .bin file for partial reconfiguration

    if (lenBytes % 4u != 0u) {
        xil_printf(".bin length %lu is not word-aligned -- wrong array, "
                   "or source .bin not generated with -bin_file\r\n",
                   (unsigned long)lenBytes);
        return XST_FAILURE;
    }

    // Step 2: store word length from byte length
    wordLen = lenBytes / 4u;

    // Step 3: Flush .bin file specific cache lines before reconfiguration

    Xil_DCacheFlushRange((UINTPTR)data, lenBytes);

    // Step 4: Clear all DeviceConfig interrupts

    XDcfg_IntrClear(&Dcfg, XDCFG_IXR_ALL_MASK);

    // Step 5: Transfer the .bin to DevCfg to initiate partial reconfiguration

    status = XDcfg_Transfer(&Dcfg, (void *)data, wordLen, (void *)XDCFG_DMA_INVALID_ADDRESS, 0, XDCFG_NON_SECURE_PCAP_WRITE);

        // Step 5.1: Verify if transfer was successful

        if (status != XST_SUCCESS) {
            xil_printf("XDcfg_Transfer failed: %lu\r\n", (unsigned long)status);
            return XST_FAILURE;
        }

    // Step 6: Store PCAP interface timeout locally

    timeout = PCAP_TIMEOUT_US;

    // Step 7: Keep checking for the done bits until they appear or we run out of tries
    while (timeout > 0) {
        u32 isr = XDcfg_IntrGetStatus(&Dcfg);
        if ((isr & XDCFG_IXR_D_P_DONE_MASK) == XDCFG_IXR_D_P_DONE_MASK) {
            break;
        }
        timeout--;
        usleep(1U);
    }

    // Step 8: Clear the done bits post .bin transfer so it is not indicated in future reconfigurations  

    XDcfg_IntrClear(&Dcfg, XDCFG_IXR_D_P_DONE_MASK);

    // Step 9: Indicate if there has been a PCAP interface timeout.

    if (timeout == 0) {
        xil_printf("PCAP reconfiguration timed out\r\n");
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}


/**
 *
 * @name Dfx_LoadVariant
 *
 * Load partial bitsream (.bin) using PCAP interface and DeviceConfig (DevCfg)
 *
 * @param   data pointer to .bin file stored in DDR. 
 *
 * @param   size stores the length of .bin file in bytes
 *
 * @return  XST_SUCCESS if the operation was successful else, XST_FAILURE.
 *
 * @note None.
 * 
 *
 */


int Dfx_LoadVariant(uint8_t *data, uint32_t size)
{
    xil_printf("\r\n--- Loading %s (%lu bytes, embedded) ---\r\n",
                (unsigned long)size);

    // Step 1: Load sigmoid varient partial bitsream / .bin file

    if (

        // Step 1.1: Verify if partial bitstream load was successful
        
        Pcap_LoadBitstream(data, size) != XST_SUCCESS

       ) 
    {
        return XST_FAILURE;
    }

    // Step 2: Let the RP settle

    usleep(1000U);

    // Step 3: Bring the DNN out of reset 

    DNN_Reset();

    xil_printf("Reconfiguration complete\r\n");
    return XST_SUCCESS;
}

/**
 *
 * @name Use_DigitRecognitionDNN
 *
 * Use the digit recognition DNN with the loaded sigmoid varient
 *
 * @param   pixels pointer to pixel bytes stored in DDR. 
 *
 * @param   digit_out pointer to the output of DNN i.e, the predicted digit
 *
 * @return  XST_SUCCESS if the operation was successful else, XST_FAILURE.
 *
 * @note DNN is designed for 28x28 = 784 pixels as per MNIST database.
 * 
 *
 */


int Use_DigitRecognitionDNN(const uint16_t *pixels, u32 *digit_out)
{
    int Status;
    int TimeOut;
    u32 loop_i;

    // Step 1: Copy pixel data from TxBuffer into local pixels buffer

    for (loop_i = 0; loop_i < NUM_PIXELS; loop_i++) {
        TxBuffer[loop_i] = pixels[loop_i];
    }

    // Step 2: Flush cache lines corresponding to TxBuffer

    Xil_DCacheFlushRange((UINTPTR)TxBuffer, FRAME_BYTES);

    // Step 3: Perform an AXI DMA transfer to pass pixel data to the DNN via AXIMM - AXI DMA - AXIS path

    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)TxBuffer, FRAME_BYTES, XAXIDMA_DMA_TO_DEVICE);
    
        // Step 3.1 Verify if DMA transfer was ssuccesful

        if (Status != XST_SUCCESS) {
            xil_printf("MM2S transfer failed: %d\r\n", Status);
            return XST_FAILURE;
        }

    // Step 4: Store DMA timeout locally

    TimeOut = DMA_TIMEOUT_US;

    // Step 5: Check if DMA is busy with transfer until timeout

    while (TimeOut) {
        if (!XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE)) {
            break;
        }
        TimeOut--;
        usleep(1U);
    }

    // Step 6: Indicate if the DMA timed out

    if (TimeOut == 0) {
        xil_printf("MM2S timed out\r\n");
        return XST_FAILURE;
    }

    // Step 7: Pipeline drain settle
    usleep(10U);

    // Step 8: Store the output from digit recognition DNN into output parameter location

    *digit_out = DNN_ReadReg(DNN_REG_DIGIT) & 0xF;


    return XST_SUCCESS;
}


/**
 *
 * @name DNN_init
 *
 * Setup initializations for using DNN
 *
 * @param   data pointer to .bin file stored in DDR. 
 *
 * @param   size stores the length of .bin file in bytes
 *
 * @return  XST_SUCCESS if the operation was successful else, XST_FAILURE.
 *
 * @note    None.
 * 
 *
 */


int DNN_init(void)
{
    // Step 1: Invoke DevCfg intialization and verify if it was successful

    if (Dcfg_Init() != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // Step 2: invoke AXI DMA initialization and verify if it was successful

    if (Dma_Init() != XST_SUCCESS) {
        return XST_FAILURE;
    }
    
    return XST_SUCCESS;
}


/**
 *
 * @name LoadDNN
 *
 * Invokes function to transfer and reconfigure PL with partial bitsream / .bin using PCAP
 *
 * @param   data pointer to .bin file stored in DDR. 
 *
 * @param   size stores the length of .bin file in bytes
 *
 * @return  XST_SUCCESS if the operation was successful else, XST_FAILURE.
 *
 * @note    Arty-Z7 20 requires .bin files instead of .bit for partial recofniguration.
 * 
 *
 */


 int LoadDNN(uint8_t *data, uint32_t ByteSize)
 {
     
    // Step 1: Invoke PCAP loading and verify if it was successful

    if (Pcap_LoadBitstream(data, ByteSize) != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // Step 2: Invoke partial reconfiguration and verify if it was successful

    if (Dfx_LoadVariant(data, ByteSize) != XST_SUCCESS) {
        return XST_FAILURE;
    }


    return XST_SUCCESS;

 }