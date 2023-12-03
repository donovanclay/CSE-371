module DE1_SoC (
    input CLOCK_50,
    inout [35:0] V_GPIO,
    output [9:0] LEDR,
    output [6:0] HEX0, 
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_BLANK_N,
    output VGA_CLK,
    output VGA_HS,
    output VGA_SYNC_N,
    output VGA_VS
    );

    parameter SCREEN_WIDTH = 640;
    parameter SCREEN_HEIGHT = 480;

    parameter SCREEN_PADDING_X = 10;
    parameter SCREEN_PADDING_Y = 10;

    parameter START_X = 320;
    parameter START_Y = 454;

    parameter NUM_ALIENS = 20;

    parameter ALIEN_GROUP_START_X = 320;
    parameter ALIEN_GROUP_START_Y = 105;
    parameter ALIEN_GROUP_PADDING_LEFT = 89;
    parameter ALIEN_GROUP_PADDING_RIGHT = 454;

    parameter ALIEN_WIDTH = 40;
    parameter ALIEN_HEIGHT = 21;

    parameter STEP_SIZE_X = 1;
    parameter STEP_SIZE_Y = 1;

    parameter PLAYER_WIDTH = 32;
    parameter PLAYER_HEIGHT = 32;

    parameter BACKGROUND_COLOR = 24'h0;
    parameter BACKGROUND_COLOR_NUM = 0;
    parameter PLAYER_COLOR = 24'h34CA7F;
    parameter PLAYER_COLOR_NUM = 1;
    parameter LASER_COLOR = 24'hE91E63;
    parameter LASER_COLOR_NUM = 2;
    parameter ENEMY_COLOR = 24'hFFFFFF;
    parameter ENEMY_COLOR_NUM = 3;
    parameter TITLE_TEXT_COLOR = 24'hFFB11E;
    parameter TITLE_TEXT_COLOR_NUM = 4;


    logic reset;
    logic global_reset;
    assign global_reset = V_GPIO[5];
    
    wire n8_up;
    wire n8_down;
    wire n8_left;
    wire n8_right;
    wire n8_a;
    wire n8_b;
    wire n8_latch;
    wire n8_pulse;
    wire n8_select;
    wire n8_start;
    
    assign V_GPIO[27] = n8_pulse;
    assign V_GPIO[26] = n8_latch;

    n8_driver driver(
        .clk(CLOCK_50),
        .data_in(V_GPIO[28]),
        .latch(n8_latch),
        .pulse(n8_pulse),
        .up(n8_up),
        .down(n8_down),
        .left(n8_left),
        .right(n8_right),
        .select(n8_select),
        .start(n8_start),
        .a(n8_a),
        .b(n8_b)
    );

    n8_display display(
        .clk(CLOCK_50),
        .up(n8_up),
        .down(n8_down),
        .left(n8_left),
        .right(n8_right),
        .select(n8_select),
        .start(n8_start),
        .a(n8_a),
        .b(n8_b),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

    logic [9:0] player_x;
    logic [8:0] player_y;
    logic enable, updated_location;

    logic [17:0] count;

    always_ff @(posedge CLOCK_50) begin
        if (global_reset)
            count = 0;
        else 
            count = count + 1;
    end

    assign enable = (count == (2** 18) - 1);
    
    assign LEDR[1] = enable;

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
        .enable(enable),
        .global_reset(global_reset),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y)
    );

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

    // assign LEDR[9:2] = player_x[9:2];
    assign LEDR[9:2] = alien_group_x[9:2];

    logic player_drawer_reset, player_drawer_done;
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
        .global_reset(global_reset),
        .reset(player_drawer_done),
        .player_x(player_x),
        .player_y(player_y),
        .out_x(player_drawer_out_x),
        .out_y(player_drawer_out_y),
        .which_color(player_drawer_which_color),
        .done(player_drawer_done)
    );

    logic [18:0] vga_address, write_address;
    logic [3:0] vga_write_data, write_data, vga_read_data, read_data;
    logic vga_write_enable, write_enable;
    display_ram my_ram (
        .address_a(vga_address),
        .address_b(write_address),
        .clock(CLOCK_50),
        .data_a(vga_write_data),
        .data_b(write_data),
        .wren_a(vga_write_enable),
        .wren_b(write_enable),
        .q_a(vga_read_data),
        .q_b(read_data)
    );

    // logic [3:0] title_color;

    // title_text_ram my_title_ram (
    //     .address(vga_address),
    //     .clock(CLOCK_50),
    //     .q(title_color)
    // );

    logic [9:0] x;
    logic [8:0] y;
    logic [7:0] r, g, b;

    logic [3:0] color_converter_in;

    // assign color_converter_in = (global_reset) ? title_color : vga_read_data;
    assign color_converter_in = vga_read_data;

    color_converter # (
        .BACKGROUND_COLOR(BACKGROUND_COLOR),
        .PLAYER_COLOR(PLAYER_COLOR),
        .LASER_COLOR(LASER_COLOR),
        .ENEMY_COLOR(ENEMY_COLOR)
    )
    my_cc (
        .which_color(color_converter_in),
        .r(r),
        .g(g),
        .b(b)
    );

    assign vga_address = SCREEN_WIDTH * y + x;
    assign vga_write_enable = 1'b0;
    assign write_address = SCREEN_WIDTH * player_drawer_out_y +
                           player_drawer_out_x;
    assign write_data = player_drawer_which_color;
    assign write_enable = (!player_drawer_done);

    video_driver #(.WIDTH(SCREEN_WIDTH), .HEIGHT(SCREEN_HEIGHT))
        v1 (.CLOCK_50, .reset(global_reset), .x, .y, .r, .g, .b,
                .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
                .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

    assign LEDR[0] = player_drawer_done;

endmodule
