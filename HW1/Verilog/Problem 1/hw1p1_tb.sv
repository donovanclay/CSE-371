module hw1p1_tb();

	logic clk, reset, x, y, S;
		
	hw1p1 dut (clk, reset, x, y, S);
	
	// Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
	
		reset <= 1; x <= 0; y <= 0; 	@(posedge clk);
		reset <= 0; 						@(posedge clk);
		for (i = 0; i < 4; i++) begin
						{x,y} = i;			@(posedge clk);
		end	
												@(posedge clk);
		
		for (i = 1; i < 4; i++) begin
						{x,y} = i;			@(posedge clk);
		end
						{x,y} = 0;			@(posedge clk);
												@(posedge clk);
		for (i = 1; i < 4; i++) begin
												@(posedge clk);
		end
						
		 $stop;  // pause the simulation
		
	end
			
endmodule // hw1p1_tb