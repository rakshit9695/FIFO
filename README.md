# Synchronous & Asynchronous FIFO for Processor Systems

A complete, portfolio-ready Verilog project that implements both **synchronous** and **asynchronous** First-In-First-Out (FIFO) buffers. This repository is designed for rapid experimentation, formal verification, and GitHub publishing as a technical showcase.

---

## Project Goals

| Goal              | Description |
|-------------------|-------------|
| **Robust FIFO IP** | Production-quality RTL for both sync and async FIFO with support for full/empty, almost-full/empty, overflow and underflow conditions. |
| **Clock-Domain Crossing** | Demonstrate safe CDC using Gray-code pointers and double-flop synchronizers in async FIFO. |
| **Verification** | Exhaustive, self-checking testbenches with random stimulus and 100% functional coverage. |
| **Resume Value** | Clean codebase, detailed documentation and testbenches—ready to push to GitHub and share in interviews. |

---

## Repository Layout
fifo-processor-implementation/
├── README.md ← This file
├── docs/ ← Design notes & waveforms
│ └── fifo_whitepaper.pdf
├── src/
│ ├── sync_fifo.v ← Synchronous FIFO RTL
│ ├── async_fifo.v ← Asynchronous FIFO RTL
│ └── common/ ← Shared parameters & helpers
├── testbench/
│ ├── sync_fifo_tb.v ← Self-checking TB for sync FIFO
│ └── async_fifo_tb.v ← Self-checking TB for async FIFO
├── simulation/
│ └── waveforms/ ← .vcd or .wlf simulation dumps
└── synthesis/ ← Constraint & synthesis report stubs



---

## Key Design Files

| File            | Highlights |
|------------------|------------|
| `sync_fifo.v`    | Parameterized single-clock FIFO. Includes overflow/underflow detection, live word count, and configurable flags. |
| `async_fifo.v`   | Dual-clock FIFO using binary-to-Gray and synchronizers. Ensures metastability-safe operation across clock domains. |
| `*_tb.v`         | Randomized, corner-case testbenches. Include formal assertions and coverage tracking. |

---

## Features

- Synchronous FIFO (single clock domain)
- Asynchronous FIFO (dual clock domain)
- Full/Empty & Almost-Full/Empty flags
- Overflow & Underflow detection
- Gray-code-based CDC logic
- Self-checking testbenches
- Modular, parameterized Verilog
---

## 📘 Documentation

Refer to `fifo_description.pdf` for the design theory, architecture diagrams, CDC safety analysis, and verification strategy.

---

## 📌 Usage

Clone and explore:

```bash
git clone https://github.com/yourusername/fifo-processor-implementation.git
cd fifo-processor-implementation

- Use the necessary software required to check the simulations thorugh this codebase.
- Use the testbenches and the coebase in src folder




