module DE1_SoC1 (
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
    parameter ALIEN_GROUP_PADDING_LEFT = 152;
    parameter ALIEN_GROUP_PADDING_RIGHT = 488;

    parameter ALIEN_WIDTH = 40;
    parameter ALIEN_HEIGHT = 21;
    parameter ALIEN_GAP = 21;

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
    parameter ALIEN_COLOR = 24'hFFFFFF;
    parameter ALIEN_COLOR_NUM = 3;
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
    
    logic [20:0] count2;
    logic enable2;
    always_ff @(posedge CLOCK_50) begin
        if (global_reset)
            count2 = 0;
        else 
            count2 = count2 + 1;
    end
    

    assign enable2 = (count2 == (2** 21) - 1);
    
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
    assign alien_alive_wren = 0;

    aliens_alive_ram alive_ram (
        .address(which_alien),
        .clock(CLOCK_50),
        .data(alien_alive_write_data),
        .wren(alien_alive_wren),
        .q(alien_alive_read_data)
    );
    
    // assign LEDR[0] = alien_alive_read_data;
    // assign alien_alive_read_data = 1;

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
    // assign LEDR[8:2] = alien_group_y[8:2];


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
    
    logic [9:0] in_group_x;
    logic [8:0] in_group_y;
    enum {s_lower, s_higher} ps1, ns1;
    always_comb begin
        case (ps1)
            s_lower:
                ns1 = s_higher;
            s_higher:
                ns1 = s_lower;
        endcase
    end
    
    always_ff @(posedge CLOCK_50) begin
        if (ps1 == s_lower) begin
            in_group_x = 200;
            in_group_y = 300;
        end
        else begin
            in_group_x = 200;
            in_group_y = 250;
        end
    end
    
    
    
    always_ff @(posedge CLOCK_50) begin
        if (global_reset)
            ps1 = s_higher;
        else if (enable2)
            ps1 = ns1;
        else
            ps1 = ps1;
    end

    logic alien_group_drawer_done, alien_group_global_reset, alien_group_reset, valid;
    
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
    ) (
        .clock(CLOCK_50),
        .global_reset(global_reset),
        .group_reset(alien_group_drawer_done),
        // .group_reset(1'b0),
        .alien_alive(alien_alive_read_data),
        .input_group_x(alien_group_x),
        .input_group_y(alien_group_y),
        .out_x(alien_out_x),
        .out_y(alien_out_y),
        .out_color(alien_out_color),
        .which_alien(which_alien),
        .group_done(alien_group_drawer_done),
        .valid(alien_valid)
    );

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
        .ALIEN_COLOR(ALIEN_COLOR)
    )
    my_cc (
        .which_color(color_converter_in),
        .r(r),
        .g(g),
        .b(b)
    );

    assign vga_address = SCREEN_WIDTH * y + x;
    assign vga_write_enable = 1'b0;
    assign write_address = SCREEN_WIDTH * alien_out_y +
                          alien_out_x;
    assign write_data = alien_out_color;
    // assign write_enable = (!player_drawer_done);
    assign write_enable = (!alien_group_drawer_done) && alien_valid;

    video_driver #(.WIDTH(SCREEN_WIDTH), .HEIGHT(SCREEN_HEIGHT))
        v1 (.CLOCK_50, .reset(global_reset), .x, .y, .r, .g, .b,
                .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
                .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

    // assign LEDR[0] = player_drawer_done;
    assign LEDR[1] = alien_group_drawer_done;

endmodule
