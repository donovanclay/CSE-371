module task2(
	input logic clock, 
	input logic [4:0] address,
	input logic [2:0] data,
	input logic wren,
	output logic [2:0] q
	);
	
	logic [4:0] addr;
	
	logic [2:0] memory_array [31:0] = '{32{0}};
	
	always_ff @(posedge clock)
		if (wren)
			memory_array[address] <= data;
		else 
			memory_array <= memory_array;
			
	always_ff @(posedge clock)
		addr <= address;
		
		
	assign q = memory_array[addr];

	
endmodule // task2