module counter_controller(CLOCK_50, reset, start, A_out, done, incr, load_a, right_shift, clear_result);

    input logic CLOCK_50, reset, start;
    input logic [7:0] A_out;
    output logic done, incr, load_a, right_shift, clear_result;

    enum {S1, S2, S3} ps, ns;

    always_comb begin
        case(ps)
            S1:	if(start)	ns = S2;
                    else			ns = S1;
                    
            S2:	if(A_out == 0)	ns = S3;
                    else			ns = S2;
                    
            S3:	if(~start)	ns = S1;
                    else			ns = S3;
        endcase
    end

    always_ff @(posedge CLOCK_50) begin
        if(reset) 	ps <= S1;
        else			ps <= ns;
    end

    // mealy outputs
    assign load_a = (ps == S1) && (start == 0);
    assign incr = (ps == S2) && (A_out[0] == 1);

    // moore outputs
    assign clear_result = (ps == S1);
    assign right_shift = (ps == S2);
    assign done = (ps == S3);

endmodule