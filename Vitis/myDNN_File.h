#ifndef MYDNN_FILE_H
#define MYDNN_FILE_H

#include <stdint.h>
#include "xil_types.h"

#define NUM_PIXELS 784

int DNN_init(void);
int LoadDNN(const uint8_t *data, uint32_t size);
int Use_DigitRecognitionDNN(const uint16_t *pixels, u32 *digit_out);

#endif