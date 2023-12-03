module color_converter 
    #(
    parameter BACKGROUND_COLOR = 24'h0,
    parameter PLAYER_COLOR = 24'h34CA7F,
    parameter LASER_COLOR = 24'he91e63,
    parameter ENEMY_COLOR = 24'hFFFFFF, 
    parameter TITLE_TEXT_COLOR = 24'hFFB11E
    )
    (
    input logic [3:0] which_color,
    // output logic [23:0] color
    output logic [7:0] r, g, b
);

    logic [23:0] my_color;
    // logic [7:0] test_color;
    assign {r, g, b} = my_color;

    // assign test_color = PLAYER_COLOR[23:16];

    always_comb begin
        case(which_color)
            0:
                my_color = BACKGROUND_COLOR;
            1: 
                my_color = PLAYER_COLOR;
            2:
                my_color = LASER_COLOR;
            3:  
                my_color = ENEMY_COLOR;
            4: 
                my_color = TITLE_TEXT_COLOR;
            default:
                my_color = 24'b0;
        endcase
    end
endmodule

module color_converter_tb ();
    logic clock;
    logic [3:0] which_color;
    logic [7:0] r, g, b;

    color_converter dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        which_color <= 0; @(posedge clock);
        which_color <= 1; @(posedge clock);
        which_color <= 2; @(posedge clock);
        which_color <= 3; @(posedge clock);
        which_color <= 4; @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        $stop;
    end

endmodule