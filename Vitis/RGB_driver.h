/******************************************************************
 * rgb_status.h
 *
 * Status LEDs for the two RGB LEDs on the Arty Z7 20.
 *
 * Header-only on purpose: it pokes the AXI GPIO data register directly
 * with Xil_Out32 instead of using the XGpio driver, so there is no
 * driver instance to share between main.c and echo.c, and nothing new
 * to add to UserConfig.cmake. Just #include it in both files.
 *
 * BEFORE THIS WORKS, CHECK ONE THING:
 *
 * The bit order. If your constraints file ordered the pins
 *    differently, fix the six *_BIT defines -- that is the only place
 *    the mapping appears. Call RGB_SelfTest() once to check.
 ******************************************************************/

#ifndef RGB_STATUS_H
#define RGB_STATUS_H

#include "xil_io.h"
#include "sleep.h"
#include "xparameters.h"



/******************************************************************
 * Hardware Constants
 ******************************************************************/

#define RGB_GPIO_BASE      0x81200000U  

// AXI GPIO register offsets (fixed by the IP, do not change)

#define RGB_GPIO_DATA      0x00
#define RGB_GPIO_TRI       0x04

// Bit positions within the single 6-bit GPIO channel

#define LD4_B_BIT   0      // LED 1 Red
#define LD4_G_BIT   1      // LED 1 Green
#define LD4_R_BIT   2      // LED 1 Blue
#define LD5_B_BIT   3      // LED 2 Red
#define LD5_G_BIT   4      // LED 2 Green
#define LD5_R_BIT   5      // LED 2 Blue

// Masks for clearing one LED without disturbing the other

#define LD4_MASK    ((1u << LD4_R_BIT) | (1u << LD4_G_BIT) | (1u << LD4_B_BIT))
#define LD5_MASK    ((1u << LD5_R_BIT) | (1u << LD5_G_BIT) | (1u << LD5_B_BIT))

#define RGB_SELFTEST_STEP_US   500000U   // dwell time per colour in RGB_SelfTest

/***********************************************************
 * Global Variables
 **********************************************************/

// Current state of all six bits. Avoid overwriting another LED value, because they share the same GPIO register.

static u32 RGB_State = 0;

/***********************************************************
 * Register Access
 **********************************************************/

/**
 *
 * @name RGB_Write
 *
 * Push the current six-bit LED state out to the AXI GPIO data register
 *
 * @return  None.
 *
 * @note Always write 6-bit value so other LED state is untouched.
 *
 *
 */
static inline void RGB_Write(void)
{
    Xil_Out32(RGB_GPIO_BASE + RGB_GPIO_DATA, RGB_State);
}

/***********************************************************
 * Initialisation
 **********************************************************/

/**
 *
 * @name RGB_Init
 *
 * Set up the GPIO pins for the two RGB LEDs as outputs and switch them all off
 *
 * @return  None.
 *
 * @note Write 0 to the tri-state register.
 *
 *
 */
static inline void RGB_Init(void)
{
    Xil_Out32(RGB_GPIO_BASE + RGB_GPIO_TRI, 0x00000000u);
    RGB_State = 0;
    RGB_Write();
}

/***********************************************************
 * LED 1 (LD4) - Network Status
 **********************************************************/

/**
 *
 * @name RGB1_Off
 *
 * Turn every colour off on the first RGB LED (LD4)
 *
 * @return  None.
 *
 * @note None.
 *
 *
 */
static inline void RGB1_Off(void)
{
    RGB_State &= ~LD4_MASK;
    RGB_Write();
}

/**
 *
 * @name RGB1_Red
 *
 * Show red on the first RGB LED (LD4) to flag that Ethernet auto-negotiation failed
 *
 * @return  None.
 *
 * @note None.
 *
 *
 */
static inline void RGB1_Red(void)
{
    RGB1_Off();
    RGB_State |= (1u << LD4_R_BIT);
    RGB_Write();
}

/**
 *
 * @name RGB1_Green
 *
 * Show green on the first RGB LED (LD4) to flag that the TCP server is up and ready for GUI.
 *
 * @return  None.
 *
 * @note None.
 *
 *
 */
static inline void RGB1_Green(void)
{
    RGB1_Off();
    RGB_State |= (1u << LD4_G_BIT);
    RGB_Write();
}

/**
 *
 * @name RGB1_Blue
 *
 * Show blue on the first RGB LED (LD4) once a DNN variant is loaded
 *
 * @return  None.
 *
 * @note None.
 *
 *
 */
static inline void RGB1_Blue(void)
{
    RGB1_Off();
    RGB_State |= (1u << LD4_B_BIT);
    RGB_Write();
}

/***********************************************************
 * LED 2 (LD5) - DNN Status
 **********************************************************/

/**
 *
 * @name RGB2_Off
 *
 * Turn every colour off on the second RGB LED (LD5)
 *
 * @return  None.
 *
 * @note None.
 *
 *
 */
static inline void RGB2_Off(void)
{
    RGB_State &= ~LD5_MASK;
    RGB_Write();
}

/**
 *
 * @name RGB2_Red
 *
 * Show red on the second RGB LED (LD5) while the DNN is still idle
 *
 * @return  None.
 *
 * @note It stays red until the first detect request arrives and Use_DigitRecognitionDNN() is called.
 *
 *
 */
static inline void RGB2_Red(void)
{
    RGB2_Off();
    RGB_State |= (1u << LD5_R_BIT);
    RGB_Write();
}

/**
 *
 * @name RGB2_Green
 *
 * Show green on the second RGB LED (LD5) while the DNN is running
 *
 * @return  None.
 *
 * @note The digit takes very little time, so expect only a brief flash of green.
 *
 *
 */
static inline void RGB2_Green(void)
{
    RGB2_Off();
    RGB_State |= (1u << LD5_G_BIT);
    RGB_Write();
}

/**
 *
 * @name RGB2_Blue
 *
 * Show blue on the second RGB LED (LD5) once a digit has been predicted
 *
 * @return  None.
 *
 * @note Stays blue until the next detect request turns it green again.
 *
 *
 */
static inline void RGB2_Blue(void)
{
    RGB2_Off();
    RGB_State |= (1u << LD5_B_BIT);
    RGB_Write();
}


#endif /* RGB_STATUS_H */