// `ifndef ALIEN_X
// `define ALIEN_X(WHICH_ALIEN) \
//     group_x + (((WHICH_ALIEN % 5) - 2) * (ALIEN_WIDTH + ALIEN_GAP))
// `endif

// `ifndef ALIEN_Y
// `define ALIEN_Y(WHICH_ALIEN) \
//     group_y - (3 * (ALIEN_GAP / 2) + ALIEN_HEIGHT / 2) + ((WHICH_ALIEN / 5) * (ALIEN_HEIGHT + ALIEN_GAP))
// `endif

module alien_hit 
 #(
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21,
    parameter ALIEN_GAP = 21,
    parameter LASER_WIDTH = 5
 )
 (
    input logic [9:0] laser_x, group_x,
    input logic [8:0] laser_y, group_y,
    input logic [4:0] which_alien,
    output logic hit_alien
);

    logic [9:0] x_res, neg_x_res, alien_x;
    logic [8:0] y_res, neg_y_res, alien_y;

    assign alien_x = group_x + (((which_alien % 5) - 2) * (ALIEN_WIDTH + ALIEN_GAP));
    assign alien_y = group_y - (3 * (ALIEN_GAP / 2) + ALIEN_HEIGHT / 2) + ((which_alien / 5) * (ALIEN_HEIGHT + ALIEN_GAP));

    assign x_res = laser_x - alien_x;
    assign y_res = laser_y - alien_y;
    assign neg_x_res = -1 * x_res;
    assign neg_y_res = -1 * y_res;

    logic bool1, bool2;
    
    assign bool1 = (x_res <= ALIEN_WIDTH / 2 || neg_x_res <= ALIEN_WIDTH / 2 + LASER_WIDTH / 2);
    assign bool2 = (y_res <= ALIEN_HEIGHT / 2 || neg_y_res <= ALIEN_HEIGHT / 2);

    always_comb begin
        if (bool1 && bool2)
            hit_alien = 1;
        else
            hit_alien = 0;
    end
    

endmodule  // hit_alien

module alien_hit_tb();
    logic clock, hit_alien;
    logic [9:0] laser_x, group_x;
    logic [8:0] laser_y, group_y;
    logic [4:0] which_alien;

    alien_hit dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        group_x <= 200; group_y <= 200; laser_x <= 322; laser_y <= 280; which_alien <= 19; @(posedge clock);

        for (i = 0; i < 5; i++) begin
            @(posedge clock);
        end

        $stop;
    end

endmodule

