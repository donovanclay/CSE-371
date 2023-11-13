module bs_datapath(clk, reset, load_regs, decr, below, above, found, count_zero, read_addr, loc);

    input logic clk, reset, load_regs, decr, below, above, found;
    output logic count_zero;
    output logic [4:0] read_addr, loc;

    logic [2:0] count;
    logic [4:0] addr, addr_below, addr_above;

    assign read_addr = addr;
    assign addr_below = addr - 2 ** (count - 1);
    assign addr_above = addr + 2 ** (count - 1);
    
    always_ff @(posedge clk) begin
        if (load_regs) begin
            addr = 15;
            count = 4;
        end 
        else begin 
            if (decr) count <= count - 1;

            if (below) addr <= addr_below;

            if (above) addr <= addr_above;
        end 
    end

    assign count_zero = count == 0;
    assign loc = (found) ? addr : 5'bZ;
endmodule

`timescale 1ps/1ps
module bs_datapath_tb();
    logic clk, reset, load_regs, decr, below, above, found, count_zero;
    logic [4:0] read_addr, loc;

    logic [7:0] data;

    rom my_rom(read_addr, clk, data);

    bs_datapath dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        load_regs <= 1;                 @(posedge clk);
        {decr, below, above, found} <= 0;   @(posedge clk);
        load_regs <= 0;  below <= 1; decr <= 1;  @(posedge clk);

        for (i = 0; i < 5; i++) begin
                        @(posedge clk);
        end
        $stop;
    end
endmodule 