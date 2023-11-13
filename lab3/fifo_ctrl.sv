/* FIFO controller to manage a register file as a circular queue.
 * Manipulates output read and write addresses based on 1-bit
 * read (rd) and write (wr) requests and current buffer status
 * signals empty and full.
 */
module fifo_ctrl #(parameter ADDR_WIDTH=4)
                 (clk, reset, rd, wr, empty, full, w_addr, r_addr);
	
	input  logic clk, reset, rd, wr;
	output logic empty, full;
	output logic [ADDR_WIDTH-1:0] w_addr, r_addr;
	
	// signal declarations
	logic [ADDR_WIDTH-1:0] rd_ptr, rd_ptr_next;
	logic [ADDR_WIDTH-1:0] wr_ptr, wr_ptr_next;
	logic empty_next, full_next;
	
	// output assignments
	assign w_addr = wr_ptr;
	assign r_addr = rd_ptr;
	
	// fifo controller logic
	always_ff @(posedge clk) begin
		if (reset)
			begin
				wr_ptr <= 0;
				rd_ptr <= 0;
				full   <= 0;
				empty  <= 1;
			end
		else
			begin
				wr_ptr <= wr_ptr_next;
				rd_ptr <= rd_ptr_next;
				full   <= full_next;
				empty  <= empty_next;
			end
	end  // always_ff
	
	// next state logic
	always_comb begin
		// default to keeping the current values
		rd_ptr_next = rd_ptr;
		wr_ptr_next = wr_ptr;
		empty_next = empty;
		full_next = full;
		case ({rd, wr})
			2'b11:  // read and write
				begin
					rd_ptr_next = rd_ptr + 1;
					wr_ptr_next = wr_ptr + 1;
					
					// if there is one available register in the buffer, 
					// we will not allow the user to write to the buffer
					if (wr_ptr_next == rd_ptr)
						full_next = 1;
				end
			2'b10:  // read
				if (~empty)
					begin
						rd_ptr_next = rd_ptr + 1'b1;
						if (rd_ptr_next == wr_ptr)
							empty_next = 1;
						full_next = 0;
					end
			2'b01:  // write
				if (~full)
					begin
						wr_ptr_next = wr_ptr + 1;
						empty_next = 0;
						
						// if there is one available register in the buffer, 
						// we will not allow the user to write to the buffer
						if (wr_ptr_next == rd_ptr)
							full_next = 1;
					end
			2'b00: ; // no change
		endcase
	end  // always_comb
	
endmodule  // fifo_ctrl

module fifo_ctrl_tb();

	parameter ADDR_WIDTH=4;
	
	logic clk, reset, rd, wr;
	logic empty, full;
	logic [ADDR_WIDTH-1:0] w_addr, r_addr;
	
	fifo_ctrl dut (clk, reset, rd, wr, empty, full, w_addr, r_addr);	
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		{rd, wr} <= 0;	reset <= 1;		@(posedge clk); 
		wr <= 1;			reset <= 0; 	@(posedge clk);
												@(posedge clk);
												@(posedge clk);
		wr <= 0; rd <= 1;					@(posedge clk);
		
		for (i = 0; i < 4; i++) begin
			@(posedge clk);
		end 
		wr <= 1; rd <= 0;					@(posedge clk);
		
		for (i = 0; i < 8; i++) begin
			@(posedge clk);
		end 
		wr <= 0; rd <= 1;					@(posedge clk);
		wr <= 1; rd <= 0;					@(posedge clk);
		for (i = 0; i < 8; i++) begin
			@(posedge clk);
		end 
		wr <= 0; rd <= 1;					@(posedge clk);
		for (i = 0; i < 18; i++) begin
			@(posedge clk);
		end 

		$stop;
	end
	
endmodule 

