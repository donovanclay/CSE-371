module big_testbench_tb();
    logic CLOCK_50;
    logic [9:0] LEDR;

    parameter SCREEN_WIDTH = 640;
    parameter SCREEN_HEIGHT = 480;

    parameter SCREEN_PADDING_X = 10;
    parameter SCREEN_PADDING_Y = 10;

    parameter START_X = 320;
    parameter START_Y = 454;

    parameter NUM_ALIENS = 20;

    parameter ALIEN_GROUP_START_X = 320;
    parameter ALIEN_GROUP_START_Y = 105;
    parameter ALIEN_GROUP_PADDING_LEFT = 152;
    parameter ALIEN_GROUP_PADDING_RIGHT = 488;

    parameter ALIEN_WIDTH = 40;
    parameter ALIEN_HEIGHT = 21;
    parameter ALIEN_GAP = 21;

    parameter STEP_SIZE_X = 1;
    parameter STEP_SIZE_Y = 1;

    parameter PLAYER_WIDTH = 32;
    parameter PLAYER_HEIGHT = 32;

    parameter LASER_WIDTH = 5;
    parameter LASER_LENGTH = 10;

    parameter BACKGROUND_COLOR = 24'h0;
    parameter BACKGROUND_COLOR_NUM = 0;
    parameter PLAYER_COLOR = 24'h34CA7F;
    parameter PLAYER_COLOR_NUM = 1;
    parameter LASER_COLOR = 24'hE91E63;
    parameter LASER_COLOR_NUM = 2;
    parameter ALIEN_COLOR = 24'hFFFFFF;
    parameter ALIEN_COLOR_NUM = 3;
    parameter TITLE_TEXT_COLOR = 24'hFFB11E;
    parameter TITLE_TEXT_COLOR_NUM = 4;


    logic reset;
    logic global_reset;
    
    logic n8_up;
    logic n8_down;
    logic n8_left;
    logic n8_right;
    logic n8_a;
    logic n8_b;
    logic n8_select;
    logic n8_start;
    

    // n8_driver driver(
    //     .clk(CLOCK_50),
    //     .data_in(V_GPIO[28]),
    //     .latch(n8_latch),
    //     .pulse(n8_pulse),
    //     .up(n8_up),
    //     .down(n8_down),
    //     .left(n8_left),
    //     .right(n8_right),
    //     .select(n8_select),
    //     .start(n8_start),
    //     .a(n8_a),
    //     .b(n8_b)
    // );

    logic enable;

    logic [4:0] count;

    always_ff @(posedge CLOCK_50) begin
        if (global_reset)
            count = 0;
        else 
            count = count + 1;
    end

    assign enable = (count == (2** 5) - 1);
    
    logic [5:0] count2;
    logic enable2;
    always_ff @(posedge CLOCK_50) begin
        if (global_reset)
            count2 = 0;
        else 
            count2 = count2 + 1;
    end
    

    assign enable2 = (count2 == (2** 6) - 1);
    
    // assign LEDR[1] = enable;

    logic [9:0] alien_group_x;
    logic [8:0] alien_group_y;

    alien_group_location # (
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .ALIEN_GROUP_START_X(ALIEN_GROUP_START_X),
        .ALIEN_GROUP_START_Y(ALIEN_GROUP_START_Y),
        .ALIEN_GROUP_PADDING_LEFT(ALIEN_GROUP_PADDING_LEFT),
        .ALIEN_GROUP_PADDING_RIGHT(ALIEN_GROUP_PADDING_RIGHT)
    ) alien_group_location1 (
        .clock(CLOCK_50),
        .enable(enable2),
        .global_reset(global_reset),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y)
    );

    logic [4:0] which_alien;
    logic alien_alive_write_data, alien_alive_read_data, alien_alive_wren;
    // assign alien_alive_wren = 0;

    // aliens_alive_ram alive_ram (
    //     .address(which_alien),
    //     .clock(CLOCK_50),
    //     .data(alien_alive_write_data),
    //     .wren(alien_alive_wren),
    //     .q(alien_alive_read_data)
    // );
    assign alien_alive_read_data = 1;
    
    logic [9:0] player_x;
    logic [8:0] player_y;

    player_location # (
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .SCREEN_PADDING_X(SCREEN_PADDING_X),
        .SCREEN_PADDING_Y(SCREEN_PADDING_Y),
        .PLAYER_WIDTH(PLAYER_WIDTH),
        .PLAYER_HEIGHT(PLAYER_HEIGHT),
        .START_X(START_X),
        .START_Y(START_Y),
        .STEP_SIZE_X(STEP_SIZE_X),
        .STEP_SIZE_Y(STEP_SIZE_Y)
    )
    player_location1 (
        .CLOCK_50(CLOCK_50),
        .enable(enable),
        .global_reset(global_reset),
        .left(n8_left),
        .right(n8_right),
        .out_x(player_x),
        .out_y(player_y)
    );
    
    logic player_drawer_global_reset, player_drawer_reset;
    logic player_drawer_done;
    logic [9:0] player_drawer_out_x;
    logic [8:0] player_drawer_out_y;
    logic [3:0] player_drawer_which_color;

    player_drawer #(
        .START_X(START_X),
        .START_Y(START_Y),
        .PLAYER_WIDTH(PLAYER_WIDTH),
        .PLAYER_HEIGHT(PLAYER_HEIGHT)
    )
    player_drawer1 (
        .clock(CLOCK_50),
        .global_reset(player_drawer_global_reset),
        .reset(player_drawer_reset),
        .player_x(player_x),
        .player_y(player_y),
        .out_x(player_drawer_out_x),
        .out_y(player_drawer_out_y),
        .which_color(player_drawer_which_color),
        .done(player_drawer_done)
    );

    assign LEDR[9:3] = player_x[9:3];
    // assign LEDR[9:2] = alien_group_x[9:2];
    // assign LEDR[8:2] = alien_group_y[8:2];


    logic [18:0] vga_address, write_address;
    logic [3:0] vga_write_data, write_data, vga_read_data, read_data;
    logic vga_write_enable, write_enable;
    // display_ram my_ram (
    //     .address_a(vga_address),
    //     .address_b(write_address),
    //     .clock(CLOCK_50),
    //     .data_a(vga_write_data),
    //     .data_b(write_data),
    //     .wren_a(vga_write_enable),
    //     .wren_b(write_enable),
    //     .q_a(vga_read_data),
    //     .q_b(read_data)
    // );

    logic alien_group_drawer_done, alien_group_global_reset, alien_group_reset, valid;
    logic [4:0] alien_group_which_alien;
    
    logic [9:0] alien_out_x;
    logic [8:0] alien_out_y;
    logic [3:0] alien_out_color;
    alien_group_drawer_organizer #(
        .NUM_ALIENS(NUM_ALIENS),
        .ALIEN_GROUP_START_X(ALIEN_GROUP_START_X),
        .ALIEN_GROUP_START_Y(ALIEN_GROUP_START_Y),
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT),
        .ALIEN_GAP(ALIEN_GAP),
        .BACKGROUND_COLOR_NUM(BACKGROUND_COLOR_NUM),
        .ENEMY_COLOR_NUM(ALIEN_COLOR_NUM)
    ) my_alien_organizer (
        .clock(CLOCK_50),
        .global_reset(alien_group_global_reset),
        .group_reset(alien_group_reset),
        .alien_alive(alien_alive_read_data),
        .input_group_x(alien_group_x),
        .input_group_y(alien_group_y),
        .out_x(alien_out_x),
        .out_y(alien_out_y),
        .out_color(alien_out_color),
        .which_alien(alien_group_which_alien),
        .group_done(alien_group_drawer_done),
        .valid(alien_valid)
    );


    
    logic laser_enable, laser_done, finished_one_frame, laser_alien_alive_write_data, laser_alien_alive_wren, out_laser_manager_done, laser_alive;
    logic [9:0] laser_out_x;
    logic [8:0] laser_out_y;
    logic [4:0] laser_which_alien;
    logic [3:0] laser_which_color;

    laser_top_level #(
        .PLAYER_HEIGHT(PLAYER_HEIGHT),
        .PLAYER_WIDTH(PLAYER_WIDTH),
        .LASER_LENGTH(LASER_LENGTH),
        .LASER_WIDTH(LASER_WIDTH),
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT),
        .ALIEN_GAP(ALIEN_GAP),
        .BACKGROUND_COLOR_NUM(BACKGROUND_COLOR_NUM),
        .LASER_COLOR_NUM(LASER_COLOR_NUM)
    ) my_top_level_laser (
        .clock(CLOCK_50),
        .laser_enable(laser_enable),
        .global_reset(global_reset),
        .fire(n8_a),
        .alien_alive(alien_alive_read_data),
        .player_x(player_x),
        .player_y(player_y),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y),
        .out_x(laser_out_x),
        .out_y(laser_out_y),
        .finished_one_frame(finished_one_frame),
        .alien_alive_write_data(laser_alien_alive_write_data),
        .alien_alive_wren(laser_alien_alive_wren),
        .out_laser_manager_done(out_laser_manager_done),
        .which_alien(laser_which_alien),
        .out_which_color(laser_which_color),
        .out_laser_alive(laser_alive)
    );

    logic [9:0] draw_controller_x;
    logic [8:0] draw_controller_y;
    logic [3:0] draw_which_color;
    logic draw_alien_alive_wren, draw_alien_alive_write_data;

    drawing_state_machine draw_controller (
        .clock(CLOCK_50),
        .enable(enable),
        .global_reset(global_reset),
        .player_drawer_done(player_drawer_done),
        .alien_group_drawer_done(alien_group_drawer_done),
        .finished_one_frame(finished_one_frame),
        // .finished_one_frame(1),
        .laser_alien_alive_wren(laser_alien_alive_wren),
        .laser_alien_alive_write_data(laser_alien_alive_write_data),
        .laser_done(out_laser_manager_done),
        .player_drawer_out_x(player_drawer_out_x),
        .player_drawer_out_y(player_drawer_out_y),
        .alien_group_out_x(alien_out_x),
        .alien_group_out_y(alien_out_y),
        .laser_out_x(laser_out_x),
        .laser_out_y(laser_out_y),
        .player_drawer_which_color(player_drawer_which_color),
        .alien_group_which_color(alien_out_color),
        .laser_which_color(laser_which_color),
        .alien_group_which_alien(alien_group_which_alien),
        .laser_which_alien(laser_which_alien),
        .player_global_reset(player_drawer_global_reset),
        .player_reset(player_drawer_reset),
        .alien_group_global_reset(alien_group_global_reset),
        .alien_group_reset(alien_group_reset),
        .laser_enable(laser_enable),
        .out_alien_alive_wren(draw_alien_alive_wren),
        .out_alien_alive_write_data(draw_alien_alive_write_data),
        .out_x(draw_controller_x),
        .out_y(draw_controller_y),
        .out_which_color(draw_which_color),
        .out_which_alien(which_alien)
    );

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    integer i;
    initial begin
        n8_left <= 0; n8_right <= 0; n8_a <= 0; @(posedge CLOCK_50);
                        @(posedge CLOCK_50);
                        @(posedge CLOCK_50);
        global_reset <= 1;  @(posedge CLOCK_50);
        global_reset <= 0;  @(posedge CLOCK_50);

        for (i = 0; i < 900 * 75; i++) begin
                            @(posedge CLOCK_50);
        end
        n8_left <= 1;   @(posedge CLOCK_50);
        for (i = 0; i < 100; i++) begin
                            @(posedge CLOCK_50);
        end
        n8_left <= 0;   @(posedge CLOCK_50);

        for (i = 0; i < 900 * 75; i++) begin
                            @(posedge CLOCK_50);
        end

        n8_a <= 1;   @(posedge CLOCK_50);
        for (i = 0; i < 100; i++) begin
                            @(posedge CLOCK_50);
        end
        n8_a <= 0;   @(posedge CLOCK_50);
        for (i = 0; i < 900 * 300 * 8; i++) begin
                            @(posedge CLOCK_50);
        end
        $stop;
    end
endmodule