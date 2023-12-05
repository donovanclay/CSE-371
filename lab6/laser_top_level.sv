module laser_top_level #(
    
) (
    input logic clock, enable, global_reset, fire,
    input logic [9:0] x,
    input logic [8:0] y,
    output logic [9:0] x,
    output logic [8:0] y
);

    logic laser_manager_reset, laser_alive, laser_manager_done;

    enum {s_start, s_laser_alive} ps, ns;

    always_comb begin
        case (ps)
            s_start:
                if (fire)
                    ns = s_laser_alive;
                else
                    ns = s_start;
            s_laser_alive:
                if (laser_manager_done)
                    ns = s_laser_alive;
                else
                    ns = s_start;
        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == s_start) begin
            if (fire)
                laser_manager_reset = 1;
        end

        if (ps == s_laser_alive) begin
            laser_manager_reset = 0;
        end
    end

endmodule