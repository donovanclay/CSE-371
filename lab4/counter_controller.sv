module counter_controller(clk, reset, s, A, clear_result, load_a, right_shift, incr_result, done);

	input logic clk, reset, s;
	input logic [7:0] A;
	output logic clear_result, load_a, right_shift, incr_result, done;
	
	enum {S1, S2, S3} ps, ns;
	
	always_comb begin
		case(ps)
			S1:	if(s == 1)	ns = S2;
					else			ns = S1;
					
			S2:	if(A == 0)	ns = S3;
					else			ns = S2;
					
			S3:	if(s == 0)	ns = S1;
					else			ns = S3;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if(reset) 	ps <= S1;
		else			ps <= ns;
	end
	
	assign clear_result = (ps == S1);
	assign load_a = (ps == S1) && (s == 0);
	assign right_shift = (ps == S2);
	assign incr_result = (ps == S2) && (A[0] == 1);
	assign done = (ps == S3);
	
	
	
endmodule


module counter_controller_tb();


	logic clk, reset, s, clear_result, load_a, right_shift, incr_result, done;
	logic [7:0] A;
	
	counter_controller dut(.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	
	initial begin
		reset <= 1;	 @(posedge clk);
		reset <= 0;	s <= 0;	 @(posedge clk);
		
		A <= 8'b10101010;	@(posedge clk);
		s <= 1;	#300;
		A <= 8'b00000000;	@(posedge clk);
		#100;
		s <= 0;	@(posedge clk);
		
		$stop;
	end
	
endmodule
