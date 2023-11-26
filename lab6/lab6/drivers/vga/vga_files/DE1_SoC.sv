module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, V_GPIO, KEY, LEDR, SW,
                        CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    inout [35:0] V_GPIO;
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

    // N8 CONTROLLER

    wire up;
    wire down;
    wire left;
    wire right;
    wire a;
    wire b;

    wire start;
    wire select;

    wire latch;
    wire pulse;
    
    assign V_GPIO[27] = pulse;
    assign V_GPIO[26] = latch;

    n8_driver driver(
        .clk(CLOCK_50),
        .data_in(V_GPIO[28]),
        .latch(latch),
        .pulse(pulse),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .select(select),
        .start(start),
        .a(a),
        .b(b)
    );

    assign LEDR[7:0] = {up, down, left, right, a, b, start, select, latch, pulse};

    // END OF CONTROLLER 

    logic reset;
    logic [9:0] x;
    logic [8:0] y;
    logic [7:0] r, g, b;

    video_driver #(.WIDTH(640), .HEIGHT(480))
        v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
                .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
                .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

    always_ff @(posedge CLOCK_50) begin
        r <= SW[7:0];
        g <= x[7:0];
        b <= y[7:0];
    end

    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
    assign reset = 0;

    endmodule  // DE1_SoC


    `timescale 1 ps / 1 ps
    module DE1_SoC_testbench ();
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR, SW;
    logic [3:0] KEY;
    logic CLOCK_50;
    logic [7:0] VGA_R, VGA_G, VGA_B;
    logic VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;

    // instantiate module
    DE1_SoC dut (.*);

    // create simulated clock
    parameter T = 20;
    initial begin
        CLOCK_50 <= 0;
        forever #(T/2) CLOCK_50 <= ~CLOCK_50;
    end  // clock initial

    // simulated inputs
    initial begin
        
        $stop();
    end  // inputs initial

    endmodule  // DE1_SoC_testbench