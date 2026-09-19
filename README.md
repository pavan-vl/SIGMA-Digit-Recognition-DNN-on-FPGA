# SIGMA-Digit-Recognition-DNN-on-FPGA
SIGMA - Sigmoid Granularity Modular Accelerator. It is a hardware implementation of a deep neural network that performs digit recognition based on the MNIST database using varients of the sigmoid function. It is implemented on the Arty Z7 20 board, with Zynq-7000 SoC. 

It includes the RTL implementation of the DNN,interfacing with the processing system (PS -- Cortex A9), firmware that runs TCP communication via LAN and the user interface on the host side.

The overall architecture allows the user to pick between three different variants of the Sigmoid function to be used for the DNN. These variants differ by the step size between the sigmoid function discrete values. The sizes are determined by the total number of samples taken. The variants are Sigmoid-5, Sigmoid-8, and Sigmoid-10. In Sigmoid-N, the 'N' denotes the power raised to the base 2 number of steps. Example - N=5, implies, 2^5 = 32 samples.

These variants can be loaded during run time using DFX (Dynamic Function eXcahnge) capability of the SoC. The user is allowed to switch the variants as many number of times as they please before drawing the digit and starting the DNN.
