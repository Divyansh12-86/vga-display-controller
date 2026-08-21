# VGA Display Controller Simulator

A hardware-software co-design project that simulates the entire pipeline of displaying a digital image, from a raw matrix to a simulated VGA monitor.

This project bridges the gap between digital data representation and physical display timing, implementing a complete 640x480 @ 60Hz VGA controller in Verilog and verifying it through a Python-based virtual monitor.

## System Architecture

The workflow consists of three distinct phases:
1. **Pre-processing (MATLAB):** Parses a standard `.png` image, resizes it to 640x480, and converts the 24-bit RGB values into a 12-bit hex memory map (`.hex`).
2. **Hardware Simulation (Verilog):** A hardware display controller generates precise horizontal and vertical synchronization pulses (`hsync`, `vsync`). The testbench simulates reading from memory and logs the output signals cycle-by-cycle to a text file.
3. **Display Emulation (Python):** A Pygame script acts as a virtual CRT monitor, parsing the simulation log and painting the screen pixel-by-pixel based on the hardware's sync and color signals.

## Prerequisites

To run the full pipeline, you will need:
* **Icarus Verilog** (`iverilog` and `vvp`) for hardware simulation.
* **MATLAB** (or GNU Octave) for image processing.
* **Python 3.x** with `pygame` (`pip install pygame`).

## Quick Start

### 1. Generate the Memory Map
Place your target image in the `data/` folder and name it `source_image.png`. Run the MATLAB script to generate the memory map:
```matlab
run scripts/image_to_hex.m