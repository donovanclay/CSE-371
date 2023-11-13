module DE1_SoC_Task3 (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW);

	input  logic		 CLOCK_50;	// 50MHz clock
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// active low
	output logic [9:0] LEDR;
	
	logic [31:0] clk;	

	// from CSE 369
	clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
	
	
	logic [2:0] Datain, Dataout, Dataoutport2;
	logic [4:0] WriteAddress, ReadAddress;
	logic Write, Clock, reset, WhichMemory;
	
	assign Datain = SW[3:1];
	assign WriteAddress = SW[8:4];
	assign Write = SW[0];
	assign Clock = clk[1];
//	assign reset = ~KEY[3];
	assign WhichMemory = SW[9];	
	
	basic_D_FF flip_flop(reset, ~KEY[3], Clock);
	
	
	addr_counter counter(clk[24], reset, ReadAddress);	
	
	task2 my_ram32x3 (Clock, WriteAddress, Datain, Write & ~WhichMemory, Dataout);
	ram32x3port2 my_ram32x3port2(Clock, Datain, ReadAddress, WriteAddress, Write & WhichMemory, Dataoutport2);

	logic [2:0] data;
	
	assign data = WhichMemory ? Dataoutport2 : Dataout;
	
	logic [6:0] HEX3_2, HEX2_2;

	seg7 hex5({{3{1'b0}}, WriteAddress[4]}, HEX5);
	seg7 hex4(WriteAddress[3:0], HEX4);
	seg7 hex3({{3{1'b0}}, ReadAddress[4]}, HEX3_2);
	assign HEX3 = (~WhichMemory) ? 7'b1111111 : HEX3_2;
	assign HEX2 = (~WhichMemory) ? 7'b1111111 : HEX2_2;
	seg7 hex2(ReadAddress[3:0], HEX2_2);
//	seg7 hex2({1'b0, Datain}, HEX2_2);
	seg7 hex1({1'b0, Datain}, HEX1);
	seg7 hex0({1'b0, data}, HEX0);
	
endmodule 
