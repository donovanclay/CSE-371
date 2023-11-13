module sync_rom (input logic clk, 
	input logic [7:0] addr,
	output logic [3:0] data);
	// signal declaration
	logic [3:0] rom [0:15][0:15];
	// load binary values from a dummy text file into ROM
	initial
	$readmemh("truthtable4.txt", rom);
	
	// synchronously reads out data from requested addr
	always_ff @(posedge clk)
		data <= rom[addr[7:4]][addr[3:0]];
endmodule // sync_rom