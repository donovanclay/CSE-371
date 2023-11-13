module bs_datapath(clk, reset, load_regs, decr, below, above, found, done_in, count_zero, done_out, loc, rom_out);

    input logic clk, load_regs, decr, below, above, found, done_in;
    output logic count_zero, done_out;
    output logic [4:0] loc;
    output logic [7:0] rom_out;

    logic [4:0] read_addr;
    logic [1:0] count;

    always_ff @(posedge clk) begin
        if (reset) begin
            count_zero <= 0;
            done_out <= 0;
            loc <= 5'bZ;
            rom_out <= 7'bZ;
        end
        
        else begin

            // outputs
            count_zero = (count == 0);
            loc = (found) ? read_addr : 5'bZ;
            done_out = done_in;


            // inputs
            if (load_regs) begin
                read_addr <= 15;
                count <= 3;
            end 

            if (decr) begin
                count <= count - 1;
            end

            if (below) begin
                count <= count - 2 ** count;
            end

            if (above) begin
                count <= count + 2 ** count;
            end

            if (found) begin
                loc <= read_addr;
            end 
            else loc <= 5'bZ;

        end
	end
	
endmodule