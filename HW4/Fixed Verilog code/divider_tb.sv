module divider_tb();
	logic Clock, Resetn, s, LA, EB, Done;
	logic [7:0] DataA, DataB, R, Q;
	
	divider dut(.*);
	
	parameter CLOCK_PERIOD = 1000;
	integer i;
	initial begin
		Clock <= 0;
		for(i = 0; i < 250; i++) begin
			#(CLOCK_PERIOD/2) Clock <= ~Clock;
		end
	end
	
	initial begin
		DataA <= 8'b01110000;
		DataB <= 8'b00001010;
		Resetn <= 0; repeat(2) @(posedge Clock);
		
		Resetn <= 1;
		LA <= 1;
		EB <= 1; 
		s <= 0; repeat(2) @(posedge Clock);
		LA <= 0;
		EB <= 0; 
		s <= 1; repeat(20) @(posedge Clock);
		
		
		DataA <= 8'b00001101;
		DataB <= 8'b00000010;
		s <= 0; repeat(2) @(posedge Clock);
		LA <= 1;
		EB <= 1;
		s <= 0; repeat(2) @(posedge Clock);
		LA <= 0;
		EB <= 0;
		s <= 1; repeat(10) @(posedge Clock);
		
		$stop;
	end
endmodule
