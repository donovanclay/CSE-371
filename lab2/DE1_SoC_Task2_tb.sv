module DE1_SoC_Task2_tb();
	
	
	logic	clock;	// 50MHz clock
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// active low
	logic [9:0] LEDR;
	
	DE1_SoC_Task2 dut (clock, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW);
	
	// define parameters
	parameter T = 20;
	
	// define simulated clock
	initial begin
		clock <= 0;
		forever	#(T/2)	clock <= ~clock;
	end  // initial clock
	
	logic [2:0] Datain;
	logic [4:0] Address;
	logic Write;
	
	assign SW[0] = Write;
	assign SW[8:4] = Address;
	assign SW[3:1] = Datain;
	assign KEY[0] = clock;
	
	integer i;
	initial begin				
		{Write, Address, Datain} <= 0;						@(posedge clock);
		for (i = 0; i < 8; i++) begin
			Address <= i; 	Datain <= i;						@(posedge clock);
		end
		for (i = 0; i < 8; i++) begin
			Address <= i; 	Datain <= i;						@(posedge clock);
		end		
																	@(posedge clock);
										Write <= 1;
		for (i = 0; i < 8; i++) begin
			Address <= i; 	Datain <= 7-i;						@(posedge clock);
		end
										Write <= 0;
		for (i = 0; i < 4; i++) begin
			Address <= i; 										@(posedge clock);
		end
	
										Address <= 0;    		@(posedge clock);
										# 9;
			Address <= i;
		
		for (i = 5; i < 8; i++) begin
			Address <= i; 										@(posedge clock);
		end
																	@(posedge clock);
																	@(posedge clock);
		
		$stop;  // pause the simulation
	end
	

endmodule // DE1_SoC_Task2_tb