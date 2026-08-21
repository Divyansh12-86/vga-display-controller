# -*- coding: utf-8 -*-
"""
VGA Display Emulator

Description:
  This script reads a text file containing simulated VGA signal data
  (HSYNC, VSYNC, display_on, R, G, B) and reconstructs the image using Pygame.
  It acts as a virtual monitor for the Verilog simulation output.

Usage:
  python display_emulator.py
"""
import pygame
import sys
import time

# --- Configuration ---
VGA_SIGNALS_FILE = 'vga_signals.txt'
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480
PIXEL_SCALE = 1  # Set to > 1 to scale up the window
WINDOW_TITLE = "VGA Display Emulator"

# These timing constants are for tracking position.
# They should match the Verilog controller's parameters.
H_TOTAL = 800
V_TOTAL = 525

def main():
    """Main function to run the emulator."""
    pygame.init()

    # Set up the display window
    window_size = (SCREEN_WIDTH * PIXEL_SCALE, SCREEN_HEIGHT * PIXEL_SCALE)
    screen = pygame.display.set_mode(window_size)
    pygame.display.set_caption(WINDOW_TITLE)
    
    # Create a surface for the VGA display content, which we can scale up
    display_surface = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
    display_surface.fill((0, 0, 0))  # Start with a black screen

    try:
        with open(VGA_SIGNALS_FILE, 'r') as f:
            vga_signals = f.readlines()
    except FileNotFoundError:
        print(f"Error: The input file '{VGA_SIGNALS_FILE}' was not found.")
        print("Please run the Verilog simulation first to generate it.")
        sys.exit(1)

    print(f"Successfully loaded {len(vga_signals)} clock cycles from '{VGA_SIGNALS_FILE}'.")
    print("Starting emulation... Close the window to exit.")

    running = True
    signal_iterator = iter(vga_signals)
    x, y = 0, 0
    frame_count = 0

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        try:
            # Read one line of signal data, corresponding to one pixel clock cycle
            line = next(signal_iterator)
            parts = line.strip().split()
            
            if len(parts) != 6:
                continue

            hsync, vsync, display_on, r, g, b = [int(p) for p in parts]

            # If display_on is high, draw the pixel
            if display_on and 0 <= x < SCREEN_WIDTH and 0 <= y < SCREEN_HEIGHT:
                # Scale 4-bit color (0-15) to 8-bit color (0-255)
                color = (r * 17, g * 17, b * 17)
                display_surface.set_at((x, y), color)

            # Update pixel coordinates based on VGA timing
            x += 1
            if x >= H_TOTAL:
                x = 0
                y += 1
                if y >= V_TOTAL:
                    y = 0
                    frame_count += 1
                    print(f"Frame {frame_count} drawn.")
                    # Update the scaled screen after a full frame is drawn
                    scaled_surface = pygame.transform.scale(display_surface, window_size)
                    screen.blit(scaled_surface, (0, 0))
                    pygame.display.flip()
                    
                    # Optional: Add a small delay to visualize the drawing process
                    # time.sleep(0.5)


        except StopIteration:
            # Reached the end of the signal file
            print("End of simulation file reached.")
            # Final update to show the complete image
            scaled_surface = pygame.transform.scale(display_surface, window_size)
            screen.blit(scaled_surface, (0, 0))
            pygame.display.flip()
            
            # Keep the window open until the user closes it
            while running:
                 for event in pygame.event.get():
                    if event.type == pygame.QUIT:
                        running = False

    pygame.quit()
    sys.exit()

if __name__ == '__main__':
    main()
