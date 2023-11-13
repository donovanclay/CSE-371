	/* Top-level module for LandsLand hardware connections to implement the parking lot system.*/

module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, V_GPIO);

	input  logic		 CLOCK_50;	// 50MHz clock
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// active low
	output logic [9:0] LEDR;
	inout  logic [35:0] V_GPIO;	// expansion header 0 (LabsLand board)

	logic reset, outer, inner, enter, exit;
	
	// setup GPIO ports
	assign reset = V_GPIO[24];
	assign outer = V_GPIO[28];
	assign inner = V_GPIO[30];
	assign V_GPIO[33] = outer;
	assign V_GPIO[35] = inner;
	
	// car detector module
	detectorFSM detector (.clk(CLOCK_50), .reset(reset), .outer(outer), .inner(inner), .enter(enter), .exit(exit));
	
	logic [4:0] count;
	
	// car counter module
	car_counter counter (.clk(CLOCK_50), .reset(reset), .incr(enter), .decr(exit), .count(count));
	
	// seg7 display module
	seg7 seg7_0 (count, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
endmodule // DE1_SoC

/* 
 * This testbench module tests the DE1_SoC module.
 */
module DE1_SoC_tb();

	// define signals
	logic	CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	wire [35:0] V_GPIO;
	
	// additional logic required to simulate inout pins
   logic [35:0] V_GPIO_in;
   logic [35:0] V_GPIO_dir;  // 1 = input, 0 = output

   // set up tristate buffers for inout pins
   genvar i;
   generate
      for (i = 0; i < 36; i++) begin : gpio
         assign V_GPIO[i] = V_GPIO_dir[i] ? V_GPIO_in[i] : 1'bZ;
      end
   endgenerate
	
	logic reset, outer, inner, outer_led, inner_led;
	
	assign V_GPIO_in[24] = reset;
	assign V_GPIO_in[28] = outer;
	assign V_GPIO_in[30] = inner;
	assign outer_led = V_GPIO[33];
	assign inner_led = V_GPIO[35];
	
	// instantiate module
	DE1_SoC dut (.*);
	
	// define parameters
	parameter T = 20;
	
	// define simulated clock
	initial begin
		CLOCK_50 <= 0;
		forever	#(T/2)	CLOCK_50 <= ~CLOCK_50;
	end  // initial clock
	
	
	initial begin
		V_GPIO_dir[24] <= 1'b1;
		V_GPIO_dir[28] <= 1'b1;
		V_GPIO_dir[30] <= 1'b1;
		V_GPIO_dir[33] <= 1'b0;
		V_GPIO_dir[35] <= 1'b0;					@(posedge CLOCK_50);
		reset <= 1;	outer <= 0; inner <= 0; @(posedge CLOCK_50);
		reset <= 0;	outer <= 1; 				@(posedge CLOCK_50);
														@(posedge CLOCK_50);
														@(posedge CLOCK_50);
										inner <= 1; @(posedge CLOCK_50);
						outer <= 0; 				@(posedge CLOCK_50);
										inner <= 0; @(posedge CLOCK_50);
														@(posedge CLOCK_50);
														@(posedge CLOCK_50);
														@(posedge CLOCK_50);
		$stop;  // pause the simulation
	end
endmodule // DE1_SoC_tb
