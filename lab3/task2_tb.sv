`timescale 1ps/1ps
module task2_tb ();
	logic clk, reset, read;
    logic [15:0] addr;
	logic [23:0] Romout;
	
	addr_counter count1 (clk, reset, read, addr);
	
	note_rom my_note_rom (addr, clk, Romout);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
	
		// for you to implement
		read <= 0; reset <= 1;  @(posedge clk);
        reset <= 0;  @(posedge clk)

        for (i = 0; i < 5; i++) begin
			                @(posedge clk);
		end

        read <= 1;

        for (i = 0; i < 14; i++) begin
			                @(posedge clk);
		end

		$stop;
	end  // initial

endmodule 