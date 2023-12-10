module drawing_state_machine2 (
    input logic clock, enable,
    input logic global_reset, player_drawer_done, alien_group_drawer_done, laser_done, laser_alien_alive_wren, laser_alien_alive_write_data,
    input logic [9:0] player_drawer_out_x, alien_group_out_x, laser_out_x,
    input logic [8:0] player_drawer_out_y, alien_group_out_y, laser_out_y,
    input logic [3:0] player_drawer_which_color, alien_group_which_color, laser_which_color,
    input logic [3:0] laser_which_state,
    input logic [4:0] alien_group_which_alien, laser_which_alien,
    output logic player_global_reset, player_reset, laser_reset, alien_group_global_reset, alien_group_reset, out_alien_alive_wren, out_alien_alive_write_data,
    output logic [9:0] out_x,
    output logic [8:0] out_y,
    output logic [3:0] out_which_color,
    output logic []
    output logic [4:0] out_which_alien
);

    // logic local_alien_group_reset;
    // assign alien_group_reset = local_alien_group_reset;

    enum {s_start, s_init_player, s_init_alien_group, s_draw_player, s_before_draw_laser, s_draw_alien_group, s_draw_laser} ps, ns;

    always_comb begin
        case (ps)
            s_start:
                ns = s_init_player;
            
            s_init_player: begin
                if (player_drawer_done)
                    ns = s_init_alien_group;
                else
                    ns = s_init_player;
            end

            s_init_alien_group:
                if (alien_group_drawer_done)
                    ns = s_draw_player;
                else
                    ns = s_draw_alien_group;

            s_draw_player:
                if (player_drawer_done) begin
                    // ns = s_draw_laser;
                    ns = s_before_draw_laser;
                end
                else
                    ns = s_draw_player;
            
            s_before_draw_laser:
                ns = s_draw_laser;

            s_draw_laser:
                if (laser_done)
                    ns = s_draw_alien_group;
                else begin
                    
                    ns = s_draw_laser;
                end

            s_draw_alien_group:
                if (alien_group_drawer_done)
                    ns = s_draw_player;
                else
                    ns = s_draw_alien_group
        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == s_start) begin
            player_global_reset = 1;
            player_reset = 0;
            alien_group_global_reset = 0;
            alien_group_reset = 0;
            laser_reset = 0;
        end

        if (ps == s_init_player) begin
            player_global_reset = 0;

            if (player_drawer_done)
                alien_group_global_reset = 1;
            else
                alien_group_global_reset = 0;
        end

        if (ps == s_init_alien_group) begin
            alien_group_global_reset = 0;

            if (alien_group_drawer_done)
                player_reset = 1;
            else
                player_reset = 0;
        end

        if (ps == s_draw_player) begin
            player_reset = 0;

            if (player_drawer_done) begin
                laser_reset = 1;
            end
        end

        if (ps == s_before_draw_laser) begin
            laser_reset = 1;
        end

        if (ps == s_draw_laser) begin
            laser_reset = 0;
            if (laser_done)
                alien_group_reset = 1;
        end

        if (ps == s_draw_alien_group) begin
            alien_group_reset = 0;

            if (alien_group_drawer_done)
                player_reset = 1;
            else
                player_reset = 0;
        end

        
    end

    always_ff @(posedge clock) begin
        if (ps == s_init_player || ps == s_draw_player) begin
            out_x = player_drawer_out_x;
            out_y = player_drawer_out_y;
            out_which_color = player_drawer_which_color;
            // out_which_alien = 
            out_alien_alive_wren = 0;
        end 

        if (ps == s_init_alien_group || ps == s_draw_alien_group) begin
            out_x = alien_group_out_x;
            out_y = alien_group_out_y;
            out_which_color = alien_group_which_color;
            out_which_alien = alien_group_which_alien;
            out_alien_alive_wren = 0;
        end

        if (ps == s_draw_laser) begin
            out_x = laser_out_x;
            out_y = laser_out_y;
            out_which_color = laser_which_color;
            out_which_alien = laser_which_alien;
            out_alien_alive_wren = laser_alien_alive_wren;
            out_alien_alive_write_data = laser_alien_alive_write_data;
        end

    end

    always_ff @(posedge clock ) begin
        if (global_reset)
            ps = s_start;
        else if (enable)
            ps = ns;
        else
            ps = ps;
    end

endmodule   // drawing_state_machine

module drawing_state_machine2_tb ();
    logic clock, enable;
    logic global_reset, player_drawer_done, alien_group_drawer_done, laser_done, laser_alien_alive_wren, laser_alien_alive_write_data;
    logic [9:0] player_drawer_out_x, alien_group_out_x, laser_out_x;
    logic [8:0] player_drawer_out_y, alien_group_out_y, laser_out_y;
    logic [3:0] player_drawer_which_color, alien_group_which_color,laser_which_color;
    logic [4:0] alien_group_which_alien, laser_which_alien;
    logic player_global_reset, player_reset, laser_reset,alien_group_global_reset, alien_group_reset, out_alien_alive_wren, out_alien_alive_write_data;
    logic [9:0] out_x;
    logic [8:0] out_y;
    logic [3:0] out_which_color;
    logic [4:0] out_which_alien;

    drawing_state_machine2 dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i, j;
    initial begin
        enable <= 1; global_reset <= 1; alien_group_drawer_done <= 0; player_drawer_done <= 0;  @(posedge clock);
        global_reset <= 0;                  @(posedge clock);

        for (i = 0; i < 3; i++) begin
                        @(posedge clock);
        end

        
        player_drawer_done <= 1;            @(posedge clock);
        player_drawer_done <= 0;            @(posedge clock);
        for (i = 0; i < 3; i++) begin
                        @(posedge clock);
        end


        alien_group_drawer_done <= 1;       @(posedge clock);
        alien_group_drawer_done <= 0;       @(posedge clock);
        for (i = 0; i < 3; i++) begin
                        @(posedge clock);
        end

        player_drawer_done <= 1;            @(posedge clock);
        player_drawer_done <= 0;            @(posedge clock);
        for (i = 0; i < 3; i++) begin
                        @(posedge clock);
        end

        laser_done <= 1;              @(posedge clock);

        $stop;
    end


endmodule