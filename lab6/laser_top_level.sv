module laser_top_level #(
    parameter PLAYER_HEIGHT = 32,
    parameter PLAYER_WIDTH = 32,
    parameter LASER_LENGTH = 10,
    parameter LASER_WIDTH = 5, 
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21,
    parameter ALIEN_GAP = 21,
    parameter BACKGROUND_COLOR_NUM = 0,
    parameter LASER_COLOR_NUM = 2
) (
    input logic clock, laser_enable, global_reset, fire, alien_alive,
    input logic [9:0] player_x, alien_group_x,
    input logic [8:0] player_y, alien_group_y,
    output logic [9:0] out_x,
    output logic [8:0] out_y, 
    output logic finished_one_frame, alien_alive_write_data, alien_alive_wren, out_laser_manager_done, out_laser_alive,
    output logic [4:0] which_alien,
    output logic [3:0] out_which_color
);

    logic laser_manager_reset, laser_alive, laser_manager_done;
    enum {s_not_reset, s_reset} ps1, ns1;
    assign out_laser_manager_done = laser_manager_done || ps1 == s_not_reset;
    assign out_laser_alive = laser_alive;

    enum {s_start, s_laser_alive} ps, ns;

    laser_manager #(
        .PLAYER_HEIGHT(PLAYER_HEIGHT),
        .PLAYER_WIDTH(PLAYER_WIDTH),
        .LASER_LENGTH(LASER_LENGTH),
        .LASER_WIDTH(LASER_WIDTH),
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT),
        .ALIEN_GAP(ALIEN_GAP)
    ) my_manager (
        .clock(clock),
        .laser_enable(laser_enable),
        .global_reset(global_reset),
        .laser_manager_reset(laser_manager_reset),
        .player_x(player_x),
        .player_y(player_y),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y),
        .alien_alive(alien_alive),
        .out_which_alien(which_alien),
        .out_x(out_x),
        .out_y(out_y),
        .done(laser_manager_done),
        .out_alien_alive_write(alien_alive_write_data),
        .out_alien_alive_wren(alien_alive_wren),
        .out_laser_alive(laser_alive),
        .out_finished_one_frame(finished_one_frame),
        .out_which_color(out_which_color)
    );

    

    always_comb begin
        case (ps)
            s_start:
                if (fire)
                    ns = s_laser_alive;
                else
                    ns = s_start;
            s_laser_alive:
                if (laser_alive)
                    ns = s_laser_alive;
                else
                    ns = s_start;
        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == s_start) begin
            if (fire)
                laser_manager_reset = 1;
            else
                laser_manager_reset = 0;
        end

        if (ps == s_laser_alive) begin
            laser_manager_reset = 0;
        end
    end

    always_ff @(posedge clock) begin
        if (global_reset)
            ps = s_start;
        else
            ps = ns;
    end

    

    always_comb begin
        case (ps1)
            s_not_reset:
                if (laser_manager_reset)
                    ns1 = s_reset;
                else ns1 = s_not_reset;
            s_reset:
                ns1 = s_reset;
        endcase
    end

    always_ff @(posedge clock) begin
        if (global_reset)
            ps1 = s_not_reset;
        else
            ps1 = ns1;
    end

endmodule

module laser_top_level_tb();
    logic fire, alien_alive, out_laser_alive;
    logic [9:0] player_x, alien_group_x;
    logic [8:0] player_y, alien_group_y;
    logic alien_alive_write_data, alien_alive_wren, out_laser_manager_done;
    logic [4:0] which_alien;

    logic clock, enable;
    logic global_reset, player_drawer_done, alien_group_drawer_done, finished_one_frame, laser_alien_alive_wren, laser_alien_alive_write_data, laser_done;
    logic [9:0] player_drawer_out_x, alien_group_out_x, laser_out_x;
    logic [8:0] player_drawer_out_y, alien_group_out_y, laser_out_y;
    logic [3:0] player_drawer_which_color, alien_group_which_color,laser_which_color;
    logic [4:0] alien_group_which_alien, laser_which_alien;
    logic player_global_reset, player_reset, alien_group_global_reset, alien_group_reset, laser_enable, out_alien_alive_wren, out_alien_alive_write_data;
    logic [9:0] out_x;
    logic [8:0] out_y;
    logic [3:0] out_which_color;
    logic [4:0] out_which_alien;

    laser_top_level dut1 (
        .clock(clock),
        .laser_enable(laser_enable),
        .global_reset(global_reset),
        .fire(fire),
        .alien_alive(alien_alive),
        .player_x(player_x),
        .player_y(player_y),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y),
        .out_x(laser_out_x),
        .out_y(laser_out_y),
        .finished_one_frame(finished_one_frame),
        .alien_alive_write_data(laser_alien_alive_write_data),
        .alien_alive_wren(laser_alien_alive_wren),
        .out_laser_manager_done(laser_done),
        .out_laser_alive(out_laser_alive),
        .which_alien(laser_which_alien),
        .out_which_color(laser_which_color)
    );
    drawing_state_machine dut2 (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        enable <= 1; fire <= 0; global_reset <= 1; player_x <= 200; player_y <= 400; alien_group_x <= 200; alien_group_y <= 200; alien_alive <= 1; @(posedge clock);
        global_reset <= 0; @(posedge clock);

        for (i = 0; i < 3; i++) begin
                            @(posedge clock);
        end
        player_drawer_done <= 1; @(posedge clock);
        player_drawer_done <= 0; @(posedge clock);
        for (i = 0; i < 3; i++) begin
                            @(posedge clock);
        end
        alien_group_drawer_done <= 1; @(posedge clock);
        alien_group_drawer_done <= 0; @(posedge clock);
        for (i = 0; i < 3; i++) begin
                            @(posedge clock);
        end

        fire <= 1;          @(posedge clock);
        fire <= 0;          @(posedge clock);

        player_drawer_done <= 1; @(posedge clock);
        player_drawer_done <= 0; @(posedge clock);
        for (i = 0; i < 3; i++) begin
                            @(posedge clock);
        end

        alien_group_drawer_done <= 1; @(posedge clock);
        alien_group_drawer_done <= 0; @(posedge clock);
        for (i = 0; i < 3; i++) begin
                            @(posedge clock);
        end

        for (i = 0; i < 15; i++) begin
                            @(posedge clock);
        end
        alien_group_drawer_done <= 1; @(posedge clock);
        alien_group_drawer_done <= 0; @(posedge clock);

        for (i = 0; i < 15* 5; i++) begin
                            @(posedge clock);
        end

         @(posedge clock);

        for (i = 0; i < 15* 8; i++) begin
                            @(posedge clock);
        end     
        
        alien_group_drawer_done <= 1; @(posedge clock);
        alien_group_drawer_done <= 0; @(posedge clock);

        for (i = 0; i < 15* 10; i++) begin
                            @(posedge clock);
        end

        player_drawer_done <= 1;        @(posedge clock);
        player_drawer_done <= 0;        @(posedge clock);
        for (i = 0; i < 15* 15; i++) begin
                            @(posedge clock);
        end
        alien_group_drawer_done <= 1; @(posedge clock);
        alien_group_drawer_done <= 0; @(posedge clock);
        for (i = 0; i < 15* 15; i++) begin
                            @(posedge clock);
        end
        $stop;
    end
endmodule