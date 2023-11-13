module top_level_bs(CLOCK_50, SW, KEY, HEX0, HEX1, LEDR);

    input logic CLOCK_50;
    input logic [9:0] SW;
    input logic [3:0] KEY;
    output logic [6:0] HEX0, HEX1;
    output logic [9:0] LEDR;

    logic clk;

    assign clk = CLOCK_50;

    logic reset, start, done, found, count_zero, decr, load_regs, below, above, which_task;
    logic [7:0] rom_out, A, A_out;
    logic [4:0] read_addr, loc;

    assign A = SW[7:0];

    assign which_task = SW[9];
    assign reset = ~KEY[0];
    assign start = ~KEY[3];

    rom my_rom(read_addr, CLOCK_50, rom_out);

    bs_controller my_controller (clk, reset, start, count_zero, A, rom_out, read_addr, done, decr, found, load_regs, below, above);
    bs_datapath my_datapath (clk, reset, load_regs, decr, below, above, found, count_zero, read_addr, loc);

    logic [6:0] my_hex0, my_hex1;
    seg7 my_seg1(loc[3:0], my_hex0);
    seg7 my_seg2({3'b0, loc[4]}, my_hex1);

    assign LEDR[9] = done;
    assign LEDR[0] = found;
    assign HEX0 = (found) ? my_hex0 : 7'b1111111;
    assign HEX1 = (found) ? my_hex1 : 7'b1111111;


endmodule

`timescale 1ps/1ps
module top_level_bs_tb();
    logic CLOCK_50;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1;
    logic [9:0] LEDR;

    top_level_bs dut (CLOCK_50, SW, KEY, HEX0, HEX1, LEDR);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    logic reset;
    logic start;
    logic [9:0] A;

    assign SW[9:0] = A;

    assign KEY[0] = ~reset;
    assign KEY[3] = ~start;

    integer i;
    initial begin
        reset <= 1; A <= 19;        @(posedge CLOCK_50);
        reset <= 0;                 @(posedge CLOCK_50);
                    start <= 1;     @(posedge CLOCK_50);
                        @(posedge CLOCK_50);

        for (i = 0; i < 13; i++) begin
                            @(posedge CLOCK_50);
        end
                    start <= 0;     @(posedge CLOCK_50);
                    start <= 1;
                    A <= 230;        @(posedge CLOCK_50);
        for (i = 0; i < 11; i++) begin
                            @(posedge CLOCK_50);
        end

                    start <= 0;     @(posedge CLOCK_50);
                    start <= 1;
                    A <= 225;        @(posedge CLOCK_50);

        for (i = 0; i < 20; i++) begin
                            @(posedge CLOCK_50);
        end
        $stop;
    end
endmodule
