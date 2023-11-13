module counter_datapath(clk, reset, clear_result, load_a, right_shift, done, incr, A_in, A_out, result);

    input logic clk, reset, clear_result, load_a, right_shift, done, incr;
    input logic [7:0] A_in;
    output logic [7:0] A_out;
    output logic [2:0] result;

    logic [7:0] A;
    logic [2:0] count;

    assign A_out = A;

    always_ff @(posedge clk) begin
        if(clear_result) begin
            count <= 0;
            result <= 0;
        end

        if(load_a) begin
            A <= A_in;
        end

        if (incr) begin
           count <= count + 1'b1;
        end
        
        if (right_shift) begin
            A <= A >> 1;
        end
        
        if (done) begin
            result <= count;
        end
    end

endmodule
