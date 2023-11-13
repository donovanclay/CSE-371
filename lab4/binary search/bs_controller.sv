module bs_controller(clk, reset, start, count_zero, A, rom_out, addr, done, decr, found, load_regs, below, above);

    input logic clk, reset, start, count_zero;
    input logic [7:0] A, rom_out;
    input logic [4:0] addr;
    output logic done, decr, found, load_regs, below, above;

    enum {s_idle, s_compare, s_done, s_stall1, s_stall2} ps, ns;

    always_comb begin
        case(ps)
            s_idle:
                if (start == 1)
                    ns = s_stall1;
                else
                    ns = s_idle;
                    
            s_stall1:   ns = s_stall2;

            s_stall2:   ns = s_compare;
                
            s_compare:
                if (A == rom_out || count_zero)
                    ns = s_done;
                else 
                    ns = s_stall1;
                    
            s_done: if (~start) ns = s_idle;
                    else    ns = s_done;
        endcase
    end

    always_ff @(posedge clk) begin
        if(reset)
            ps <= s_idle;
        else
            ps <= ns;
    end

    // mealy outputs
    assign load_regs = (ps == s_idle && start);
    assign below = (ps == s_compare && !count_zero && A < rom_out);
    assign above = (ps == s_compare && !count_zero && A > rom_out);
    assign found = ((ps == s_compare || ps == s_done) && A == rom_out);

    // moore outputs
    assign decr = (ps == s_compare);
    assign done = (ps == s_done);

    
endmodule

module bs_controller_tb();
    logic clk, reset, start, count_zero, done, decr, found, load_regs, below, above;
    logic [7:0] A, rom_out;

    bs_controller dut(.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1; A <= 15;        count_zero <= 0; @(posedge clk);
        reset <= 0; start <= 1;      @(posedge clk);
                    start <= 0;     @(posedge clk);
                                        @(posedge clk);
                                rom_out <= 120; @(posedge clk);
                                rom_out <= 16;      @(posedge clk);
                                rom_out <= 10;      @(posedge clk);
                                rom_out <= 15;      @(posedge clk);
        for (i = 0; i < 5; i++) begin
                            @(posedge clk);
        end
        $stop;
    end

endmodule