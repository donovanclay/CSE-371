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

    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
    assign LEDR[8:0] = SW[8:0];

    logic line_color;
    logic [10:0] x0, y0, x1, y1, x, y;

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
                
    logic line_done, animation_done, hard_reset, line_drawer_reset;

    line_drawer lines (.clk(divided_clocks[0]), .reset(line_drawer_reset),.x0, .y0, .x1, .y1, .x, .y, .done(line_done));

    logic [11:0] read_addr;
    logic [38:0] rom_out;

    assign hard_reset = SW[0];
    enum {s_start, s_stall, s_drawline, s_finished_line, s_done} ps, ns;
    
    logic [8:0] count;

    always_comb begin
        case (ps)
            s_start: begin
                ns <= s_stall;
            end

            // s_erasestall: 
            //     if (count == 127) ns <= s_drawline;
            //     else ns <= s_erasestall;
                
            s_stall:
                ns <= s_drawline;

            s_drawline: begin
                if (line_done) ns <= s_finished_line;
                else ns <= s_drawline;
            end

            s_finished_line: begin
                if (read_addr < 607) begin
                    // if (read_addr % 6 >= 2) 
                    //     ns <= s_erasestall;
                    // else 
                        ns <= s_stall;
                end
                else ns <= s_done;
            end

            s_done: ns <= s_start;

        endcase
    end

    always_ff @(posedge divided_clocks[13]) begin
        if (ps == s_start) begin
            read_addr <= 0;
            line_drawer_reset <= 1'b1;
        end
        
        // if (ns == s_stall && ps != s_stall) begin
        //     count <= 0;
        // end
        
        // if (ps == s_stall) begin
        //     count <= count + 1'b1;
        // end

        if (ps == s_drawline) begin
            line_drawer_reset <= 1'b0;
        end 

        if (ps == s_finished_line) begin
            read_addr <= read_addr + 1'b1;
            line_drawer_reset <= 1'b1;
        end 
    end

    always_ff @(posedge divided_clocks[13]) begin
        if (hard_reset) begin
            ps <= s_start;
        end 
        else ps <= ns;
    end

    lines_rom my_rom (read_addr, CLOCK_50, rom_out);

    assign LEDR[9] = divided_clocks[13];
    assign line_color = rom_out[38];
    assign x0 = rom_out[37:28];
    assign y0 = rom_out[27:19];
    assign x1 = rom_out[18:9];
    assign y1 = rom_out[8:0];
    // assign x0 = 61;
    // assign y0 = 146;
    // assign x1 = 180;
    // assign y1 = 20;


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
        SW[0] <= 0;             @(posedge CLOCK_50);

        for (i = 0; i < 500; i++) begin
                                @(posedge CLOCK_50);
        end
        $stop;
    end 

endmodule