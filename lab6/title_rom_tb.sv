`timescale 1ps/1ps
module title_rom_tb ();

    logic clock;
    logic [18:0] address;
    logic [3:0] q;

    title_text_rom dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        address <= 18594; @(posedge clock);
        address <= 18595; @(posedge clock);
        address <= 18593; @(posedge clock);
        address <= 3; @(posedge clock);
        address <= 4; @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        $stop;
    end
endmodule

