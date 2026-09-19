# SIGMA: Sigmoid Granularity Modular Accelerator. A Digit Recognition DNN on a FPGA (SoC)

**SIGMA** A hardware implementation of a deep neural network that performs digit recognition based on the MNIST database using variants of the sigmoid function. It is implemented on the Arty Z7-20 board, with a Zynq-7000 SoC.

It includes the RTL implementation of the DNN, interfacing with the processing system (PS — Cortex-A9), firmware that runs TCP communication via LAN, and the user interface on the host side.

The overall architecture allows the user to pick between three different variants of the sigmoid function to be used for the DNN. These variants differ by the step size between the sigmoid function's discrete values. The sizes are determined by the total number of samples taken. The variants are Sigmoid-5, Sigmoid-8, and Sigmoid-10. In Sigmoid-N, the 'N' denotes the power raised to the base 2 number of steps. Example: N=5 implies 2^5 = 32 samples.

These variants can be loaded during run time using the DFX (Dynamic Function eXchange) capability of the SoC. The user is allowed to switch the variants as many times as they please before drawing the digit and starting the DNN.

---

## How the whole thing works

At a high level, there are three pieces that talk to each other:

```
   HOST PC                      ZYNQ-7000 PS                  ZYNQ-7000 PL
   (Python GUI)                 (Cortex-A9, bare metal)       (FPGA fabric)

   draw a digit  ──TCP/LAN──>   receive 784 pixels    ──AXI-Stream──>   DNN
   pick variant  ──TCP/LAN──>   partial reconfig      ──PCAP──────>     (swapped in)
   show result   <──TCP/LAN──   read predicted digit  <──AXI-Lite──     hardmax
```

### 1. The user draws a digit

The host-side GUI is a Python/Tkinter app. It gives you a 28×28 drawing grid (the same size as an MNIST image), three buttons to pick the sigmoid variant, a **Detect** button, and a **Reset** button to clear the canvas.

Each cell of the grid holds a brightness from 0 (black background) to 255 (full white ink). Drawing with the mouse paints a small soft brush so strokes have gradient edges, roughly like the anti-aliased strokes in real MNIST images.

### 2. The digit is converted to fixed point and sent over TCP

The DNN works in **Q1.15 fixed point** — 16-bit values with 1 sign/integer bit and 15 fractional bits. So each 0–255 brightness is scaled by 128 before it is sent (255 × 128 = 32640, which is ≈0.996 in Q1.15, i.e. an almost-white pixel).

The GUI then sends one packet over TCP:

| Byte(s) | Meaning |
|---|---|
| 0 | `0xDA` — "this is a detect request" |
| 1 … 1568 | 784 pixels, 16 bits each, little-endian |

Total: **1569 bytes**.

### 3. The firmware collects the packet

TCP is a stream, not a set of neat messages, so those 1569 bytes usually arrive split across several callbacks. The firmware (built on the lwIP raw API) copies each chunk into a buffer and waits until the whole frame has arrived before doing anything with it.

### 4. The pixels are streamed into the DNN

Once the full frame is in, the firmware rebuilds the 784 16-bit pixel values and hands them to the AXI DMA, which streams them into the DNN over **AXI4-Stream**, one pixel per clock.

### 5. The DNN computes the answer in hardware

The network is fully connected with four layers:

```
784 inputs ──> 30 ──> 30 ──> 10 ──> 10 ──> hardmax ──> digit (0-9)
                L1     L2     L3     L4
```

Each neuron:
1. Reads its weights one at a time from its own on-chip weight memory (loaded from `.mif` files at synthesis).
2. Multiplies each incoming pixel by the matching weight and accumulates the running sum, with saturation logic so the accumulator clamps instead of wrapping around on overflow.
3. Passes the final sum through its activation function.

For the sigmoid variants, the activation is **not** calculated at run time. Computing an exponential in hardware is expensive, so instead the sigmoid curve is precomputed offline and stored in a ROM. The top bits of the accumulator are used directly as the ROM address, and the value that comes out is the activation. That lookup table is exactly what the three variants differ in.

Between layers, the 30 (or 10) neuron outputs are serialised one at a time and fed into the next layer, which repeats the same process.

Finally the **hardmax** block compares the 10 output values and reports the index of the largest one — that index is the predicted digit.

### 6. The result goes back to the GUI

The digit lands in an AXI-Lite register that the PS reads. The firmware then sends a short reply, tagged with a marker so the GUI can pick it out of the stream:

| Byte(s) | Meaning |
|---|---|
| 0–2 | `0xDE 0xED 0xAF` — "the next byte is a result" |
| 3 | the predicted digit (0–9) |

The GUI scans the incoming data for that marker and displays the digit that follows.

---

## Switching variants at run time (DFX)

This is the part that makes the project more than a fixed accelerator.

The DNN lives inside a **Reconfigurable Partition** — a reserved rectangle of FPGA fabric. Everything else (the DMA, the interconnects, the PS) sits in the **static region** and keeps running untouched.

Each of the three variants is built into its own **partial bitstream** (`.bin`), containing only the logic for that rectangle. All three are embedded in the firmware as byte arrays.

When you press a variant button, the GUI sends a 3-byte command:

| Bytes | Meaning |
|---|---|
| `0xFA 0xCE 0x05` | load Sigmoid-5 |
| `0xFA 0xCE 0x08` | load Sigmoid-8 |
| `0xFA 0xCE 0x0A` | load Sigmoid-10 |

The firmware then feeds the matching partial bitstream through the **PCAP** interface using the DevCfg peripheral, which rewrites just that rectangle of the FPGA. The Ethernet link, the TCP connection, and the rest of the system stay alive the whole time — no reboot, no reprogramming the whole chip.

Once the swap is done, the firmware echoes the same 3 bytes back so the GUI knows it actually took effect, and the DNN is held in reset briefly so it starts clean.

---

## Why the variants differ

A sigmoid ROM with `2^N` entries covers the same input range no matter what N is — a bigger N just means smaller steps between stored values, so the curve is approximated more finely.

| Variant | ROM entries | Step size |
|---|---|---|
| Sigmoid-5 | 32 | coarse (staircase-like) |
| Sigmoid-8 | 256 | medium |
| Sigmoid-10 | 1024 | fine |

Finer steps mean better accuracy but more BRAM, because every neuron that uses sigmoid instantiates its own copy of the table. That trade-off is the whole point of the project: you can swap between the three on the same board, on the same image, and watch what changes.

---

## Results

Measured on the MNIST test set, running on hardware:

| Variant | Accuracy | LUT | FF | BRAM | DSP | Fmax |
|---|---|---|---|---|---|---|
| Sigmoid-5 | ~90% | 5148 | 5094 | 15 | 160 | ~179 MHz |
| Sigmoid-8 | ~91% | 4744 | 4986 | 35 | 160 | ~180 MHz |
| Sigmoid-10 | ~92% | 4740 | 5018 | 35 | 160 | ~177 MHz |

All three close timing at a 5.714 ns target (175 MHz), which is the frequency the design actually runs at. The Fmax column is what the positive slack implies each build could reach.

A Sigmoid-12 variant was also built (~92.7%, 13674 LUT, 70 BRAM) but is not included here — the accuracy gain over Sigmoid-10 is small, while the resource cost roughly doubles, which is a clear case of diminishing returns.

### Reading the numbers

The interesting result is that **Sigmoid-8 and Sigmoid-10 use exactly the same resources** — 35 BRAM, and LUT counts within 4 of each other — while Sigmoid-10 is about a point more accurate.

The reason is how block RAM is allocated. A Sigmoid-8 table is 256 entries × 16 bits = 4 Kbit, and a Sigmoid-10 table is 1024 × 16 = 16 Kbit. But BRAM comes in fixed-size blocks, and each neuron instantiates its own copy of the table, so both variants consume the same number of blocks. The smaller table simply leaves more of each block unused.

So the meaningful jump is between Sigmoid-5 and Sigmoid-8: 15 BRAM to 35 BRAM buys roughly a point of accuracy. Past that, going from 8 to 10 is effectively free, and going from 10 to 12 doubles BRAM for well under a point.

If you want the smallest build, Sigmoid-5 is the one to pick. If you want the most accurate build that still fits comfortably, Sigmoid-10 — there is no good reason to deploy Sigmoid-8 over it. That does not make Sigmoid-8 useless here: it is exactly the kind of result that only shows up once you build all the variants and compare them, which is what this project set out to do.

> **Note on live drawing:** accuracy on hand-drawn input through the GUI is lower than the numbers above. MNIST images were preprocessed — each digit is scaled to fit a 20×20 box and shifted so its centre of mass sits at the centre of the frame. The GUI does not replicate that preprocessing, so a digit drawn off-centre or with thicker strokes looks different to the network than anything it was trained on. A fully-connected network has no translation invariance, so this matters more than it would for a CNN.

---

## Repository layout

| File | What it is |
|---|---|
| `dnn_top.v` | Top level — AXI-Stream input, layer chaining, hardmax, AXI-Lite output |
| `CNN_Layer1..4.v` | One file per layer; instantiates 30/30/10/10 neurons |
| `neuronDes.v` | A single neuron: weight memory, multiply-accumulate, saturation, activation |
| `Weight_Memory.v` | Per-neuron weight ROM, loaded from `.mif` |
| `Sigmoid_ROM.v` | Sigmoid lookup table |
| `ReLU_FunctionDes.v` | ReLU activation (alternative to sigmoid) |
| `hardwaremaxfinder.v` | Hardmax — finds the index of the largest output |
| `includes.v` | All the configuration macros (layer sizes, activation types, sigmoid size) |

---

## Status LEDs

The board's two RGB LEDs show what is happening without needing the serial console, which is handy when the board is sitting next to you during a demo.

**LED 1 (LD4) — network status**

| Colour | Meaning |
|---|---|
| Red | Ethernet PHY autonegotiation failed; there is no usable link |
| Green | Link is up and the TCP server is listening on `192.168.1.10` port `7` |
| Blue | Link is up **and** a sigmoid variant has been loaded, so the board can actually answer a detect request |

**LED 2 (LD5) — DNN status**

| Colour | Meaning |
|---|---|
| Red | No inference has been run yet since power-up |
| Green | An inference is in progress |
| Blue | A digit has been predicted and sent back to the GUI |

Green on LED 2 is usually only a brief flash, because the inference itself finishes quickly.

The LEDs are driven straight from the AXI GPIO data register rather than through the XGpio driver, so the helper is a single header with no driver instance to share between source files. Both LEDs sit in one 6-bit GPIO channel, so each colour helper clears only its own three bits and leaves the other LED alone.

---

## Build notes

- **Sigmoid tables** are generated offline by a Python script and written as `.mif` files, one per variant. The generator must use the same fixed-point convention as the RTL (`weightIntWidth = 4`) or the table will be scaled wrongly and the network will produce nonsense.
- **Weights and biases** come from training in Python, converted to Q1.15 and written as one `.mif` per neuron.
- **`includes.v` selects the build.** Set the four `Size_Sigmoid_Lx` macros and the filename in `Sigmoid_ROM.v` to the variant you are building, then synthesise. Each variant gets its own implementation run and its own partial bitstream.
- Partial bitstreams must be generated with the `-bin_file` option. The PCAP interface needs raw `.bin` data, not the headered `.bit` format.
