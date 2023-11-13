module task1(
	input logic clock, 
	input logic [4:0] address,
	input logic [2:0] data,
	input logic wren,
	output logic [2:0] q
	);
	
	ram32x3 ram(.*);

endmodule 