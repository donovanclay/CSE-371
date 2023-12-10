module alien_drawer 
    #(
    parameter ALIEN_WIDTH = 32,
    parameter ALIEN_HEIGHT = 32
    )
    (
    input logic clock, reset,
    input logic [9:0] alien_center_x,
    input logic [8:0] alien_center_y,
    output logic [9:0] out_x,
    output logic [8:0] out_y,
    output logic valid, done
    );

    logic [9:0] input_x, curr_x;
    logic [8:0] input_y, curr_y;
    enum {s_start, s_draw, s_done} ps, ns;

    assign out_x = curr_x;
    assign out_y = curr_y;
    assign valid = (ps == s_draw);
    assign done = (ps == s_done);

    always_comb begin
        case(ps)
            s_start:
                ns = s_draw;

            s_draw: begin
                if (curr_x == input_x + (ALIEN_WIDTH / 2)) begin
                    if (curr_y == input_y + (ALIEN_HEIGHT / 2)) begin
                        ns = s_done;
                    end
                    else
                        ns = s_draw;
                end
                else
                    ns = s_draw;
            end

            s_done:
                ns = s_done;
        endcase
    end

    // outputs
    always_ff @(posedge clock) begin

        if (ps == s_start) begin
            curr_x = alien_center_x - (ALIEN_WIDTH / 2);
            curr_y = alien_center_y - (ALIEN_HEIGHT / 2);
            input_x = alien_center_x;
            input_y = alien_center_y;
        end

        if (ps == s_draw) begin
            if (curr_x == input_x + (ALIEN_WIDTH / 2)) begin
                if (curr_y != input_y + (ALIEN_HEIGHT / 2)) begin
                    curr_y = curr_y + 1;
                    curr_x = input_x - (ALIEN_WIDTH / 2);
                end
            end
            else
                curr_x = curr_x + 1;
        end
    end

    always_ff @(posedge clock) begin
        if (reset)
            ps <= s_start;
        else
            ps <= ns;
    end
endmodule

module alien_drawer_tb ();
    logic clock, reset;
    logic [9:0] alien_center_x;
    logic [8:0] alien_center_y;
    logic [9:0] out_x;
    logic [8:0] out_y;
    logic done, valid;

    alien_drawer dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        reset <= 1'b1;  alien_center_x <= 100; alien_center_y <= 100;     @(posedge clock);
        reset <= 1'b0;       @(posedge clock);
                                    @(posedge clock);

        for (i = 0; i < 32 * 35; i++) begin
                                    @(posedge clock);
        end

        alien_center_x <= 80; alien_center_y <= 80; reset <= 1;   @(posedge clock);
        reset <= 0;                                     @(posedge clock);
        

        for (i = 0; i < 32 * 69; i++) begin
                                    @(posedge clock);
        end

        alien_center_x <= 200; alien_center_y <= 200; reset <= 1;   @(posedge clock);
        reset <= 0;                                     @(posedge clock);

        for (i = 0; i < 32 * 69; i++) begin
                                    @(posedge clock);
        end
        $stop;
    end
endmodule