module alien_group_location
    #(
        parameter SCREEN_WIDTH = 640,
        parameter SCREEN_HEIGHT = 480,
        parameter ALIEN_GROUP_START_X = 320,
        parameter ALIEN_GROUP_START_Y = 105, 
        parameter ALIEN_GROUP_PADDING_LEFT = 89,
        parameter ALIEN_GROUP_PADDING_RIGHT = 454
    )
    (
        input logic clock, enable, global_reset,
        // output logic [18:0] location
        output logic [9:0] alien_group_x,
        output logic [8:0] alien_group_y
    );

    logic [9:0] x;
    logic [8:0] y;

    // assign location = y * (SCREEN_WIDTH) + x;
    assign alien_group_x = x;
    assign alien_group_y = y;

    enum {s_global_reset, s_going_left, s_going_right} ps, ns;

    always_comb begin
        case (ps)
            s_global_reset:
                ns = s_going_left;

            s_going_left: begin
                if (x == ALIEN_GROUP_PADDING_LEFT)
                    ns = s_going_right;
                else
                    ns = s_going_left;
            end

            s_going_right: begin
                if (x == ALIEN_GROUP_PADDING_RIGHT) 
                    ns = s_going_left;
                else
                    ns = s_going_right;
            end
        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == global_reset) begin
            x = ALIEN_GROUP_START_X;
            y = ALIEN_GROUP_START_Y;
        end
        if (enable) begin
            if (ns == s_going_left && ps != s_global_reset) begin
                x = x - 1;
            end
            if (ns == s_going_right) begin
                x = x + 1;
            end
            if ((ps == s_going_left && ns == s_going_right) ||
                (ps == s_going_right && ns == s_going_left)) begin
                y = y + 1;
            end
        end else begin
            x = x;
            y = y;
        end
        
    end

    always_ff @(posedge clock) begin
        if (global_reset)
            ps = s_global_reset;
        else if (enable) begin
            ps = ns;
        end else
            ps = ps;
    end

endmodule // alien_group_location

module alien_group_location_tb ();
    logic clock, enable, global_reset;
    logic [18:0] location;
    logic [9:0] alien_group_x;
    logic [8:0] alien_group_y;

    // assign {x, y} = location;

    alien_group_location dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i, j;
    initial begin
        global_reset <= 1; enable <= 0;
        global_reset <= 0;
        for (j = 0; j < 300 * 4; j++) begin
            enable <= 1;    @(posedge clock);
            enable <= 0;    
            for (i = 0; i < 8; i++) begin
                            @(posedge clock);
            end
        end


        $stop;
    end

endmodule // alien_group_location_tb