module sign_mag_add_tb();
	logic[3:0] a, b, sum, sum2;
	logic [7:0] addr;
	logic clk;
	
	assign addr = {a, b};
	
	sign_mag_add dut1 (a, b, sum);
	
	sync_rom dut2 (clk, addr, sum2);
	
	// Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		a <= 4'b0000;	b <= 4'b0000;	@(posedge clk); // reset
		
		a <= 4'b0010;	b <= 4'b0000;	@(posedge clk); // 2 + 0 = 2
		
		a <= 4'b0011;	b <= 4'b1010;	@(posedge clk);  // 3 + -2 = 1
		
		a <= 4'b0010;	b <= 4'b0010;	@(posedge clk);  // 2 + 2 = 4
		
		a <= 4'b1010;	b <= 4'b1010;	@(posedge clk); // -2 + -2 = -4
		
		a <= 4'b0010;	b <= 4'b1010;	@(posedge clk);  // 2 + -2 = 0
		
		a <= 4'b0010;	b <= 4'b1011;	@(posedge clk);  // 2 + -3 = -1
		
		a <= 4'b0111;	b <= 4'b0111;	@(posedge clk); // 7 + 7 = ???
		
		a <= 4'b1111;	b <= 4'b1111;	@(posedge clk);  // -7 + -7 = ???
		
												@(posedge clk);
		$stop;
	end
endmodule 