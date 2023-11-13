module FIR_filter #(parameter N) (
	input logic CLOCK_50, reset, enable,
	input logic [23:0] Datain,
	output logic [23:0] Dataout
	);
	
	logic empty, full;
	logic [23:0] Fifo_in, Fifo_out;
	
	assign Fifo_in = {{$clog2(N){Datain[23]}}, Datain[23:$clog2(N)]};
	
	logic read, write;
	assign read = full && enable;
	assign write = enable;

	fifo #(24, 24, $clog2(N)) my_fifo(CLOCK_50, reset, read, write, empty, full, Fifo_in, Fifo_out);
	
	logic [23:0] neg_sum;
	logic [23:0] neg_Fifo_out;
	assign neg_Fifo_out = (-1 * Fifo_out);
	
	assign neg_sum = Fifo_in + neg_Fifo_out;
	
	logic [23:0] accumulated;

	assign Dataout = accumulated + neg_sum;
	
	always_ff @(posedge CLOCK_50) begin
		if (reset)
			accumulated <= 0;
		else if (full && enable)
			accumulated <= Dataout;
		else if (enable)
			accumulated <= accumulated + Fifo_in;
		else
			accumulated <= accumulated;
	end
	
endmodule // FIR_filter


module FIR_filter_tb ();
	logic clk, reset, enable;
	logic [23:0] Datain;
	logic [23:0] Dataout;
	
	FIR_filter #(8) dut (clk, reset, enable, Datain, Dataout);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
	
		// for you to implement
		Datain <= 0;	reset <= 1;			@(posedge clk); 
			enable <= 1;	Datain <= 500;	reset <= 0;		@(posedge clk);
//								rd <=1; 	
		for (i = 0; i < 5; i++) begin
			Datain <= 1000; @(posedge clk);
			Datain <= 500; @(posedge clk);
		end
		// enable <= 0;

		// for (i = 0; i < 15; i++) begin
		// 	Datain <= 1000; @(posedge clk);
		// 	Datain <= 500; @(posedge clk);
		// end
		// enable <= 1;
		// for (i = 0; i < 32; i++) begin
		// 	Datain <= 1000; @(posedge clk);
		// 	Datain <= 500; @(posedge clk);
		// end
		$stop;
	end  // initial

endmodule 