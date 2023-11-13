module bs_controller(clk, reset, start, count_zero, A, rom_out, done_in, decr, found, load_regs, below, above);

    input logic clk, reset, start, count_zero;
    input logic [7:0] A, rom_out;
    output logic done_in, decr, found, load_regs, below, above;

    enum {s_idle, s_compare, s_done} ps, ns;

    always_comb begin
        case(ps)
            s_idle:
                if (start == 1)
                    ns = s_compare;
                else
                    ns = s_idle;
            s_compare:
                if (A == rom_out || count_zero)
                    ns = s_done;
                else 
                    ns = s_compare;
                    
            s_done: ns = s_idle;
        endcase
    end

    always_ff @(posedge clk) begin
        if(reset)
            ps <= s_idle;
        else
            ps <= ns;
    end

    // moore
    assign decr = (ps == s_compare);
    assign done = (ps == s_done);
    assign found = (ps == s_compare) && (A == rom_out);

    // mealy
    assign load_regs = (ps == s_idle) && (start == 1);
endmodule

module bs_controller_tb();
    logic clk, reset, start, count_zero, done_in, decr, found, load_regs, below, above;
    logic [7:0] A, rom_out;

    bs_controller dut(.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1; A <= 15; rom_out <= 15;   @(posedge clk);
        reset <= 0; start <= 1;    @(posedge clk);

        for (i = 0; i < 5; i++) begin
                            @(posedge clk);
        end
        $stop;
    end

endmodule