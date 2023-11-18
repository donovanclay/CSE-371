/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *
 */
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
    input logic clk, reset;
    input logic [10:0]	x0, y0, x1, y1;
    output logic done;
    output logic [10:0]	x, y;

    /* You'll need to create some registers to keep track of things
        * such as error and direction.
        */
    logic signed [11:0] error, error_tracker;  // example - feel free to change/delete
    logic [10:0] my_x0, my_x1, my_y0, my_y1, delta_x, delta_y;
    logic y_step;
    
    assign delta_x = (x1 > x0) ? x1 - x0 : x0 - x1;
    assign delta_y = (y1 > y0) ? y1 - y0 : y0 - y1;

    logic error_bool, is_steep;
    assign is_steep = (delta_y > delta_x);
    assign error_tracker = (is_steep) ? error + delta_x : error + delta_y;
    assign error_bool = (error_tracker >= 0);

    enum {s_start, s_draw, s_done} ps, ns;

    always_comb begin
        case (ps)
            s_start: ns = s_draw;

            // if we finished drawing the line go to the done state
            // otherwise keep drawing
            s_draw: if (my_x0 < my_x1) ns = s_draw;
                    else ns = s_done;

            s_done: ns = s_done;
        endcase
    end

    assign done = (ps == s_done);

    // this logic directly translates from the algorithm outlined in the lab spec
    always_comb begin
        if (is_steep) begin
            if (y0 < y1) begin
                y_step = (x0 > x1) ? 0 : 1;
            end else begin
                y_step = (x0 < x1) ? 0 : 1;
            end
        end else begin
            if (x0 < x1) begin
                y_step = (y0 < y1) ? 1 : 0;
            end
            else begin
                y_step = (y0 < y1) ? 0 : 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        // this logic is outlined in the lab spec
        // if the line is steep we have to swap x and y
        // after the swap, if the x0 is greater than x1, then we 
        // have to swape x0 and x1, and y0 and y1
        if (ps == s_start) begin
            if (is_steep && y0 > y1) begin
                my_x0 = y1;
                my_x1 = y0;
                my_y0 = x1;
                my_y1 = x0;
            end else if (is_steep) begin
                my_x0 = y0;
                my_x1 = y1;
                my_y0 = x0;
                my_y1 = x1;
            end else if (x0 > x1) begin
                my_x0 = x1;
                my_x1 = x0;
                my_y0 = y1;
                my_y1 = y0;
            end else begin
                my_x0 = x0;
                my_x1 = x1;
                my_y0 = y0;
                my_y1 = y1;
            end
            error <= (is_steep) ? - (delta_y / 2) : - (delta_x / 2);
        end

        // this logic follows from the algorithm outline in the lab spec
        if (ps == s_draw) begin

            // if there are still points along the line to draw.
            if (my_x0 <= my_x1) begin

                // if the line is steep then we previously swapped x and y, 
                // so we need to swap it back.
                if (is_steep) begin
                    x <= my_y0;
                    y <= my_x0;
                end else begin
                    x <= my_x0;
                    y <= my_y0;
                end

                // increment x
                my_x0 <= my_x0 + 1'b1;

                // if we need to increment y, increment y and reset error 
                // so we will know the next time we need to increment y
                if (error_bool) begin
                    my_y0 <= (y_step) ?  my_y0 + 1 : my_y0 - 1;
                    error <= (is_steep) ? error + delta_x - delta_y : error + delta_y - delta_x;
                end else begin
                    my_y0 <= my_y0;
                    error <= (is_steep) ? error + delta_x : error + delta_y;
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            ps <= s_start;
            
        end
        else begin
            ps <= ns;
        end
    end

endmodule  // line_drawer

// horizontal line
module line_drawer_horizontal_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 100; y0 <= 50; x1 <= 150; y1 <= 50;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 54; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule // line_drawer_horizontal_tb

module line_drawer_vertical_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 100; y0 <= 50; x1 <= 100; y1 <= 100;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 53; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_vertical_tb


module line_drawer_left_up_gradual_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 100; y0 <= 80; x1 <= 80; y1 <= 90;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 53; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_left_up_gradual_tb

module line_drawer_left_up_steep_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 60; y0 <= 80; x1 <= 50; y1 <= 120;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 44; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_left_up_steep_tb

module line_drawer_right_up_gradual_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 60; y0 <= 80; x1 <= 90; y1 <= 90;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 44; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_right_up_gradual_tb

module line_drawer_right_up_steep_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 60; y0 <= 80; x1 <= 70; y1 <= 120;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 44; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_right_up_steep_tb

module line_drawer_left_down_gradual_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 90; y0 <= 90; x1 <= 60; y1 <= 85;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 44; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_left_down_gradual_tb

module line_drawer_left_down_steep_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 90; y0 <= 120; x1 <= 80; y1 <= 70;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 54; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_left_down_steep_tb

module line_drawer_right_down_gradual_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 60; y0 <= 20; x1 <= 90; y1 <= 10;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 44; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_right_down_gradual_tb

module line_drawer_right_down_steep_tb();
    logic clk, reset, done;
    logic [10:0] x0, y0, x1, y1, x, y;

    line_drawer dut (clk, reset, x0, y0, x1, y1, x, y, done);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    integer i;
    initial begin
        reset <= 1;    x0 <= 80; y0 <= 120; x1 <= 90; y1 <= 70;      @(posedge clk); 
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 55; i++) begin
                    @(posedge clk);
        end
        $stop;
    end

endmodule  // line_drawer_right_down_steep_tb