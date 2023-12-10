`timescale 1ps/1ps
module aliens_alive_ram_tb ();
    logic clock, enable;
    logic [4:0] which_alien;
    logic alive_in, alive_out;

    aliens_alive_ram dut (
        .address(which_alien),
        .clock(clock),
        .data(alive_in),
        .wren(enable),
        .q(alive_out)
    );

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i, j;
    initial begin
        which_alien <= 0; enable <= 0;
        for (i = 0; i < 20; i++) begin
            which_alien <= i;       @(posedge clock);
        end
        
        which_alien <= 0; alive_in <= 0; enable <= 1;  @(posedge clock);
        enable <= 0; which_alien <= 2; @(posedge clock);
        which_alien <= 0; @(posedge clock);
        $stop;
    end

endmodule