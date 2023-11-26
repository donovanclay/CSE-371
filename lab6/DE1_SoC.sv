module DE1_SoC (
    input CLOCK_50,
    inout [35:0] V_GPIO,
    output [9:0] LEDR,
    output [6:0] HEX0, 
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_BLANK_N,
    output VGA_CLK,
    output VGA_HS,
    output VGA_SYNC_N,
    output VGA_VS
    );

    logic reset;

    assign reset = V_GPIO[5];
    
    wire n8_up;
    wire n8_down;
    wire n8_left;
    wire n8_right;
    wire n8_a;
    wire n8_b;

    wire n8_latch;
    wire n8_pulse;
    
    wire n8_select;
    wire n8_start;
    
    assign V_GPIO[27] = n8_pulse;
    assign V_GPIO[26] = n8_latch;
    
    assign LEDR[0] = V_GPIO[5];
    assign LEDR[1] = V_GPIO[6];
    assign LEDR[2] = V_GPIO[7];
    assign LEDR[3] = V_GPIO[8];
    assign LEDR[4] = V_GPIO[9];
    
    assign LEDR[5] = V_GPIO[10]; // sw5; for debugging
    assign LEDR[6] = V_GPIO[11]; // sw6; for debugging
    assign LEDR[7] = V_GPIO[12]; // sw7; for debugging 
    assign LEDR[8] = V_GPIO[13];
    assign LEDR[9] = V_GPIO[14];

    n8_driver driver(
        .clk(CLOCK_50),
        .data_in(V_GPIO[28]),
        .latch(n8_latch),
        .pulse(n8_pulse),
        .up(n8_up),
        .down(n8_down),
        .left(n8_left),
        .right(n8_right),
        .select(n8_select),
        .start(n8_start),
        .a(n8_a),
        .b(n8_b)
    );
    
    n8_display display(
        .clk(CLOCK_50),
        .up(n8_up),
        .down(n8_down),
        .left(n8_left),
        .right(n8_right),
        .select(n8_select),
        .start(n8_start),
        .a(n8_a),
        .b(n8_b),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

    logic [9:0] player_x;
    logic [8:0] player_y;
    logic enable;

    assign enable = 1;

    player_location player_location(
        .CLOCK_50(CLOCK_50),
        .enable(enable),
        .reset(reset),
        .left(n8_left),
        .right(n8_right),
        .out_x(player_x),
        .out_y(player_y)
    );
    
    logic [9:0] x;
    logic [8:0] y;
    logic [7:0] r, g, b;

    video_driver #(.WIDTH(640), .HEIGHT(480))
        v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
                .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
                .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

    always_ff @(posedge CLOCK_50) begin
        r <= (n8_left) ? 122 : 0;
        g <= x[7:0];
        b <= y[7:0];
    end

endmodule