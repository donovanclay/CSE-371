// module rom_test (CLOCK_50, SW, LEDR);
//     input logic CLOCK_50;
//     input logic [9:0] SW;
//     output logic [9:0] LEDR;


//     logic [4:0] address;
//     logic [7:0] data;

//     assign address = SW[4:0];

//     rom dut(address, CLOCK_50, data);


// endmodule 

`timescale 1ps/1ps
module rom_test_tb();
    logic CLOCK_50;
	logic clk;

	assign CLOCK_50 = clk;

    logic [4:0] address;
    logic [7:0] data;

    rom dut(address, CLOCK_50, data);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        address <= 15;  @(posedge clk);
        address <= 7;  @(posedge clk);
        address <= 15;  @(posedge clk);
        $stop;
    end

endmodule