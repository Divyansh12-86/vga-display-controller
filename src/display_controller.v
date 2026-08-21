module display_controller(
    // Inputs
    input wire pixel_clk,
    input wire reset,

    // Outputs
    output reg hsync,
    output reg vsync,
    output reg display_on,
    output wire [19:0] pixel_addr, // Address for a 640x480 memory
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b,

    // Input from memory
    input wire [11:0] pixel_data
    );

    // Horizontal Timing Parameters
    parameter H_DISPLAY      = 640;
    parameter H_FRONT_PORCH  = 16;
    parameter H_SYNC_PULSE   = 96;
    parameter H_BACK_PORCH   = 48;
    parameter H_TOTAL        = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; // 800

    // Vertical Timing Parameters
    parameter V_DISPLAY      = 480;
    parameter V_FRONT_PORCH  = 10;
    parameter V_SYNC_PULSE   = 2;
    parameter V_BACK_PORCH   = 33;
    parameter V_TOTAL        = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; // 525

    // Counters for horizontal and vertical position
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // Update counters on each pixel clock
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count < H_TOTAL - 1) begin
                h_count <= h_count + 1;
            end else begin
                h_count <= 0;
                if (v_count < V_TOTAL - 1) begin
                    v_count <= v_count + 1;
                end else begin
                    v_count <= 0;
                end
            end
        end
    end

    // Generate Horizontal Sync (active low)
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            hsync <= 1'b1;
        end else begin
            if ((h_count >= H_DISPLAY + H_FRONT_PORCH) && (h_count < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE)) begin
                hsync <= 1'b0;
            end else begin
                hsync <= 1'b1;
            end
        end
    end

    // Generate Vertical Sync (active low)
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            vsync <= 1'b1;
        end else begin
            if ((v_count >= V_DISPLAY + V_FRONT_PORCH) && (v_count < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE)) begin
                vsync <= 1'b0;
            end else begin
                vsync <= 1'b1;
            end
        end
    end

    // Generate display_on signal (high during active video)
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            display_on <= 1'b0;
        end else begin
            if ((h_count < H_DISPLAY) && (v_count < V_DISPLAY)) begin
                display_on <= 1'b1;
            end else begin
                display_on <= 1'b0;
            end
        end
    end
    
    // Generate pixel address for memory
    // Only valid when display_on is high
    assign pixel_addr = (display_on) ? (v_count * H_DISPLAY) + h_count : 20'd0;
    
    // Assign pixel data to VGA outputs (assuming 12-bit R[11:8], G[7:4], B[3:0])
    assign vga_r = display_on ? pixel_data[11:8] : 4'h0;
    assign vga_g = display_on ? pixel_data[7:4]  : 4'h0;
    assign vga_b = display_on ? pixel_data[3:0]  : 4'h0;

endmodule
