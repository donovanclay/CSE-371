module top_level(CLOCK50, SW, KEY, HEX0, LEDR);

	input logic CLOCK50;
	input logic [7:0] SW;
	input logic [3:0] KEY;
	output logic [6:0] HEX0;
	output logic LEDR[9];
	
	logic reset, start, clear_result, load_a, right_shift, incr_result, done;
	logic [2:0] result;
	logic [7:0] A;

	assign reset = KEY[0];
	assign start = KEY[3];
	
	
	counter_controller c_unit(.clk(CLOCK_50), .reset(reset), .s(start), .A(A), .clear_result(clear_result), .load_a(load_a), .right_shift(right_shift), .incr_result(incr_result), .done(done));
	counter_datapath d_unit(.clk(CLOCK_50), .reset(reset), .clear_result(clear_result), .load_a(load_a), .right_shift(right_shift), .incr_result(incr_result), .done(done), .SW(SW), .A(A), .result(result));
	seg7 display({1'b0, result}, HEX0);
	
endmodule

	