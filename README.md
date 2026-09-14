# VGA Display Controller Simulator

This project is a hardware-software co-design that simulates the entire pipeline of displaying a digital image, bridging the gap between digital data representation and physical display timing. It implements a complete 640x480 @ 60Hz VGA display controller in Verilog and verifies the hardware logic using a Python-based virtual monitor.

## Table of Contents
- [Repository Structure](#repository-structure)
- [System Architecture](#system-architecture)
- [Prerequisites & Installation](#prerequisites--installation)
- [Quick Start Guide](#quick-start-guide)
  - [Step 1: Image Pre-processing](#step-1-image-pre-processing-matlab)
  - [Step 2: Hardware Simulation](#step-2-hardware-simulation-verilog)
  - [Step 3: Display Emulation](#step-3-display-emulation-python)

---

## Repository Structure

    vga-display-simulator/
    │
    ├── src/                          # Core hardware logic
    │   ├── display_controller.v      # Verilog VGA controller module
    │   └── tb_display_controller.v   # Verilog testbench and environment
    │
    ├── scripts/                      # Software tooling
    │   ├── image_to_hex_converter.m  # MATLAB image processing script
    │   └── displayemu.py             # Python/Pygame virtual monitor       
    │
    ├── data/                         # Input and output assets
    │   └── source_image.png          # Place your test image here
    │
    ├── .gitignore                    # Git ignore rules for compiled files
    └── README.md                     # Project documentation

---

## System Architecture

The workflow consists of three distinct phases:
1. **Pre-processing (MATLAB):** Reads a standard `.png` image, resizes it to 640x480, and converts the 24-bit RGB values into a 12-bit hexadecimal memory map.
2. **Hardware Simulation (Verilog):** The hardware display controller generates precise horizontal and vertical synchronization pulses (`hsync`, `vsync`). The testbench simulates reading from the hex memory map and logs the output video signals cycle-by-cycle to a text file.
3. **Display Emulation (Python):** A Pygame script acts as a virtual CRT monitor. It parses the simulation log and paints the screen pixel-by-pixel based strictly on the hardware's sync and color signals.

---

## Prerequisites & Installation

To run the full simulation pipeline, you will need the following installed on your system:
* **A Verilog Simulator** (e.g., ModelSim, Vivado, Icarus Verilog, etc.)
* **MATLAB** (or GNU Octave)
* **Python 3.x**

Since the Python emulator relies on a single external library, you can install it directly via your terminal:

    pip install pygame

---

## Quick Start Guide

Follow these steps in order to process an image, simulate the hardware, and view the result.

### Step 1: Image Pre-processing (MATLAB)
First, generate the memory map that the Verilog testbench will read.
1. Place the image you want to display into the `data/` folder and name it `source_image.png`.
2. Open MATLAB, navigate to the `scripts/` directory, and run the conversion script:

        run image_to_hex_converter.m

   *This will generate a file named `image_data.hex`.*

### Step 2: Hardware Simulation (Verilog)
Next, compile and simulate the hardware controller to generate the raw video signal log.
1. Using your preferred Verilog simulator, compile and run the testbench (`tb_display_controller.v`) along with the main module (`display_controller.v`).
2. Running the simulation will process an entire 16.8ms video frame (over 400,000 clock cycles) and output a large text file named `vga_signals.txt`. 

   *Note: Ensure that the generated `vga_signals.txt` file is placed in the `scripts/` directory (or update the file path in `display_emulator.py`) before proceeding to the next step.*

### Step 3: Display Emulation (Python)
Finally, run the virtual monitor to visualize the hardware's output.
1. Open your terminal and navigate to the `scripts/` directory.
2. Run the emulator script:

        python display_emulator.py

   *A Pygame window will open and draw the image pixel-by-pixel, simulating exactly how a physical VGA monitor would interpret the hardware signals.*
