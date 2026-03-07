# 16-Point Radix-2 Pipelined FFT Hardware Accelerator

![Status](https://img.shields.io/badge/Status-Verified-brightgreen)
![Language](https://img.shields.io/badge/Language-Verilog_HDL-orange)
![Tools](https://img.shields.io/badge/Tools-Xilinx_Vivado_%7C_MATLAB-red)

## Project Overview

A fully pipelined 16-point FFT hardware accelerator designed from scratch in Verilog. This project bridges theoretical Digital Signal Processing (DSP) with practical VLSI implementation, using a **Radix-2 Multi-path Delay Commutator (R2MDC)** architecture with **Decimation in Frequency (DIF)** for high-throughput continuous streaming.

---

## Hardware Architecture (R2MDC)

The R2MDC architecture processes a **single continuous input stream** through 4 cascaded pipeline stages. Each stage stores half the incoming data in a delay line, then feeds both the new input and the delayed data into a butterfly unit simultaneously.

### Pipeline Structure

```
din ──► Stage 1 ──► Stage 2 ──► Stage 3 ──► Stage 4 ──► dout_top
        delay=8     delay=4     delay=2     delay=1      dout_bot
```

### Key Components

| Component | Module | Purpose |
|-----------|--------|---------|
| Delay Lines | `delay_line.v` | Shift register FIFOs — hold samples for N cycles |
| Butterfly Unit | `Butterfly_unit.v` | Core FFT math: A+B and (A-B)×twiddle |
| FFT Stage | `r2mdc_stage.v` | One pipeline stage: delay + commutator mux + butterfly + register |
| Control Unit | `fft_control_unit.v` | Generates sel signals, ROM addresses, and dout_valid flag |
| Twiddle ROMs | `stage1/2/3_rom` | Pre-computed complex coefficients in Block RAM |
| Top Level | `fft_16_top.v` | Connects all 4 stages together |

### Commutator Design (Important)

The R2MDC commutator is **not** a 2-input crossbar switch. It is a **single-input feedback mux** — the delay line always shifts the input, and a mux selects the butterfly inputs based on the `sel` control signal:

```
sel=0 (fill phase):    butterfly top = delay_out,  bot = 0       → butterfly idles
sel=1 (compute phase): butterfly top = din,         bot = delay_out → butterfly fires
```

This gives the stage a single input port (`din_top`) with internal feedback through the delay line.

---

## Key Engineering Implementations

### 1. Q15 Fixed-Point Arithmetic & Bit-Growth Management

All arithmetic uses strict **Q15 fixed-point** (16-bit signed).

- **Overflow Prevention:** 17-bit sign-extension inside butterfly add/subtract, followed by divide-by-2 scaling
- **Complex Multiplication:** 16×16-bit multipliers with `[30:15]` bit extraction to maintain Q15 fractional alignment
- **Total scaling:** 4 stages × ÷2 = ÷16, which cancels exactly for a 16-point FFT

### 2. Synchronous BRAM Early-Fetch

Xilinx Block RAMs have 1-cycle read latency. The control unit uses an **early-fetch** strategy — ROM addresses are driven from `next_count` (one cycle ahead), so twiddle data arrives exactly when the butterfly needs it:

```verilog
wire [3:0] next_count = count + 1'b1;
assign rom_addr1 = next_count[2:0];  // fetch next twiddle now
```

### 3. Pipeline Valid Flag

A `dout_valid` output goes HIGH after exactly 19 clock cycles (8+4+2+1 delay depths + 4 output registers). This suppresses pipeline fill artifacts and clearly marks when output is meaningful.

### 4. Output Pipeline Registers

Each `r2mdc_stage` includes a clocked output register that also **gates fill-phase garbage** — during `sel=0`, the register passes the delay line output rather than butterfly results, preventing partial sums from corrupting downstream stages.

---

## Verification Results

**Test: DC Input (most fundamental FFT correctness test)**

Input: 32 samples of `din_real = 1000`, `din_imag = 0`

| Output Signal | Expected | Result | Status |
|--------------|----------|--------|--------|
| `dout_top_real` (X[0]) | 1000 | 1000 | ✅ PASS |
| `dout_top_imag` | 0 | 0 | ✅ PASS |
| `dout_bot_real` (X[1..15]) | 0 | 0 | ✅ PASS |
| `dout_bot_imag` | 0 | 0 | ✅ PASS |
| `dout_valid` timing | Cycle 19 | Cycle 19 | ✅ PASS |

All DC energy correctly appears in bin X[0] only. All other bins are zero.

> Note: Output values before `dout_valid` goes HIGH are pipeline fill artifacts and should be ignored.

---

## Verification Strategy

Verification followed a strict **bottom-up modular** approach:

1. **Combinational Logic** — Butterfly unit tested for mathematical accuracy in isolation
2. **Sequential Logic** — Delay lines tested for correct DEPTH-cycle latency
3. **Stage Integration** — Single `r2mdc_stage` tested with known inputs
4. **Top-Level Integration** — DC test across full 4-stage pipeline
5. **Golden Reference** — MATLAB FFT script used to cross-verify hardware output

---

## Pipeline Latency

```
Stage 1 delay:    8 cycles
Stage 2 delay:    4 cycles
Stage 3 delay:    2 cycles
Stage 4 delay:    1 cycle
Output registers: 4 cycles (1 per stage)
─────────────────────────────────────
Total latency:   19 cycles
```

`dout_valid` goes HIGH at cycle 19 and remains HIGH for continuous streaming input.

---


## Known Limitations

- Output is in **bit-reversed order** (standard for DIF FFT). `bit_reversal_16.v` exists in the project but is not yet connected at the top level.
- Verified with DC input only. Sine wave test against MATLAB golden reference is pending.

---
## Simulation Waveforms

### DC Test — Verified Output
![DC Verified]<img width="1577" height="418" alt="image" src="https://github.com/user-attachments/assets/3b9d6d1a-2435-41b0-ba23-5f6dc9f986e7" />

*dout_valid goes HIGH at cycle 19. dout_top_real = 1000 (X[0] correct). All other bins = 0.*

### Full Pipeline View
![Full Pipeline]<img width="1577" height="551" alt="image" src="https://github.com/user-attachments/assets/74db86d1-9a23-4d6a-b971-cc57689ee34e" />

*Shows reset → data input → pipeline fill (expected artifacts) → valid output window.*

### Valid Flag Transition
![Valid Transition]<img width="1559" height="487" alt="image" src="https://github.com/user-attachments/assets/814d3d72-c50b-436e-bee8-d46e64701ec3" />

*Exact moment dout_valid goes HIGH — garbage suppressed, correct output begins.*\
### Vivado Project Sources
![Sources]<img width="642" height="803" alt="image" src="https://github.com/user-attachments/assets/1ce7a75b-c0ee-4c51-8ee0-6355c9aa7c73" />


### Console Output
![Console]<img width="1627" height="668" alt="image" src="https://github.com/user-attachments/assets/b615eb4c-6d72-4734-a67a-272b40b2ca51" />


## Directory Structure

```
📦 R2MDC_FFT_Project
 ┣ 📂 src
 ┃ ┣ 📜 fft_16_top.v        ← Top-level, connects all 4 stages + control
 ┃ ┣ 📜 r2mdc_stage.v       ← Single pipeline stage (delay + mux + butterfly + register)
 ┃ ┣ 📜 fft_control_unit.v  ← sel signals, ROM addresses, dout_valid flag
 ┃ ┣ 📜 Butterfly_unit.v    ← Complex add/sub/multiply math engine
 ┃ ┣ 📜 delay_line.v        ← Parameterised shift register
 ┃ ┗ 📜 commutator_2x2.v    ← Kept for reference (not used in final design)
 ┣ 📂 sim
 ┃ ┗ 📜 tb_fft_16_top.v     ← Top-level DC test with dout_valid gating
 ┣ 📂 matlab
 ┃ ┗ 📜 twiddle_gen.m       ← Generates .coe files for twiddle ROMs
 ┗ 📜 README.md
```

---

## Tools

- **Xilinx Vivado 2022.2** — Synthesis, simulation (XSim)
- **MATLAB** — Golden reference FFT, twiddle factor generation
- **Verilog HDL** — RTL implementation

## Project Learning Journal[R2MDC_FFT_Learning_Journal.docx](https://github.com/user-attachments/files/25814684/R2MDC_FFT_Learning_Journal.docx)

A detailed personal document covering every bug found, every fix applied,
and every concept learned during this 10-day build.

