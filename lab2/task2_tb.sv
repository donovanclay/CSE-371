module task2_tb();
	logic clock, wren;
	logic [4:0] address;
	logic [2:0] data, q;
	
	task2 dut(.*);
	
	// define parameters
	parameter T = 20;
	
	// define simulated clock
	initial begin
		clock <= 0;
		forever	#(T/2)	clock <= ~clock;
	end  // initial clock
	
	integer i;
	initial begin				
		{wren, address, data} <= 0;						@(posedge clock);
		for (i = 0; i < 8; i++) begin
			address <= i; 	data <= i;						@(posedge clock);
		end
		for (i = 0; i < 8; i++) begin
			address <= i; 	data <= i;						@(posedge clock);
		end		
																	@(posedge clock);
										wren <= 1;
		for (i = 0; i < 8; i++) begin
			address <= i; 	data <= 7-i;						@(posedge clock);
		end
										wren <= 0;
		for (i = 0; i < 4; i++) begin
			address <= i; 										@(posedge clock);
		end
	
										address <= 0;    		@(posedge clock);
										# 9;
			address <= i;
		
		for (i = 5; i < 8; i++) begin
			address <= i; 										@(posedge clock);
		end
																	@(posedge clock);
																	@(posedge clock);
		
		$stop;  // pause the simulation
	end
endmodule // task2