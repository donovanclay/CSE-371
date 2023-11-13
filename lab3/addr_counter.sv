module addr_counter(
	input logic clock, reset, enable,
	output logic [15:0] addr);
	
	logic [15:0] address;
	
	always_ff @(posedge clock)
		if (reset) address <= 0;
		
		else if (enable) begin
			if (address == 47000) 
				address <= 1;
			else address <= address + 1;
		end
		
	assign addr = address;
	
endmodule 