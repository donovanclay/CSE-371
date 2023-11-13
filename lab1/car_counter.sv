/*
 * car_counter is the module for counting the current number of cars in the parking lot.
 * Since it is a FSM, it has the clock and reset as input signals. It also has 1-bit 
 * input signals incr and decr to know when to increment and decrement the count.
 * The count never exceeds 16 and is always non-negative.
 */
module car_counter(
	input logic clk, reset, incr, decr,
	output logic [4:0] count
	);
	
	// 5 bits wide because max count is 16
	logic [4:0] ps;
	
	// this block updates the count
	always_ff @(posedge clk)
		// reset state
		if (reset) ps <= 5'b0;
		
		/*
		 *  if both incr and decr are asserted 
		 *  or incr is asserted and the count is at the max 
		 *  or decr is asserted and the count is 0
		 *  don't change the count
		 */
		else if ((incr && decr) || (incr && ps == 16) || (decr && ps == 0)) 		ps <= ps;
		
		// increment the count
		else if (incr) 				ps <= ps + 1;
		
		// decrement the count
		else if (decr) 				ps <= ps-1;
		
		// no signals received so dont change the count
		else 								ps <= ps;
		
	assign count = ps;
	
endmodule // car_counter
	
/*
 * This testbench module tests the car_counter module. It ensures the counter counts until 16
 * and stays at 16 even when incr is asserted. It also checks that the counter decrements
 * when decr is asserted. It ensures that count stays at 0 even when decr is asserted.
 */
module car_counter_tb();
	logic clk, reset, incr, decr;
	logic [4:0] count;
	
	car_counter dut(clk, reset, incr, decr, count);
	
	// Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		reset <= 1; 	incr <= 1'b0; 	decr <= 1'b0; 	@(posedge clk);
		reset <= 0; 	incr <= 1'b1; 	decr <= 1'b0; 
		
		// test the increment and incrementing when count is 16
		for (i = 0; i <9; i++) begin
																	@(posedge clk);
		end
							incr <= 1'b0;						@(posedge clk);
		for (i = 0; i <4; i++) begin
																	@(posedge clk);
		end
		for (i = 9; i <19; i++) begin
							incr <= 1'b1;						@(posedge clk);
		end
							incr <= 1'b0;	decr <= 1'b1; 				
		// test the decrement and decrementing when count is 0
		for (i = 0; i <16; i++) begin
																	@(posedge clk);
		end
																	@(posedge clk);
																	@(posedge clk);
																	@(posedge clk);
		$stop;  // pause the simulation
	end
	
	
endmodule // car_counter_tb