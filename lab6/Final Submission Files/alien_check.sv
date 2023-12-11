module alien_check #(
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21,
    parameter ALIEN_GAP = 21,
    parameter LASER_WIDTH = 5
) (
    input logic clock,
    input logic alien_check_reset, alien_alive,
    input logic [9:0] input_laser_x, alien_group_x,
    input logic [8:0] input_laser_y, alien_group_y,
    output logic [4:0] which_alien_out,
    output logic done, alien_killed
);
    logic [4:0] which_alien;
    logic [9:0] laser_x;
    logic [8:0] laser_y;
    logic alien_hit;

    enum {s_start, s_check, s_killed, s_none_killed} ps, ns;

    assign which_alien_out = which_alien;
    assign alien_killed = (ps == s_killed);
    assign done = (ps == s_killed || ps == s_none_killed);
    

    always_comb begin
        case (ps)
            s_start: begin
                if (alien_alive) begin
                    if (alien_hit)
                        ns = s_killed;
                    else
                        ns = s_check;
                end
                else
                    ns = s_check;
            end

            s_check: begin
                if (alien_alive) begin
                    if (alien_hit)
                        ns = s_killed;
                    else if (which_alien == 0)
                        ns = s_none_killed;
                    else
                        ns = s_check;
                end else begin
                    if (which_alien == 0)
                        ns = s_none_killed;
                    else
                        ns = s_check;
                end
            end

            s_killed:
                ns = s_killed;

            s_none_killed:
                ns = s_none_killed;
        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == s_start) begin
            laser_x = input_laser_x;
            laser_y = input_laser_y;
            which_alien = 19;
        end

        if (ns == s_check && ps != s_start)
            which_alien = which_alien - 1;

    end

    always_ff @(posedge clock) begin
        if (alien_check_reset)
            ps = s_start;
        else
            ps = ns;
    end

    alien_hit #(
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT),
        .ALIEN_GAP(ALIEN_GAP),
        .LASER_WIDTH(LASER_WIDTH)
    ) my_alien_hit (
        .laser_x(laser_x),
        .laser_y(laser_y),
        .group_x(alien_group_x),
        .group_y(alien_group_y),
        .which_alien(which_alien),
        .hit_alien(alien_hit)
    );

endmodule  // alien_check

module alien_check_tb();
    logic clock;
    logic alien_check_reset, alien_alive;
    logic [9:0] input_laser_x, alien_group_x;
    logic [8:0] input_laser_y, alien_group_y;
    logic [4:0] which_alien_out;
    logic done, alien_killed;

    alien_check dut1 (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    integer i;
    initial begin
        alien_check_reset <= 1; alien_alive <= 1;
        input_laser_x <= 261 + (19); input_laser_y <= 280; alien_group_x <= 200; alien_group_y <= 200; @(posedge clock);
        alien_check_reset <= 0; @(posedge clock);

        for (i = 0; i < 25; i++) begin
            @(posedge clock);
        end

        $stop;
    end

endmodule

