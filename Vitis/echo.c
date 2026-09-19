/*
 * Copyright (C) 2009 - 2019 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */

#include <stdio.h>
#include <string.h>
#include "RGB_driver.h"

#include "lwip/err.h"
#include "lwip/tcp.h"
#if defined (__arm__) || defined (__aarch64__)
#include "xil_printf.h"
#endif

#include "xstatus.h"
#include "myDNN_File.h"   /* NUM_PIXELS, LoadDNN(), Use_DigitRecognitionDNN() */
#include "bitstreams.h"   /* sigf_bin/SIGF_BIN_SIZE, sige_bin/..., sigt_bin/... */

/* Reply header that marks a prediction result. The UI looks for these
 * three bytes and treats the byte right after them as the digit. */
#define RESULT_HDR_0  0xDE
#define RESULT_HDR_1  0xED
#define RESULT_HDR_2  0xAF

#define RX_BUF_SIZE 1569              /* 1 command byte + 1568 pixel bytes */
 u8_t          rx_buf[RX_BUF_SIZE];
 u16_t         rx_len = 0;      /* bytes accumulated so far */
 

int transfer_data() {
	return 0;
}

void print_app_header()
{
#if (LWIP_IPV6==0)
	xil_printf("\n\r\n\r-----lwIP TCP echo server ------\n\r");
#else
	xil_printf("\n\r\n\r-----lwIPv6 TCP echo server ------\n\r");
#endif
	xil_printf("TCP packets sent to port 6001 will be echoed back\n\r");
}

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                               struct pbuf *p, err_t err)
{
	/* do not read the packet if we are not in ESTABLISHED state */
	if (!p) {
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		return ERR_OK;
	}

	/* indicate that the packet has been received */
	tcp_recved(tpcb, p->len);

     /* --- TAP: copy the bytes out before they disappear --- */
    if (rx_len + p->len <= RX_BUF_SIZE) {
        memcpy(&rx_buf[rx_len], p->payload, p->len);
        rx_len += p->len;
    } else {
        /* Would overrun the buffer. Previously this silently skipped the
         * copy AND left rx_len untouched, so the frame could never
         * complete and rx_len stayed stuck forever -- every later detect
         * piled onto the stale value and overflowed too. Resetting here
         * means a bad frame costs us one detect instead of wedging the
         * board until reboot. */
        xil_printf("rx overflow (rx_len=%d + %d) -- resetting\n\r",
                   rx_len, p->len);
        rx_len = 0;
    }
    

    /* Result packet, sent as its own tcp_write below when a detect
     * frame completes. Static so it stays valid until lwIP copies it. */
    static u8_t reply[4];
    int  send_result = 0;   /* set when reply[] has been filled in */

    /* ---------------- VARIANT SELECT: 0xFA 0xCE <code> ----------------
     * Only 3 bytes long, so it is complete as soon as we have 3. Load
     * the matching partial bitstream. The payload is left alone, so the
     * write below echoes the same 3 bytes back as confirmation. */
    if (rx_len >= 2 && rx_buf[0] == 0xFA && rx_buf[1] == 0xCE) {

        if (rx_len >= 3) {
            uint8_t *bin_ptr = NULL;
            uint32_t bin_size = 0;

            switch (rx_buf[2]) {
                case 0x05: bin_ptr = (uint8_t*)sigf_bin; bin_size = SIGF_BIN_SIZE; break;
                case 0x08: bin_ptr = (uint8_t*)sige_bin; bin_size = SIGE_BIN_SIZE; break;
                case 0x0A: bin_ptr = (uint8_t*)sigt_bin; bin_size = SIGT_BIN_SIZE; break;
                default:
                    xil_printf("unknown variant code: 0x%02x\n\r", rx_buf[2]);
                    break;
            }

            if (bin_ptr) {
                if (LoadDNN(bin_ptr, bin_size) != XST_SUCCESS) {
                    xil_printf("Loading bitstream failed\n\r");
                } else {
                    RGB1_Blue();
                    xil_printf("variant %02x%02x%02x loaded\n\r",
                               rx_buf[0], rx_buf[1], rx_buf[2]);
                }
            }

            rx_len = 0;   /* command consumed, ready for the next one */
        }
    }

    /* ---------------- DETECT: 0xDA + 784 pixels = 1569 bytes ----------
     * The frame arrives over several callbacks. Each partial chunk just
     * echoes normally. On the chunk that completes the frame, we run the
     * DNN and swap the payload for 0xDEEDAF + the predicted digit. */
    else if (rx_len >= 1 && rx_buf[0] == 0xDA) {

        if (rx_len >= RX_BUF_SIZE) {
            static uint16_t pixel_buf[NUM_PIXELS];
            u32 digit = 0;

            /* Rebuild 16-bit pixels from the little-endian byte pairs.
             * Copying into an aligned array also avoids reading 16-bit
             * values straight off the odd offset &rx_buf[1]. */
            for (int k = 0; k < NUM_PIXELS; k++) {
                pixel_buf[k] = rx_buf[1 + k*2] | (rx_buf[1 + k*2 + 1] << 8);
            }
            RGB2_Green();
            if (Use_DigitRecognitionDNN(pixel_buf, &digit) != XST_SUCCESS) {
                xil_printf("DNN failed\n\r");
            }
            RGB2_Blue();
            reply[0] = RESULT_HDR_0;
            reply[1] = RESULT_HDR_1;
            reply[2] = RESULT_HDR_2;
            reply[3] = (u8_t)digit;
            send_result = 1;   /* sent as a second packet after the echo */

            xil_printf("detect %x\n\r", reply[3]);

            rx_len = 0;   /* frame consumed, ready for the next one */
        }
    }

	/* echo back the payload */
	/* in this case, we assume that the payload is < TCP_SND_BUF */
	if (tcp_sndbuf(tpcb) > p->len) {
		err = tcp_write(tpcb, p->payload, p->len, 1);
	} else
		xil_printf("no space in tcp_sndbuf\n\r");

	/* then, if a detect frame just completed, send the result as its
	 * own packet: 0xDE 0xED 0xAF <digit> */
	if (send_result) {
		if (tcp_sndbuf(tpcb) >= 4) {
			err = tcp_write(tpcb, reply, 4, 1);
		} else
			xil_printf("no space in tcp_sndbuf for result\n\r");
	}

	/* push whatever was queued above out now, rather than waiting for
	 * lwIP's next timer tick -- the GUI is sitting on a 5s timeout */
	tcp_output(tpcb);

	/* free the received pbuf */
	pbuf_free(p);

	return ERR_OK;
}

err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err)
{
	static int connection = 1;

	/* set the receive callback for this connection */
	tcp_recv(newpcb, recv_callback);

	/* just use an integer number indicating the connection id as the
	   callback argument */
	tcp_arg(newpcb, (void*)(UINTPTR)connection);

	/* increment for subsequent accepted connections */
	connection++;

	return ERR_OK;
}


int start_application()
{
	struct tcp_pcb *pcb;
	err_t err;
	unsigned port = 7;

	/* create new TCP PCB structure */
	pcb = tcp_new_ip_type(IPADDR_TYPE_ANY);
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* bind to specified @port */
	err = tcp_bind(pcb, IP_ANY_TYPE, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	/* we do not need any arguments to callback functions */
	tcp_arg(pcb, NULL);

	/* listen for connections */
	pcb = tcp_listen(pcb);
	if (!pcb) {
		xil_printf("Out of memory while tcp_listen\n\r");
		return -3;
	}

	/* specify callback to use for incoming connections */
	tcp_accept(pcb, accept_callback);

	xil_printf("TCP echo server started @ port %d\n\r", port);

	return 0;
}