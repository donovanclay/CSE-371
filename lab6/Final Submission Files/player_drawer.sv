module player_drawer 
    #(
    parameter START_X = 320,
    parameter START_Y = 454,
    parameter PLAYER_WIDTH = 32,
    parameter PLAYER_HEIGHT = 32
    )
    (
    input logic clock, global_reset, reset,
    input logic [9:0] player_x,
    input logic [8:0] player_y,
    output logic [9:0] out_x,
    output logic [8:0] out_y,
    output logic [3:0] which_color,
    output logic done
    );
    
    parameter background_color = 0;
    parameter player_color = 1;
    parameter laser_color = 2;
    parameter enemy_color = 3;

    logic [9:0] input_x, curr_x, prev_x;
    logic [8:0] input_y, curr_y, prev_y;
    logic erase;
    enum {s_global_reset, s_start, s_draw, s_done, s_last_pixel} ps, ns;

    assign out_x = (!done) ? curr_x : 10'bZ;
    assign out_y = (!done) ? curr_y : 9'bZ;
    assign which_color = (erase) ? background_color : player_color;
    // assign which_color = player_color;
    assign done = (ps == s_done);

    always_comb begin
        case(ps)
            s_global_reset:
                ns = s_draw;

            s_draw: begin
                if (curr_x != input_x + (PLAYER_WIDTH / 2))
                    ns = s_draw;
                else if (curr_y + 1 == input_y + (PLAYER_HEIGHT / 2) && !erase && curr_x == input_x + (PLAYER_WIDTH / 2)) begin
                    if (erase)
                        ns = s_last_pixel;
                    else
                        ns = s_done;
                end
                else 
                    ns = s_draw;
            end

            s_last_pixel:
                ns = s_done;
            
            s_start: begin
                if (prev_x == player_x && prev_y == player_y)
                    ns = s_done;
                else
                    ns = s_draw;
            end

            s_done:
                ns = s_done;
        endcase
    end


    // outputs
    always_ff @(posedge clock) begin
        if (ps == s_global_reset) begin
            input_x = START_X;
            input_y = START_Y;
            curr_x = START_X - (PLAYER_WIDTH / 2);
            curr_y = START_Y - (PLAYER_HEIGHT / 2);
            prev_x = START_X;
            prev_y = START_Y;
            erase = 0;
        end

        if (ps == s_draw) begin
            if ((!erase && curr_x < input_x + (PLAYER_WIDTH / 2)) ||
                (erase && curr_x < prev_x + (PLAYER_WIDTH / 2))) begin
                curr_x = curr_x + 1;
                erase = erase;
            end else if ((!erase && curr_y <= input_y + (PLAYER_HEIGHT / 2)) ||
                     (erase && curr_y < prev_y + (PLAYER_HEIGHT / 2) - 1)) begin
                curr_x = (erase) ? prev_x - (PLAYER_WIDTH / 2) : input_x - (PLAYER_WIDTH / 2);
                curr_y = (ns == s_draw) ? curr_y + 1 : input_y - (PLAYER_HEIGHT / 2);
                erase = erase;
            end else if (erase) begin
                curr_x = input_x - (PLAYER_WIDTH / 2);
                curr_y = input_y - (PLAYER_HEIGHT / 2);
                erase = 0;
                prev_x = input_x;
                prev_y = input_y;
            end else begin
                curr_x = input_x - (PLAYER_WIDTH / 2);
                curr_y = input_y - (PLAYER_HEIGHT / 2);
            end
        end

        if (ps == s_start) begin
            input_x = player_x;
            input_y = player_y;
            if (prev_x == player_x && prev_y == player_y) begin
                curr_x = player_x;
                curr_y = player_y;
                erase = 0;
            end else begin
                erase = 1;
                curr_x = prev_x - (PLAYER_WIDTH / 2);
                curr_y = prev_y - (PLAYER_HEIGHT / 2);
            end
        end
    end

    always_ff @(posedge clock) begin
        if (global_reset)
            ps <= s_global_reset;
        else if (reset)
            ps <= s_start;
        else
            ps <= ns;
    end
endmodule

module player_drawer_tb ();
    logic clock, global_reset, reset;
    logic [9:0] player_x;
    logic [8:0] player_y;
    logic [9:0] out_x;
    logic [8:0] out_y;
    logic [3:0] which_color;
    logic done;

    player_drawer dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        global_reset <= 1'b1;       @(posedge clock);
        global_reset <= 1'b0;       @(posedge clock);
                                    @(posedge clock);

        for (i = 0; i < 32 * 35; i++) begin
                                    @(posedge clock);
        end

        player_x <= 100; player_y <= 100; reset <= 1;   @(posedge clock);
        reset <= 0;                                     @(posedge clock);
        

        for (i = 0; i < 32 * 69; i++) begin
                                    @(posedge clock);
        end

        player_x <= 200; player_y <= 200; reset <= 1;   @(posedge clock);
        reset <= 0;                                     @(posedge clock);

        for (i = 0; i < 32 * 69; i++) begin
                                    @(posedge clock);
        end
        $stop;
    end
endmodule