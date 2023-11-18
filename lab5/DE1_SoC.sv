/* Top level module of the FPGA that takes the onboard resources 
* as input and outputs the lines drawn from the VGA port.
*
* Inputs:
*   KEY 			- On board keys of the FPGA
*   SW 			- On board switches of the FPGA
*   CLOCK_50 		- On board 50 MHz clock of the FPGA
*
* Outputs:
*   HEX 			- On board 7 segment displays of the FPGA
*   LEDR 			- On board LEDs of the FPGA
*   VGA_R 			- Red data of the VGA connection
*   VGA_G 			- Green data of the VGA connection
*   VGA_B 			- Blue data of the VGA connection
*   VGA_BLANK_N 	- Blanking interval of the VGA connection
*   VGA_CLK 		- VGA's clock signal
*   VGA_HS 		- Horizontal Sync of the VGA connection
*   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
*   VGA_VS 		- Vertical Sync of the VGA connection
*/
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
    VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input logic [3:0] KEY;
    input logic [9:0] SW;
    input CLOCK_50;
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_BLANK_N;
    output VGA_CLK;
    output VGA_HS;
    output VGA_SYNC_N;
    output VGA_VS;

    logic line_color;
    logic [10:0] x0, y0, x1, y1, clear_x0, clear_x1, clear_y, x, y;

    // x coordinates for the sides of the display
    assign clear_x0 = 0;
    assign clear_x1 = 639;

    logic [31:0] divided_clocks;
    clock_divider clock_div (CLOCK_50, divided_clocks);

    VGA_framebuffer fb (
        .clk50			(CLOCK_50), 
        .reset			(1'b0), 
        .x, 
        .y,
        .pixel_color	(line_color), 
        .pixel_write	(1'b1),
        .VGA_R, 
        .VGA_G, 
        .VGA_B, 
        .VGA_CLK, 
        .VGA_HS, 
        .VGA_VS,
        .VGA_BLANK_n	(VGA_BLANK_N), 
        .VGA_SYNC_n		(VGA_SYNC_N));
                
    logic line_done, hard_reset, line_drawer_reset;

    line_drawer lines (.clk(divided_clocks[0]), .reset(line_drawer_reset),.x0, .y0, .x1, .y1, .x, .y, .done(line_done));

    logic [11:0] read_addr;
    logic [38:0] rom_out;

    // controls erasing the entire screen
    assign hard_reset = SW[0];

    enum {s_clear, s_clear_drawline, s_clear_finished_line, s_start, s_stall, s_drawline, s_finished_line, s_done} ps, ns;

    always_comb begin
        case (ps)
            s_clear: begin
                ns <= s_clear_drawline;
            end

            // line drawer is drawing the line 
            s_clear_drawline: begin
                // if the line drawer is finished drawing the line, leave the state
                if (line_done) ns <= s_clear_finished_line;

                // otherwise stay in the draw state
                else ns <= s_clear_drawline;
            end

            s_clear_finished_line: begin
                // if we finished erasing the screen, restart erasing the screen
                // otherwise erase the next horizontal line. 
                if (clear_y >= 479) begin
                    ns <= s_clear;
                end else 
                    ns <= s_clear_drawline;
            end

            s_start: begin
                ns <= s_stall;
            end
                
            // state to wait for the ROM to output its data
            s_stall:
                ns <= s_drawline;

            // line drawer is drawing the line 
            s_drawline: begin
                // if the line drawer is finished drawing the line, leave the state
                if (line_done) ns <= s_finished_line;

                // otherwise stay in the draw state
                else ns <= s_drawline;
            end

            s_finished_line: begin
                // if there is more data to read in the ROM, move to the next address
                if (read_addr < 607) begin
                    ns <= s_stall;
                end

                // reached the end of the data in the ROM
                else ns <= s_done;
            end

            // restart the animation
            s_done: ns <= s_start;
        endcase
    end

    always_ff @(posedge divided_clocks[13]) begin
        // initialize the y-value to 0 and reset the line drawer
        if (ps == s_clear) begin
            clear_y <= 0;
            line_drawer_reset <= 1'b1;
        end

        // start the line drawer
        if (ps == s_clear_drawline) begin
            line_drawer_reset <= 1'b0;
        end

        // increment the y-value and reset the line drawer
        if (ps == s_clear_finished_line) begin
            clear_y <= clear_y + 1'b1;
            line_drawer_reset <= 1'b1;
        end

        // initialize the read address to 0 and reset the line drawer
        if (ps == s_start) begin
            read_addr <= 0;
            line_drawer_reset <= 1'b1;
        end

        // start the line drawer
        if (ps == s_drawline) begin
            line_drawer_reset <= 1'b0;
        end 

        // increment the read address and reset the line drawer
        if (ps == s_finished_line) begin
            read_addr <= read_addr + 1'b1;
            line_drawer_reset <= 1'b1;
        end 
    end

    always_ff @(posedge divided_clocks[13]) begin
        if (hard_reset) begin
            // if we aren't currently in the process of erasing, 
            // start erasing
            if (ps != s_clear && 
                ps != s_clear_drawline && 
                ps != s_clear_finished_line) begin
                ps <= s_clear;
            end else begin
                ps <= ns;
            end
        end else begin
            ps <= ns;
        end
    end

    // ROM which holds data for the animation of "CAM"
    lines_rom my_rom (read_addr, CLOCK_50, rom_out);

    assign LEDR[9] = divided_clocks[13];

    // muxes to choose between erasing or showing the animation.
    assign line_color = (hard_reset) ? 1'b0: rom_out[38];
    assign x0 = (hard_reset) ? clear_x0 : rom_out[37:28];
    assign y0 = (hard_reset) ? clear_y : rom_out[27:19];
    assign x1 = (hard_reset) ? clear_x1 : rom_out[18:9];
    assign y1 = (hard_reset) ? clear_y : rom_out[8:0];

    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
    assign LEDR[8:0] = SW[8:0];


endmodule  // DE1_SoC

`timescale 1ps/1ps
module DE1_SoC_tb();
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic CLOCK_50;
    logic [7:0] VGA_R;
    logic [7:0] VGA_G;
    logic [7:0] VGA_B;
    logic VGA_BLANK_N;
    logic VGA_CLK;
    logic VGA_HS;
    logic VGA_SYNC_N;
    logic VGA_VS;

    DE1_SoC dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    integer i;
    initial begin
                                @(posedge CLOCK_50);
        SW[0] <= 1;             @(posedge CLOCK_50);
        for (i = 0; i < 245760; i++) begin
                                @(posedge CLOCK_50);
        end
        SW[0] <= 0;             @(posedge CLOCK_50);
        for (i = 0; i < 245760; i++) begin
                                @(posedge CLOCK_50);
        end
        $stop;
    end 

endmodule