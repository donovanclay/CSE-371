/* Register file module for specified data and address bus widths.
 * Asynchronous read port (r_addr -> r_data) and synchronous write
 * port (w_data -> w_addr if w_en).
 */
module reg_file #(parameter WRITE_WIDTH=16, DATA_WIDTH=8, ADDR_WIDTH=2)
                (clk, w_data, w_en, w_addr, r_addr, r_data);

	input  logic clk, w_en;
	input  logic [ADDR_WIDTH-1:0] w_addr, r_addr;
	input  logic [WRITE_WIDTH-1:0] w_data;
	output logic [DATA_WIDTH-1:0] r_data;
	
	// array declaration (registers)
	logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];
	
	// write operation (synchronous)
	always_ff @(posedge clk)
	   if (w_en) begin
		
			// write the 16 bit data to two of the registers
		   array_reg[w_addr] = w_data[WRITE_WIDTH:WRITE_WIDTH/2];
			array_reg[w_addr+1] = w_data[(WRITE_WIDTH/2)-1:0];
			end
	
	// read operation (asynchronous)
	assign r_data = array_reg[r_addr];
	
endmodule  // reg_file

module reg_file_tb();

	parameter WRITE_WIDTH=16;
	parameter DATA_WIDTH=8;
	parameter ADDR_WIDTH=2;

	logic clk, w_en;
	logic [ADDR_WIDTH-1:0] w_addr, r_addr;
	logic [WRITE_WIDTH-1:0] w_data;
	logic [DATA_WIDTH-1:0] r_data;
	
	reg_file dut (clk, w_data, w_en, w_addr, r_addr, r_data);
	
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		{w_data, w_en, w_addr, r_addr} <= 0;					@(posedge clk); 
		w_data <= {{8{1'b1}}, {8{1'b0}}}; w_en <= 1; 		@(posedge clk);
																			@(posedge clk);
																			@(posedge clk);

		$stop;
	end

endmodule 