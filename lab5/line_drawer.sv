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
    
    logic y0vsy1; 

    assign y0vsy1 = y0 < y1;

    enum {s_start, s_draw, s_done} ps, ns;

    always_comb begin
        case (ps)
            s_start: ns = s_draw;

            s_draw: if (my_x0 < my_x1) ns = s_draw;
                    else ns = s_done;

            s_done: ns = s_done;
        endcase
    end

    assign done = (ps == s_done);

    always_comb begin
        if (is_steep) begin
            if (y0 < y1) begin
                y_step = (delta_x < delta_y) ? 1 : 0;
            end else begin
                y_step = (delta_x > delta_y) ? 1 : 0;
            end
        end else begin
            y_step = (y0 < y1) ? 1 : 0;
        end
    end

    always_ff @(posedge clk) begin
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

        if (ps == s_draw) begin
            if (my_x0 <= my_x1) begin
                if (is_steep) begin
                    x <= my_y0;
                    y <= my_x0;
                end else begin
                    x <= my_x0;
                    y <= my_y0;
                end
                my_x0 <= my_x0 + 1'b1;
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
        reset <= 1;    x0 <= 100; y0 <= 50; x1 <= 200; y1 <= 50;      @(posedge clk); 
        // reset <= 1;    x0 <= 305; y0 <= 54; x1 <= 387; y1 <= 420;      @(posedge clk);
        reset <= 0;                                             @(posedge clk);

        for (i = 0; i < 102; i++) begin
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

endmodule