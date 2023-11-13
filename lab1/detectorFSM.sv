/*
 * detectorFSM is the module to detect when cars enter or exit the parking lot. Since it is a
 * FSM it has the clock and a reset signal as input signals. It also has the 1-bit signals outer and inner
 * from the outer and inner sensors of the parking lot. When a car is detected entering or exiting the 
 * parking lot, the output signals enter and exit are asserted, respecively. Pedestrians do not affect
 * the car detector
 */
module detectorFSM(
	input  logic clk, reset, outer, inner,
	output logic enter, exit
	);
	
	logic [2:0] ps, ns;
	logic [1:0] sensors;
	
	assign sensors = {outer, inner};
	
	parameter S0 = 3'b000;
	parameter S1 = 3'b001;
	parameter S2 = 3'b010;
	parameter S3 = 3'b011;
	parameter S4 = 3'b100;
	parameter S5 = 3'b101;
	parameter S6 = 3'b110;
	
	// every case in this switch statement directly corresponds to a 
	// state from the FSM diagram
	// the transitions match the FSM diagram exactly
	always_comb
		case(ps)
			S0: 	
					if (sensors == 2'b10) ns = S1;
					else if (sensors == 2'b01) ns = S4;
					else ns = S0;
			S1: 	if (sensors == 2'b11) ns = S2;
					else if (sensors == 2'b10) ns = S1;
					else ns = S0;
			S2: 	if (sensors == 2'b00) ns = S0;
					else if (sensors == 2'b01) ns = S3;
					else if (sensors == 2'b10) ns = S1;
					else ns = S2;
			S3: 	if (sensors == 2'b00 || sensors == 2'b10) ns = S0;
					else if (sensors == 2'b01) ns = S3;
					else ns = S2;
			S4: 	if (sensors == 2'b00 || sensors == 2'b10) ns = S0;
					else if (sensors == 2'b01) ns = S4;
					else ns = S5;
			S5:	if (sensors == 2'b00) ns = S0;
					else if (sensors == 2'b01) ns = S4;
					else if (sensors == 2'b10) ns = S6;
					else ns = S5;
			S6:	if (sensors == 2'b00 || sensors == 2'b01) ns = S0;
					else if (sensors == 2'b10) ns = S6;
					else ns = S5;
		endcase
			
		// the output logic is directly from the FSM diagram
		assign enter = (ps == S3 && sensors == 2'b00) ? 1'b1 : 1'b0;
		assign exit = (ps == S6 && sensors == 2'b00) ? 1'b1 : 1'b0;
		
	always_ff @(posedge clk)
		if (reset)
			ps <= S0;
		else 
			ps <= ns;
	
endmodule // detectorFSM
	
/*
 * This testbench module tests the detectorFSM module. It thoroughly tests all the valid transitions 
 * of the FSM. 
 */
module detectorFSM_tb();
	logic clk, reset, outer, inner, enter, exit;
	
	detectorFSM dut (clk, reset, outer, inner, enter, exit);
	
	logic [1:0] sensors;
	
	assign outer = sensors[1];
	assign inner = sensors[0];
	
	// Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		reset <= 1; 	sensors<= 2'b00; 	@(posedge clk); // 
		reset <= 0; 	sensors<= 2'b10;	@(posedge clk); // 1 <- start of enter branch tests
													@(posedge clk); // 2
							sensors<= 2'b00;	@(posedge clk); // 3
							sensors<= 2'b10;	@(posedge clk); // 4
							sensors<= 2'b11;	@(posedge clk); // 5
													@(posedge clk); // 6
							sensors<= 2'b10;	@(posedge clk); // 7
							sensors<= 2'b01;	@(posedge clk); // 8
							sensors<= 2'b10;	@(posedge clk); // 9
							sensors<= 2'b11;	@(posedge clk); // 10
							sensors<= 2'b01;	@(posedge clk); // 11
													@(posedge clk); // 12
							sensors<= 2'b11;	@(posedge clk); // 13
							sensors<= 2'b00;	@(posedge clk); // 14
							sensors<= 2'b10;	@(posedge clk); // 15
							sensors<= 2'b11;	@(posedge clk); // 16
							sensors<= 2'b01;	@(posedge clk); // 17
							sensors<= 2'b10; 	@(posedge clk); // 18
							sensors<= 2'b10;	@(posedge clk); // 19
							sensors<= 2'b11;	@(posedge clk); // 20
							sensors<= 2'b01;	@(posedge clk); // 21
							sensors<= 2'b00; 	@(posedge clk); // 22
													@(posedge clk); // 23
							sensors<= 2'b11; 	@(posedge clk); // 24
							sensors<= 2'b01; 	@(posedge clk); // 1 <- start of exit branch tests
													@(posedge clk); // 2
							sensors<= 2'b11; 	@(posedge clk); // 3
													@(posedge clk); // 4
							sensors<= 2'b10;  @(posedge clk); // 5
													@(posedge clk); // 6
							sensors<= 2'b11;  @(posedge clk); // 7
							sensors<= 2'b01;  @(posedge clk); // 8
							sensors<= 2'b00;  @(posedge clk); // 9
							sensors<= 2'b01;  @(posedge clk); // 10
							sensors<= 2'b10;  @(posedge clk); // 11
							sensors<= 2'b01; 	@(posedge clk); // 12
							sensors<= 2'b11; 	@(posedge clk); // 13
							sensors<= 2'b00; 	@(posedge clk); // 14
							sensors<= 2'b01; 	@(posedge clk); // 15
							sensors<= 2'b11; 	@(posedge clk); // 16
							sensors<= 2'b10; 	@(posedge clk); // 17
							sensors<= 2'b01;  @(posedge clk); // 18
							sensors<= 2'b01; 	@(posedge clk); // 19
							sensors<= 2'b11; 	@(posedge clk); // 20
							sensors<= 2'b10; 	@(posedge clk); // 21
							sensors<= 2'b00;  @(posedge clk); // 22
							
							
													@(posedge clk);
		$stop;  // pause the simulation
	end
endmodule // detectorFSM_tb
	
	