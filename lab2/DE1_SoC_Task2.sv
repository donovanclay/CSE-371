module DE1_SoC_Task2 (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW);

	input  logic		 CLOCK_50;	// 50MHz clock
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// active low
	output logic [9:0] LEDR;
	
	logic [2:0] Datain, Dataout;
	logic [4:0] Address;
	logic Write, Clock;
	
	assign Datain = SW[3:1];
	assign Address = SW[8:4];
	assign Write = SW[0];
	assign Clock = KEY[0];
	
	
	task2 my_ram32x3 (Clock, Address, Datain, Write, Dataout);
	
	
	seg7 hex5({{3{1'b0}}, Address[4]}, HEX5);
	seg7 hex4(Address[3:0], HEX4);
	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	seg7 hex1 ({1'b0, Datain}, HEX1);
	seg7 hex0({1'b0, Dataout}, HEX0);
	
	
endmodule // DE1_SoC_Task2

