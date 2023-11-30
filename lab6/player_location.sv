module player_location 
    #(
        parameter SCREEN_WIDTH = 640,
        parameter SCREEN_HEIGHT = 480,
        parameter SCREEN_PADDING_X = 10,
        parameter SCREEN_PADDING_Y = 10,
        parameter PLAYER_WIDTH = 32,
        parameter PLAYER_HEIGHT = 32,
        parameter START_X = 320,
        parameter START_Y = 454, 
        parameter STEP_SIZE_X = 1,
        parameter STEP_SIZE_Y = 1
    )
    (
    input logic CLOCK_50, enable, global_reset, left, right,
    output logic [9:0] out_x,
    output logic [8:0] out_y
    );
    logic [9:0] x;
    logic [8:0] y;

    always_ff @(posedge CLOCK_50) begin : pixel_tracker
        if (global_reset) begin
            x = START_X;
        end else if (enable) begin
            if (left && !right && x > (PLAYER_WIDTH / 2) + SCREEN_PADDING_X) begin
                x = x - STEP_SIZE_X;
            end
            else if (!left && right && x < SCREEN_WIDTH - (PLAYER_WIDTH / 2) -
                                           SCREEN_PADDING_X) begin
                x = x + STEP_SIZE_X;
            end
        end
    end

    assign out_x = x;
    assign out_y = START_Y;
endmodule

module player_location_tb ();
    logic CLOCK_50, enable, global_reset, left, right, updated_location;
    logic [9:0] out_x;
    logic [8:0] out_y;

    player_location dut(.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    integer i;
    initial begin
        global_reset <= 1; enable <= 1; left <= 0; right <= 0; @(posedge CLOCK_50);
        global_reset <= 0; enable <= 1; left <= 1; right <= 0; @(posedge CLOCK_50);

        for (i = 0; i < 16; i++) begin
                    @(posedge CLOCK_50);
        end


        $stop;
    end

endmodule