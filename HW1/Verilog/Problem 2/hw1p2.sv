module hw1p2 (clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;
	
	logic [2:0] ps, ns;
	
	// update ps and include reset case
	always_ff @(posedge clk, posedge reset)
		if (reset) 	ps <= 3'b000;
		else 			ps <= ns;
		
	always_comb
		// one case for each state in the state diagram
		case (ps)
			3'b000:	if (in == 1'b1) ns = 3'b100;
						else ns = 3'b011;				
			3'b001:	if (in == 1'b1) ns = 3'b100;
						else ns = 3'b001;
			3'b010:	if (in == 1'b1) ns = 3'b000;
						else ns = 3'b010;
			3'b011:	if (in == 1'b1) ns = 3'b010;
						else ns = 3'b001;
			3'b100:	if (in == 1'b1) ns = 3'b011;
						else ns = 3'b010;
		endcase
		
		// unless the present state is 100, the output is the same as the input
		assign out = (ps == 3'b100) ? 0 : in;
		
endmodule
