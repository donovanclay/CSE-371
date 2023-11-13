/* Arbitrary ASM chart implementation to examine output timings */
module hw3p3 (clk, reset, X, Ya, Yb, Yc, Z1, Z2);
	input logic clk, reset, X;
	output logic Ya, Yb, Yc, Z1, Z2;
	
	// for you to implement
	enum logic [1:0] {S0, S1, S2} ps, ns;
	
	always_comb
		case (ps)
			S0: 	if (X) ns <= S1;
					else ns <= S0;
			S1:	if (X) ns <= S2;
					else ns <= S0;
			S2:	if (X) ns <= S2;
					else ns <= S0;
		endcase
			
	always_ff @(posedge clk)
		if (reset)
			ps <= S0;
		else
			ps <= ns;
			
	assign Z1 = ps == S2 && X == 0;
	assign Z2 = ps == S2 && X == 1;
	assign Ya = ps == S0;
	assign Yb = ps == S1;
	assign Yc = ps == S2;
	
endmodule  // hw3p3


/* Testbench for Homework 3 Problem 3 */
module hw3p3_testbench ();
	
	// for you to implement
	logic clk, reset, X, Ya, Yb, Yc, Z1, Z2;	
	
	hw3p3 dut (.*);
	
	// define parameters
	parameter T = 20;
	
	// define simulated clock
	initial begin
		clk <= 0;
		forever	#(T/2)	clk <= ~clk;
	end  // initial clock
	
	initial begin
		
		// for you to implement
		reset <= 1;		X <= 0;	@(posedge clk);
		reset <= 0;					@(posedge clk);
							X <= 1;	@(posedge clk);
							X <= 0;	@(posedge clk);
							X <= 1;	@(posedge clk);
							X <= 1;	@(posedge clk);
							X <= 0;  # 4;
							X <= 1;  # 4;
							X <= 0;  # 4;
							X <= 1;	@(posedge clk);
							X <= 0;	@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										
		$stop;
		
	end  // initial
	
endmodule  // hw3p3_testbench
