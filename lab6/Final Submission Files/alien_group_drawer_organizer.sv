module alien_group_drawer_organizer #(
    parameter NUM_ALIENS = 20,
    parameter ALIEN_GROUP_START_X = 320,
    parameter ALIEN_GROUP_START_Y = 105,
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21,
    parameter ALIEN_GAP = 21,
    parameter BACKGROUND_COLOR_NUM = 0,
    parameter ENEMY_COLOR_NUM = 3
) (
    input logic clock, global_reset, group_reset, alien_alive,
    input logic [9:0] input_group_x,
    input logic [8:0] input_group_y,
    output logic [9:0] out_x,
    output logic [8:0] out_y,
    output logic [3:0] out_color,
    output logic [4:0] which_alien,
    output logic group_done, valid
);
    logic [9:0] alien_center_x;
    logic [8:0] alien_center_y;
    logic alien_draw_reset;
    logic reset;

    logic drawer_reset, drawer_done;

    alien_drawer #(
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT)
    ) drawer (
        .clock(clock),
        .reset(drawer_reset),
        .alien_center_x(alien_center_x),
        .alien_center_y(alien_center_y),
        .out_x(out_x),
        .out_y(out_y),
        .valid(valid),
        .done(drawer_done)
    );

    alien_group_drawer #(
        .NUM_ALIENS(NUM_ALIENS),
        .ALIEN_GROUP_START_X(ALIEN_GROUP_START_X),
        .ALIEN_GROUP_START_Y(ALIEN_GROUP_START_Y),
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT),
        .ALIEN_GAP(ALIEN_GAP),
        .BACKGROUND_COLOR_NUM(BACKGROUND_COLOR_NUM),
        .ENEMY_COLOR_NUM(ENEMY_COLOR_NUM)
    ) group_drawer (
        .clock(clock),
        .global_reset(global_reset),
        .reset(group_reset),
        .alien_alive(alien_alive),
        .alien_draw_done(drawer_done),
        .input_group_x(input_group_x),
        .input_group_y(input_group_y),
        .out_center_x(alien_center_x),
        .out_center_y(alien_center_y),
        .color(out_color),
        .out_which_alien(which_alien),
        .done(group_done),
        .alien_draw_reset(drawer_reset)
    );

endmodule

module alien_group_drawer_organizer_tb ();
    logic clock, global_reset, group_reset, alien_alive, group_done, valid;
    logic [9:0] input_group_x, out_x;
    logic [8:0] input_group_y, out_y;
    logic [3:0] out_color;
    logic [4:0] which_alien;

    logic write;

    assign write = (!group_done && valid);

    logic [9:0] alien_group_x;
    logic [8:0] alien_group_y;
    logic [17:0] count;

    always_ff @(posedge clock) begin
        if (global_reset)
            count = 0;
        if (count == (2** 16) - 1)
            count = 0;
        else 
            count = count + 1;
    end

    assign enable = (count == (2** 16) - 1);

    alien_group_location alien_group_location1 (
        .clock(clock),
        .enable(enable),
        .global_reset(global_reset),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y)
    );

    alien_group_drawer_organizer dut (
        .clock(clock),
        .global_reset(global_reset),
        .group_reset(group_done),
        .alien_alive(alien_alive),
        .input_group_x(alien_group_x),
        .input_group_y(alien_group_y),
        .out_x(out_x),
        .out_y(out_y),
        .out_color(out_color),
        .which_alien(which_alien),
        .group_done(group_done),
        .valid(valid)
    );

     parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        global_reset <= 1; alien_alive <= 1;        @(posedge clock);
        global_reset <= 0;          @(posedge clock);
        for (i = 0; i < 32 * 33 * 17; i++) begin
            @(posedge clock);
        end

        for (i = 0; i < 32 * 32 * 18 * 10; i++) begin
            @(posedge clock);
        end
        $stop;
    end
endmodule