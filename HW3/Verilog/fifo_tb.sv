/* Testbench for Homework 3 Problem 1 */
module fifo_tb ();

	// for you to implement
	parameter WRITE_WIDTH=16;
	parameter DATA_WIDTH=8;
	parameter ADDR_WIDTH=4;
	
	logic clk, reset, rd, wr;
	logic empty, full;
	logic [WRITE_WIDTH-1:0] w_data;
	logic [DATA_WIDTH-1:0] r_data;
	
	fifo dut (clk, reset, rd, wr, empty, full, w_data, r_data);
	
	logic [7:0] w_dataMSB, w_dataLSB;
	
	assign w_data = {w_dataMSB, w_dataLSB};
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
	
		// for you to implement
		{rd, wr, w_dataMSB, w_dataLSB} <= 0;	reset <= 1;		@(posedge clk); 
										reset <= 0;		@(posedge clk);
		wr <= 1;		
		for (i = 1; i < 1024; i*= 2) begin
			w_dataMSB = i;	w_dataLSB = i/2;			@(posedge clk);
		end
		wr <= 0;	rd <= 1;
	
		for (i = 0; i < 19; i++) begin
															@(posedge clk);
		end
		
		$stop;
		
		
	end  // initial
	
endmodule  // fifo_tb
