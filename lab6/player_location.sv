module player_location (
    input logic CLOCK_50, enable, reset, left, right,
    output logic [9:0] out_x,
    output logic [8:0] out_y
);
    logic [9:0] x;
    logic [8:0] y;

    always_ff @(posedge CLOCK_50) begin : pixel_tracker
        if (reset) begin
            x = 320;
        end else if (enable) begin
            if (left && !right)
                x = x - 5;
            else if (!left && right)
                x = x + 5;
        end
    end

    assign out_x = x;
    assign out_y = 26;
endmodule

module player_location_tb ();
    logic CLOCK_50, enable, reset, left, right;
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
        reset <= 1; enable <= 1; left <= 0; right <= 0; @(posedge CLOCK_50);
        reset <= 0; enable <= 1; left <= 1; right <= 0; @(posedge CLOCK_50);

        for (i = 0; i < 16; i++) begin
                    @(posedge CLOCK_50);
        end


        $stop;
    end

endmodule