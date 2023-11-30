module combined_rams (
    input logic clock,
    input logic [18:0] vga_address, write_address,
    input logic [23:0] vga_write_data, write_data,
    input logic vga_write_enable, write_enable,
    output logic [23:0] vga_read_data, read_data
    );

    logic [4:0][23:0] vga_read_data_arr, read_data_arr;
    logic [4:0] vga_write_enable_arr, write_enable_arr;
    logic [3:0] vga_which_memory, write_which_memory;
    assign vga_which_memory = (vga_address / (2 ** 17));
    assign write_which_memory = (write_address / (2 ** 17));

    // ram inputs
    assign vga_write_enable_arr = (vga_write_enable) ? 
                                  2 ** (vga_address / (2 ** 17)) : 5'b00000;
    assign write_enable_arr = (write_enable) ? 2 ** (write_address / (2 ** 17))
                                             : 5'b00000;

    genvar i;
    generate
        for (i = 0; i < 1; i++) begin : rams
            display_ram my_display_ram(
                .address_a(write_address[16:0]),
                .address_b(vga_address[16:0]),
                .clock(clock),
                .data_a(vga_write_data),
                .data_b(write_data),
                .wren_a(vga_write_enable_arr[i]),
                .wren_b(write_enable_arr[i]),
                .q_a(vga_read_data_arr[i]),
                .q_b(read_data_arr[i])
            );
        end
    endgenerate

    // rom outputs
    assign vga_read_data = vga_read_data_arr[vga_address / (2 ** 17)];
    assign read_data = read_data_arr[write_address / (2 ** 17)];

endmodule

`timescale 1ps/1ps
module combined_rams_tb ();
    logic clock;
    logic [9:0] x;
    logic [8:0] y;
    logic [18:0] vga_address, write_address;
    logic [23:0] vga_write_data, write_data;
    logic vga_write_enable, write_enable;
    logic [23:0] vga_read_data, read_data;

    combined_rams dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clock <= 0;
        forever #(CLOCK_PERIOD/2) clock <= ~clock;
    end

    assign vga_address = 640 * y + x;

    integer i;
    initial begin
        vga_write_enable = 1'b0; y = 479; x = 639;          @(posedge clock);
        write_address = 307199; write_data = {24{1'b1}}; write_enable = 1'b1;    @(posedge clock);
        for (i = 0; i < 5; i++) begin
                            @(posedge clock);
        end
        // vga_write_enable = 1'b0; vga_address = 306080; write_enable = 1'b0;  @(posedge clock);
        // vga_write_enable = 1'b0; vga_address = 306081;          @(posedge clock);
        // for (i = 0; i < 4; i++) begin
        //                     @(posedge clock);
        // end
        
        $stop;
    end
    
endmodule