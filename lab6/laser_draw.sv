module laser_draw #(
    parameter LASER_WIDTH = 5,
    parameter LASER_LENGTH = 10, 
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21
) (
    input logic clock, laser_alive, laser_draw_start, laser_draw_reset,
    input logic [9:0] laser_x,
    input logic [8:0] laser_y,
    output logic [9:0] out_x,
    output logic [8:0] out_y,
    output logic done
);
    logic [9:0] input_x, curr_x, prev_x;
    logic [8:0] input_y, curr_y, prev_y;
    logic erase;

    enum {s_start, s_draw, s_draw_reset, s_done} ps, ns;

    assign done = (ps == s_done);

    always_comb begin
        case (ps)
            s_start:
                ns = s_draw;

            s_draw: begin
                if ((!erase && curr_x == input_x + (LASER_WIDTH / 2)) ||
                    (erase && curr_x == prev_x + (LASER_WIDTH / 2))) begin
                    
                    if ((!erase && curr_y == input_y + (LASER_LENGTH)) ||
                        (erase && curr_y == prev_y + (LASER_LENGTH))) begin
                        
                        if (!erase || !laser_alive)
                            ns = s_done;
                        else
                            ns = s_draw;
                    end
                    else
                        ns = s_draw;
                end
                else
                            ns = s_draw;
            end

            s_draw_reset: begin
                if (prev_x == laser_x && prev_y == laser_y)
                    ns = s_done;
                else
                    ns = s_draw;
            end

            s_done:
                ns = s_done;

        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == s_start) begin
            input_x = laser_x;
            input_y = laser_y;
            curr_x = laser_x - LASER_WIDTH / 2;
            curr_y = laser_y;
            prev_x = laser_x;
            prev_y = laser_y;
            erase = 0;
        end

        if (ps == s_draw) begin
            out_x = curr_x;
            out_y = curr_y;

            if ((!erase && curr_x == input_x + (LASER_WIDTH / 2)) ||
                (erase && curr_x == prev_x + (LASER_WIDTH / 2))) begin
                
                if ((!erase && curr_y == input_y + (LASER_LENGTH)) ||
                    (erase && curr_y == prev_y + (LASER_LENGTH))) begin
                    
                    if (erase) begin
                        if (laser_alive) begin
                            curr_x = input_x - LASER_WIDTH / 2;
                            curr_y = input_y;
                            prev_x = input_x;
                            prev_y = input_y;
                            erase = 0;
                        end
                    end
                end
                else begin
                    curr_x = (erase) ? prev_x - LASER_WIDTH / 2 : input_x - LASER_WIDTH / 2;
                    curr_y = curr_y + 1;
                end
            end
            else
                curr_x = curr_x + 1;
        end

        if (ps == s_draw_reset) begin
            input_x = laser_x;
            input_y = laser_y;

            if (prev_x != laser_x || prev_y != laser_y) begin
                erase = 1;
                curr_x = prev_x - LASER_WIDTH / 2;
                curr_y = prev_y;
            end
        end
    end

    always_ff @(posedge clock) begin
        if (laser_draw_start && laser_alive)
            ps = s_start;
        else if (laser_draw_reset)
            ps = s_draw_reset;
        else
            ps = ns;
    end

endmodule  // laser_draw

module laser_draw_tb ();
    logic clock, laser_alive, laser_draw_start, laser_draw_reset;
    logic [9:0] laser_x;
    logic [8:0] laser_y;
    logic [9:0] out_x;
    logic [8:0] out_y;
    logic done;

    laser_draw dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        laser_alive <= 1; laser_draw_start <= 1; laser_x <= 100; laser_y <= 300;        @(posedge clock);
        laser_draw_start <= 0; @(posedge clock);
        for (i = 0; i < 5 * 13; i++) begin
            @(posedge clock);
        end
        $stop;
    end
endmodule

