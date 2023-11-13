module counter_datapath(clk, reset, clear_result, load_a, right_shift, incr_result, done, SW, A, result);
	
	input logic clk, reset, clear_result, load_a, right_shift, incr_result, done;
	input logic [7:0] SW;
	output logic [7:0] A;
	output logic [2:0] result;
	
	logic [2:0] count;
	
	always_ff @(posedge clk) begin
		if(clear_result) begin
			result <= 0;
			count <= 0;
		end
		
		if(load_a) begin
			A <= SW[7:0];
		end 
		
		if(right_shift) begin
			A <= A >> 1;
		end
		
		if(incr_result) begin
			count <= count + 1;
		end
		
		if(done) begin
			result <= count;
		end
	end
	
endmodule





module counter_datapath_tb();


	logic clk, reset, clear_result, load_a, right_shift, incr_result, done;
	logic [7:0] SW;
	logic [7:0] A;
	logic [2:0] result;
	
	counter_datapath dut(.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	
	initial begin
		reset <= 1;	 @(posedge clk);
		reset <= 0;	 @(posedge clk);
		
		clear_result <= 1;	load_a <= 1;	@(posedge clk);
		SW[7:0] <= 8'b11110000;	#200;
		SW[7:0] <= 8'b10101010;	#200;
		clear_result <= 0;	load_a <= 0;	@(posedge clk);
		right_shift <= 1;	@(posedge clk);
		incr_result <= 1;	#300;
		right_shift <= 0;	incr_result <= 0;	@(posedge clk);
		done <= 1;	@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		done <= 0;	@(posedge clk);

		
		$stop;
	end
	
endmodule

