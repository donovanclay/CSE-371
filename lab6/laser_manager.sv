module laser_manager # (
    parameter PLAYER_HEIGHT = 32,
    parameter PLAYER_WIDTH = 32,
    parameter LASER_LENGTH = 10,
    parameter LASER_WIDTH = 5, 
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21,
    parameter ALIEN_GAP = 21
) (
    input logic clock, laser_enable, laser_manager_reset,
    input logic [9:0] player_x, alien_group_x,
    input logic [8:0] player_y, alien_group_y,
    input logic alien_alive,
    output logic [4:0] out_which_alien,
    output logic [9:0] out_x,
    output logic [8:0] out_y,
    output logic done, out_alien_alive_write, out_alien_alive_wren, out_laser_alive
);
    logic [9:0] laser_x;
    logic [8:0] laser_y;
    logic laser_alive, laser_draw_reset, laser_draw_start, laser_draw_done, alien_check_done, alien_check_reset, alien_alive_write, alien_alive_wren, alien_killed, offscreen;
    logic [4:0] which_alien_local;

    assign offscreen = (laser_y <= 0);

    enum {s_start, s_wait1, s_wait2, s_draw_laser, s_check_offscreen, s_alien_check, s_update_aliens, s_laser_dead_erase, s_done} ps, ns;
    assign done = (ps == s_done);
    assign out_which_alien = which_alien_local;
    assign out_alien_alive_write = alien_alive_write;
    assign out_alien_alive_wren = alien_alive_wren;
    assign out_laser_alive = laser_alive;

    alien_check # (
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT),
        .ALIEN_GAP(ALIEN_GAP),
        .LASER_WIDTH(LASER_WIDTH)
    ) my_alien_checker (
        .clock(clock),
        .alien_check_reset(alien_check_reset),
        .alien_alive(alien_alive),
        .input_laser_x(laser_x),
        .input_laser_y(laser_y),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y),
        .which_alien_out(which_alien_local),
        .done(alien_check_done),
        .alien_killed(alien_killed)
    );

    laser_draw # (
        .LASER_WIDTH(LASER_WIDTH),
        .LASER_LENGTH(LASER_LENGTH),
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT)
    ) my_laser_drawer (
        .clock(clock),
        .laser_alive(laser_alive),
        .laser_draw_start(laser_draw_start),
        .laser_draw_reset(laser_draw_reset),
        .laser_x(laser_x),
        .laser_y(laser_y),
        .out_x(out_x),
        .out_y(out_y),
        .done(laser_draw_done)
    );

    always_comb begin
        case (ps)
            s_start:
                // ns = s_draw_laser;
                ns = wait_1

            s_wait1:
                if (laser_enable)
                    ns = s_draw_lawer;
                else
                    ns = s_wait1;

            s_wait2:
                if (laser_enable)
                    ns = s_check_offscreen;
                else
                    ns = s_wait2;
            
            s_draw_laser: begin
                if (laser_draw_done)
                    // ns = s_check_offscreen;
                    ns = s_wait2
                else
                    ns = s_draw_laser;
            end

            s_check_offscreen:
                if (offscreen)
                    ns = s_laser_dead_erase;
                else
                    ns = s_alien_check;
            
            s_laser_dead_erase:
                if (laser_draw_done)
                    ns = s_done;
                else
                    ns = s_laser_dead_erase;

            s_alien_check:
                if (alien_check_done) begin
                    if (alien_killed) 
                        ns = s_update_aliens;
                    else
                        ns = s_draw_laser;
                end
            
            s_update_aliens:
                ns = s_laser_dead_erase;
            
            s_done:
                ns = s_done;
        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == s_start) begin
            laser_x = player_x;
            laser_y = player_y - (PLAYER_HEIGHT / 2 + LASER_LENGTH);
            laser_alive = 1;
            laser_draw_start = 1;
            alien_check_reset = 1;
        end

        if (ps == s_draw_laser) begin
            laser_draw_reset = 0;
            laser_draw_start = 0;

            if (laser_draw_done)
                laser_y = laser_y - 1;
        end

        if (ps == s_check_offscreen) begin
            laser_draw_reset = 1;
            if (offscreen) begin
                // laser_draw_reset = 1;
                laser_alive = 0;
            end
            else begin
                alien_check_reset = 1;
            end
        end

        if (ps == s_laser_dead_erase) begin
            laser_draw_reset = 0;
        end

        if (ps == s_alien_check) begin
            // alien_check_reset = 0;
            alien_check_reset = (alien_check_done);

            if (alien_check_done) begin
                // alien_check_reset = 1
                if (alien_killed) begin
                    // out_which_alien = which_alien_local;
                    alien_alive_write = 0;
                    alien_alive_wren = 1;
                end
                else
                    laser_draw_reset = 1;
            end
        end
        
        if (ps == s_update_aliens) begin
            alien_alive_wren = 0;
            laser_draw_reset = 1;
            laser_alive = 0;
        end
    end

    always_ff @(posedge clock) begin
        if (laser_manager_reset)
            ps = s_start;
        // else if (enable)
        //     ps = ns;
        else
            ps = ps;
    end

endmodule

module laser_manager_tb();
    logic clock, enable, laser_manager_reset;
    logic [9:0] player_x, alien_group_x;
    logic [8:0] player_y, alien_group_y;
    logic alien_alive;
    logic [4:0] out_which_alien;
    logic [9:0] out_x;
    logic [8:0] out_y;
    logic done, out_alien_alive_write, out_alien_alive_wren, out_laser_alive;

    laser_manager dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        enable <= 1; laser_manager_reset <= 1; player_x <= 200; player_y <= 400; alien_group_x <= 200; alien_group_y <= 200; alien_alive <= 1; @(posedge clock);
        laser_manager_reset <= 0; @(posedge clock);

        for (i = 0; i < 90 * 14; i++) begin
                        @(posedge clock);
        end
        // alien_alive <= 0; @(posedge clock);

        for (i = 0; i < 90 * 150; i++) begin
                        @(posedge clock);
        end
        

        // for (i = 0; i < 90 * 2; i++) begin
        //                 @(posedge clock);
        // end

        $stop;
    end
endmodule