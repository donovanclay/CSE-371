`define ALIEN_X(WHICH_ALIEN) \
    group_x + (((WHICH_ALIEN % 5) - 2) * (ALIEN_WIDTH + ALIEN_GAP))
`define ALIEN_Y(WHICH_ALIEN) \
    group_y - (3 * (ALIEN_GAP / 2) + ALIEN_HEIGHT / 2) + ((WHICH_ALIEN / 5) * (ALIEN_HEIGHT + ALIEN_GAP))

`define ERASE_ALIEN_X(WHICH_ALIEN) \
    prev_group_x + (((WHICH_ALIEN % 5) - 2) * (ALIEN_WIDTH + ALIEN_GAP))
`define ERASE_ALIEN_Y(WHICH_ALIEN) \
    prev_group_y - (3 * (ALIEN_GAP / 2) + ALIEN_HEIGHT / 2) + ((WHICH_ALIEN / 5) * (ALIEN_HEIGHT + ALIEN_GAP))

`define ALIEN_START_X(WHICH_ALIEN) \
    ALIEN_GROUP_START_X + (((WHICH_ALIEN % 5) - 2) * (ALIEN_WIDTH + ALIEN_GAP))
`define ALIEN_START_Y(WHICH_ALIEN) \
    ALIEN_GROUP_START_Y - (3 * (ALIEN_GAP / 2) + ALIEN_HEIGHT / 2) + ((WHICH_ALIEN / 5) * (ALIEN_HEIGHT + ALIEN_GAP))

module alien_group_drawer 
    #(
    parameter NUM_ALIENS = 20,
    parameter ALIEN_GROUP_START_X = 320,
    parameter ALIEN_GROUP_START_Y = 105,
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21,
    parameter ALIEN_GAP = 21,
    parameter BACKGROUND_COLOR_NUM = 0,
    parameter ENEMY_COLOR_NUM = 3
    )
    (
    input logic clock, global_reset, reset, alien_alive, alien_draw_done,
    input logic [9:0] input_group_x,
    input logic [8:0] input_group_y,
    output logic [9:0] out_center_x,
    output logic [8:0] out_center_y,
    output logic [3:0] color, 
    output logic [4:0] out_which_alien,
    output logic done, alien_draw_reset
    );

    logic [9:0] group_x, prev_group_x, center_x, curr_center_x;
    logic [8:0] group_y, prev_group_y, center_y, curr_center_y;
    logic erase;
    logic [4:0] which_alien;
    logic [4:0] test_case;

    enum {s_global_reset, s_draw_alien, s_is_alive, s_done, s_start} ps, ns;

    assign out_which_alien = which_alien;
    assign out_center_x = (ps == s_done) ? 10'bZ : center_x;
    assign out_center_y = (ps == s_done) ? 9'bZ : center_y;
    assign color = (erase) ? BACKGROUND_COLOR_NUM : ENEMY_COLOR_NUM;
    

    always_comb begin
        case (ps)
            s_global_reset:
                ns = s_draw_alien;

            s_draw_alien: begin
                if (alien_draw_done) begin
                    if (which_alien == 19) begin
                        if (erase)
                            ns = s_is_alive;
                        else
                            ns = s_done;
                    end
                    else 
                        ns = s_is_alive;
                end
                else
                    ns = s_draw_alien;
            end

            s_is_alive: begin
                if (alien_alive)
                    ns = s_draw_alien;
                else if (which_alien == 19) begin
                    if (erase)
                        ns = s_is_alive;
                    else
                        ns = s_done;
                end
                else
                    ns = s_is_alive;
            end
                    

            s_start: begin
                if (prev_group_x == input_group_x &&
                    prev_group_y == input_group_y)
                    ns = s_done;
                else
                    ns = s_is_alive;
            end

            s_done:
                ns = s_done;

        endcase
    end

    // moore outputs
    always_ff @(posedge clock) begin
        if (ps == s_global_reset) begin
            which_alien = 0;
            group_x = ALIEN_GROUP_START_X;
            group_y = ALIEN_GROUP_START_Y;
            prev_group_x = ALIEN_GROUP_START_X;
            prev_group_y = ALIEN_GROUP_START_Y;
            curr_center_x = `ALIEN_START_X(0);
            curr_center_y = `ALIEN_START_Y(0);
            erase = 0;
            alien_draw_reset = 1;
        end

        if (ps == s_draw_alien) begin
            alien_draw_reset = 0;
            center_x = curr_center_x;
            center_y = curr_center_y;
        end

        if (ps == s_start) begin
            group_x = input_group_x;
            group_y = input_group_y;
        end

        if (ps == s_draw_alien) begin
            if (alien_draw_done) begin
                if (which_alien == 19) begin
                    if (erase) begin
                        erase = 0;
                        which_alien = 0;
                        group_x = input_group_x;
                        group_y = input_group_y;
                        prev_group_x = input_group_x;
                        prev_group_y = input_group_y;
                    end
                end else
                    which_alien = which_alien + 1;
            end
        end 

        if (ns == s_is_alive) begin
            alien_draw_reset = 1;
        end

        if (ps == s_is_alive) begin
            if (alien_alive) begin
                curr_center_x = (erase) ? `ERASE_ALIEN_X(which_alien) : `ALIEN_X(which_alien);
                curr_center_y = (erase) ? `ERASE_ALIEN_Y(which_alien) : `ALIEN_Y(which_alien);
                // alien_draw_reset = 1;
                test_case = 1;
            end 
            else begin
                if (which_alien == 19) begin
                    if (erase) begin
                        erase = 0;
                        which_alien = 0;
                        group_x = input_group_x;
                        group_y = input_group_y;
                        prev_group_x = input_group_x;
                        prev_group_y = input_group_y;
                    end
                    test_case = 2;
                end else
                    which_alien = which_alien + 1;
                    test_case = 3;
            end
        end

        if (ps == s_start) begin
            if (!(prev_group_x == input_group_x && prev_group_y == input_group_y)) begin
                erase = 1;
                which_alien = 0;
            end
        end
    end

    assign done = (ps == s_done);

    // mealy outputs
    // always_ff @(posedge clock) begin
    //     if (ps == s_draw_alien) begin
    //         if (alien_draw_done) begin
    //             if (which_alien == 19) begin
    //                 if (erase) begin
    //                     erase = 0;
    //                     which_alien = 0;
    //                     group_x = input_group_x;
    //                     group_y = input_group_y;
    //                     prev_group_x = input_group_x;
    //                     prev_group_y = input_group_y;
    //                 end
    //             end else
    //                 which_alien = which_alien + 1;
    //         end
    //     end 

    //     if (ns == s_is_alive) begin
    //         alien_draw_reset = 1;
    //     end

    //     if (ps == s_is_alive) begin
    //         if (alien_alive) begin
    //             curr_center_x = (erase) ? `ERASE_ALIEN_X(which_alien) : `ALIEN_X(which_alien);
    //             curr_center_y = (erase) ? `ERASE_ALIEN_Y(which_alien) : `ALIEN_Y(which_alien);
    //             // alien_draw_reset = 1;
    //             test_case = 1;
    //         end 
    //         else begin
    //             if (which_alien == 19) begin
    //                 if (erase) begin
    //                     erase = 0;
    //                     which_alien = 0;
    //                     group_x = input_group_x;
    //                     group_y = input_group_y;
    //                     prev_group_x = input_group_x;
    //                     prev_group_y = input_group_y;
    //                 end
    //                 test_case = 2;
    //             end else
    //                 which_alien = which_alien + 1;
    //                 test_case = 3;
    //         end
    //     end

    //     if (ps == s_start) begin
    //         if (!(prev_group_x == input_group_x && prev_group_y == input_group_y)) begin
    //             erase = 1;
    //             which_alien = 0;
    //         end
    //     end
    // end

    always_ff @(posedge clock) begin
        if (global_reset)
            ps = s_global_reset;
        else if (reset)
            ps = s_start;
        else
            ps = ns;
    end
endmodule  // alien_group_drawer

module alien_group_drawer_tb();
    logic clock, global_reset, reset, alien_alive, alien_draw_done, done, alien_draw_reset;
    logic [9:0] input_group_x, out_center_x;
    logic [8:0] input_group_y, out_center_y;
    logic [3:0] color;
    logic [4:0] out_which_alien;

    alien_group_drawer dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i, j;
    initial begin
        global_reset <= 1;  alien_alive <= 1;  alien_draw_done <= 0;  @(posedge clock);
        global_reset <= 0;              @(posedge clock);

        for (i = 0; i < 5; i++) begin
            @(posedge clock);
        end

        for (j = 0; j < 21; j++) begin
            alien_draw_done <= 1;           @(posedge clock);
            alien_draw_done <= 0;           @(posedge clock);
            for (i = 0; i < 5; i++) begin
                @(posedge clock);
            end
        end

        input_group_x <= 300; input_group_y <= 105;         @(posedge clock);

        reset <= 1;     @(posedge clock);
        reset <= 0;     @(posedge clock);

        for (j = 0; j < 42; j++) begin
            alien_draw_done <= 1;           @(posedge clock);
            alien_draw_done <= 0;           @(posedge clock);
            for (i = 0; i < 5; i++) begin
                @(posedge clock);
            end
        end

        input_group_x <= 400; input_group_y <= 110;         @(posedge clock);

        reset <= 1;     @(posedge clock);
        reset <= 0;     @(posedge clock);

        for (j = 0; j < 42; j++) begin
            alien_draw_done <= 1;           @(posedge clock);
            alien_draw_done <= 0;           @(posedge clock);
            for (i = 0; i < 5; i++) begin
                @(posedge clock);
            end
        end
        
        $stop;
    end

endmodule

