# 16-pt-R2MDC_FFT
# 16-Point Radix-2 Pipelined FFT Hardware Accelerator

![Status](https://img.shields.io/badge/Status-RTL_Verification-blue)
![Language](https://img.shields.io/badge/Language-Verilog_HDL-orange)
![Tools](https://img.shields.io/badge/Tools-Xilinx_Vivado_%7C_MATLAB-red)

## 📌 Project Overview
This repository contains the RTL implementation of a 16-point, continuous-flow Fast Fourier Transform (FFT) hardware accelerator. Designed from scratch in Verilog, this project bridges theoretical Digital Signal Processing (DSP) with practical VLSI implementation, utilizing a **Radix-2 Multi-path Delay Commutator (R2MDC)** architecture to achieve high throughput for real-time applications.
 

##  Hardware Architecture (R2MDC)
The R2MDC architecture was selected for its efficient hardware utilization and ability to process continuous streaming data. 

* **Pipelined Stages:** The design consists of log_2(16) = 4 cascaded stages.
* **Commutators (Routing):** 2x2 crossbar switches synchronize the incoming data stream with the delayed data stream.
* **Delay Lines:** Shift registers (FIFOs) queue the data to ensure the Butterfly Units receive the correct temporal samples simultaneously.
* **Twiddle Factor ROMs:** Pre-computed complex coefficients are stored in local Block RAM arrays.
   <img width="1552" height="340" alt="image" src="https://github.com/user-attachments/assets/ee76a30d-156c-445b-86ee-5ade0761be9b" />


##  Key Engineering Implementations

### 1. Q15 Fixed-Point Arithmetic & Bit-Growth Management
Floating-point math is too expensive for efficient RTL. This design utilizes strict **Q15 fixed-point arithmetic**.
* **Overflow Prevention:** Engineered 17-bit intermediate sign-extension logic inside the Butterfly Units to safely handle addition/subtraction bit-growth, followed by divide-by-2 scaling.
* **Complex Multiplication:** Implemented custom 16x16-bit multipliers for the Twiddle Factors, precisely extracting the `[30:15]` bits to maintain Q15 fractional alignment.

### 2. Strict Memory Initialization & Synchronization
* Resolved unknown (`X`) state propagation by implementing a strict, synchronized reset chain across all deep shift registers (`delay_line.v`).
* Eliminated multiple-driver collisions (`Z` and `X` states) on the final output buses by buffering intermediate stage outputs.

##  Verification Strategy
Verification is performed using a strict **Bottom-Up** modular approach:
1.  **Combinational Logic Verification:** Isolated Butterfly Units tested for mathematical accuracy.
2.  **Sequential Logic Verification:** Delay lines and commutators tested for precise clock-cycle latency and lane-switching alignment.
3.  **Top-Level Integration:** Impulse (`7FFF`, followed by `0000`s) and pure DC tests run across the fully connected pipeline.
4.  **Golden Reference:** Hardware simulation outputs (Vivado) are cross-verified against a custom MATLAB FFT script to guarantee frequency bin accuracy.

## 📂 Directory Structure
```text
📦 R2MDC_FFT_Project
 ┣ 📂 src               # Verilog RTL source files
 ┃ ┣ 📜 fft_16_top.v    # Top-level motherboard
 ┃ ┣ 📜 r2mdc_stage.v   # Individual pipeline stage
 ┃ ┣ 📜 Butterfly_unit.v# Math engine (Add/Sub/Mult)
 ┃ ┣ 📜 delay_line.v    # Shift registers
 ┃ ┗ 📜 commutator_2x2.v# Data routing
 ┣ 📂 sim               # Testbenches
 ┃ ┗ 📜 tb_fft_16_top.v # Top-level system testbench
 ┣ 📂 matlab            # Golden reference models
 ┃ ┗ 📜 twiddle_gen.m   # Generates .coe files for ROMs
 ┗ 📜 README.md         # Project documentation
