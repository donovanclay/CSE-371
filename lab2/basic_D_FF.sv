module basic_D_FF(q, d, clock);
	output logic q;
	input logic d, clock;
	
	
	always_ff @(posedge clock)
		q <= d;
		
endmodule 	