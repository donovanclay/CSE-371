module top_level();
	logic[3:0] a, b, sum, sum2;
		logic clk;
		
		sign_mag_add dut (a, b, sum);
		sync_rom dut2 (clk, a, b, sum2);
	
endmodule
	