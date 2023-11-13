module hw1p1 (
	input clk, reset, x, y,
	output S
	);
	
	// Cin and Cout
	logic Q, C;
	
	enum {S0, S1} ps, ns;
	
	always_comb
		// simplified logic for full adder
		case(ps)
			S0: 
				if (x ^ y || {x,y} == 2'b00) ns = S0;
				else ns = S1;
			S1:
				if (x | y) ns = S1;
				else ns = S0;
		endcase
		
	// assign intermediary values
	assign Q = ps;
	assign C = ns;
	
	// simplified logic for full adder
	assign S = (ps == S0) ? (x ^ y) : x ~^ y;
	 
	always_ff @(posedge clk)
		// reset state
		if (reset) ps <= S0;
		
		else	ps <= ns;
		
	
endmodule 