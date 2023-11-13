module top_level_task1(CLOCK_50, SW, KEY, HEX0, HEX1, LEDR);

    input logic CLOCK_50;
    input logic [9:0] SW;
    input logic [3:0] KEY;
    output logic [6:0] HEX0, HEX1;
    output logic [9:0] LEDR;

    logic clk, reset, start, done_counter;
    logic [7:0] A;

    assign clk = CLOCK_50;
    assign A = SW[7:0];

    basic_D_FF reset_ff (reset, ~KEY[0], CLOCK_50);
    basic_D_FF start_ff (start, ~KEY[3], CLOCK_50);

    // task 1
    logic clear_result, load_a, right_shift, incr;
    logic [2:0] result;
    logic [7:0] A_in, A_out;

    assign A_in = A;

    counter_controller my_count_controller (clk, reset, start, A_out, done_counter, incr, load_a, right_shift, clear_result);
    counter_datapath my_count_datapath (clk, reset, clear_result, load_a, right_shift, done_counter, incr, A_in, A_out, result);

    logic [6:0] hex_task_1_0, hex_task_1_1;

    // task 1 display
    seg7 my_seg0({1'b0, result}, hex_task_1_0);
    assign hex_task_1_1 = 7'b1111111;

    assign HEX0 = hex_task_1_0;
    assign HEX1 = hex_task_1_1;

    // led
    assign LEDR[9] = done_counter;


endmodule

`timescale 1ps/1ps
module top_level_task1_tb();
    logic CLOCK_50;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1;
    logic [9:0] LEDR;

    top_level_task1 dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    logic reset;
    logic start;
    logic [7:0] A;

    assign SW[7:0] = A;

    assign KEY[0] = ~reset;
    assign KEY[3] = ~start;

    integer i;
    initial begin
        reset <= 1; A <= 8'b11111111;       @(posedge CLOCK_50);
        reset <= 0; 
                                            @(posedge CLOCK_50);
                                            @(posedge CLOCK_50);
                    A <= 8'b10101010;       @(posedge CLOCK_50);
                    start <= 0;    @(posedge CLOCK_50);
                    start <= 1;    @(posedge CLOCK_50);

        for (i = 0; i < 12; i++) begin
                            @(posedge CLOCK_50);
        end

                A <= 8'b00000011;   @(posedge CLOCK_50);
                    start <= 0;     @(posedge CLOCK_50);
                                    @(posedge CLOCK_50);
                    start <= 1;     @(posedge CLOCK_50);
        for (i = 0; i < 8; i++) begin
                            @(posedge CLOCK_50);
        end
        $stop;
    end
endmodule
