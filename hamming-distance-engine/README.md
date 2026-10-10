# Hamming Distance and Similarity Engine

This is our project for the course COL215 (Digital Logic and System Design) at IIT Delhi. It has two parts:

- **Lab 4a:** a circuit in Verilog that finds the Hamming distance between two 8-bit numbers. We tested it in simulation.
- **Lab 4b:** we put the same circuit on a Basys3 FPGA board, so we can use switches, LEDs and the seven-segment display.

Made by:
- Ansh (2025CS51207)
- Priyam Gupta (2025CS11135)

---

## What is Hamming distance?

Hamming distance is the number of bit places where two binary numbers are different.

For example:

```
A       = 10110100
B       = 10011100
A XOR B = 00101000
```

There are two 1s in the XOR result, so the Hamming distance is 2.

---

## What our circuit does

The main module is `hamming_distance8`. It takes `A` (8 bits), `B` (8 bits) and a `threshold` (4 bits). It gives four outputs:

| Output | What it means |
|---|---|
| `difference[7:0]` | A XOR B |
| `distance[3:0]` | the Hamming distance (0 to 8) |
| `equal` | 1 if A and B are the same |
| `within_threshold` | 1 if distance <= threshold |

If the threshold is 9 to 15, `within_threshold` is always 1, because the distance can never be more than 8.

The whole thing is combinational. There is no clock and no register in it.

---

## Rules we followed in 4a

- We did not use `+`, `-`, `==`, `<`, `>`, `<=`, `>=` in the design files. (We used them only in the testbench.)
- The bit counter is built from full adders and half adders, joined together like a tree.
- The 4-bit comparator and the 8-bit equal checker are built by hand from gates.

---

## Modules

All of these are in `code4a.v`:

- `full_adder` adds three 1-bit inputs.
- `half_adder` adds two 1-bit inputs.
- `popcount8` counts the 1s in an 8-bit number using adders.
- `comparator8_eq` checks if all 8 bits are zero (used to check if A and B are equal).
- `comparator4` compares two 4-bit numbers and gives eq, lt and gt.
- `hamming_distance8` is the top module that joins everything.

How the top module works:

1. `difference = A ^ B`
2. `popcount8` counts the 1s in `difference`, and that is `distance`.
3. `comparator8_eq` checks if `difference` is all zeros, and that is `equal`.
4. `comparator4` compares `distance` with `threshold`. `within_threshold = lt | eq`.

In `code4b.v`:

- `mux2_1_8bit` picks one of two 8-bit inputs.
- `hamming_wrapper` is the top module for the board. It keeps A and B in two registers, runs `hamming_distance8`, and drives the LEDs and the display.

---

## Testing (Lab 4a)

The testbench is `test.v` (module `tb_hamming_distance8`). It is self-checking.

- It tries all 65,536 pairs of A and B, with a set of threshold values.
- For each case it works out the correct answer with normal Verilog operators, and compares it with our circuit.
- At the end it prints a clear PASS or FAIL.

To run it, add `code4a.v` as a design source and `test.v` as a simulation source in Vivado, then run behavioral simulation. You can also use EDA Playground.

Waveform screenshots are in the report PDF.

---

## Running on the Basys3 board (Lab 4b)

### Switches

| Switch | Use |
|---|---|
| SW7 to SW0 | the number you are typing in |
| SW8 | 0 means save into A, 1 means save into B |
| SW12 to SW9 | threshold |
| SW15 to SW13 | not used |

### Outputs

| Output | Shows |
|---|---|
| LED7 to LED0 | A XOR B |
| LED14 | within_threshold |
| LED15 | equal |
| Seven-segment | `--0d`, where d is the Hamming distance |

### How to use it

1. Set SW8 to 0 and set SW7 to SW0 to the value of A.
2. Set SW8 to 1 and set SW7 to SW0 to the value of B.
3. Set the threshold with SW12 to SW9.
4. Look at the LEDs and the display.

The registers take the value on the clock edge. The board clock is fast, so this happens right away.

### Programming the board

You can use the ready bitstream `hamming_wrapper.bit` and load it with Vivado Hardware Manager.

Or you can build it yourself:

1. Make a new Vivado project for the Basys3 (part `xc7a35tcpg236-1`).
2. Add `code4a.v` and `code4b.v` as design sources.
3. Add `basys3.xdc` as the constraint file.
4. Set `hamming_wrapper` as the top module.
5. Run synthesis, implementation and generate the bitstream.

---

## Which part is combinational and which is sequential

Sequential (uses the clock):
- `reg_A` and `reg_B`
- the refresh counter for the display
- the active digit register

Combinational:
- the two muxes
- `hamming_distance8` and everything inside it
- the seven-segment decoder
- the LED connections

---

## Resource use

From the Vivado report after implementation:

- LUTs: 36
- Flip-flops: 35
- BRAM: 0
- DSP: 0

---

## Files in this repo

```
.
├── README.md
├── src/
│   ├── code4a.v              Lab 4a design modules
│   └── code4b.v              Lab 4b wrapper and mux
├── sim/
│   └── test.v                self-checking testbench
├── constraints/
│   └── basys3.xdc            pin constraints
├── bitstream/
│   └── hamming_wrapper.bit   ready to program
└── docs/
    ├── lab4a.pdf             assignment 4a
    ├── lab4b.pdf             assignment 4b
    ├── Lab4a_Report.pdf      our report for 4a
    └── Report_4b_.pdf        our report for 4b
```

---

## Tools

- Vivado 2022.1
- Basys3 board (Artix-7)
