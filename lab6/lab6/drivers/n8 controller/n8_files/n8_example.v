module n8_example (
    input CLOCK_50,
    inout [35:0] V_GPIO,
    output [9:0] LEDR,
    output [6:0] HEX0, 
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5);
    
    wire up;
    wire down;
    wire left;
    wire right;
    wire a;
    wire b;

    wire latch;
    wire pulse;
    
    assign V_GPIO[27] = pulse;
    assign V_GPIO[26] = latch;
    
    assign LEDR[0] = pulse;
    assign LEDR[1] = latch;
    
    assign LEDR[2] = V_GPIO[28];
    assign LEDR[3] = V_GPIO[29]; // gpio 19 of RPico
    assign LEDR[4] = V_GPIO[30]; // gpio 20 of RPico
    
    assign LEDR[5] = V_GPIO[10]; // sw5; for debugging
    assign LEDR[6] = V_GPIO[11]; // sw6; for debugging
    assign LEDR[7] = V_GPIO[12]; // sw7; for debugging

    n8_driver driver(
        .clk(CLOCK_50),
        .data_in(V_GPIO[28]),
        .latch(latch),
        .pulse(pulse),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .select(LEDR[9]),
        .start(LEDR[8]),
        .a(a),
        .b(b)
    );
    
    n8_display display(
        .clk(CLOCK_50),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .select(select),
        .start(start),
        .a(a),
        .b(b),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

endmodule