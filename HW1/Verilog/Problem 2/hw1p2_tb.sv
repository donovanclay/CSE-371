module hw1p2_tb();

	logic clk, reset, in, out;
		
	hw1p2 dut (clk, reset, in, out);
	
	// Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
	
		reset <= 1; in <= 0; 	@(posedge clk);
		reset <= 0; in <= 0; 	@(posedge clk);
										@(posedge clk);
						in <= 1; 	@(posedge clk);
										@(posedge clk);
										@(posedge clk);
						in <= 0; 	@(posedge clk);
										@(posedge clk);
						in <= 1;		@(posedge clk);
										@(posedge clk);
						in <= 0; 	@(posedge clk);
										@(posedge clk);
		 $stop;  // pause the simulation
		
	end
			
endmodule