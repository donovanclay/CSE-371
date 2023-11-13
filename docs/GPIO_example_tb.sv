/* Test bench for the GPIO example module */
module GPIO_example_tb ();
   // inout pins must be connected to a wire type
   wire  [35:0] V_GPIO;
   // additional logic required to simulate inout pins
   logic [35:0] V_GPIO_in;
   logic [35:0] V_GPIO_dir;  // 1 = input, 0 = output

   // set up tristate buffers for inout pins
   genvar i;
   generate
      for (i = 0; i < 36; i++) begin : gpio
         assign V_GPIO[i] = V_GPIO_dir[i] ? V_GPIO_in[i] : 1'bZ;
      end
   endgenerate

   GPIO_example dut (.V_GPIO);

   initial begin
      // you only need to set the pin directions once
      V_GPIO_dir[24]  = 1'b1;
      V_GPIO_dir[35]  = 1'b0;
      // manipulate the V_GPIO input bits indirectly through V_GPIO_in
      V_GPIO_in[24] = 1'b1; #50;
      V_GPIO_in[24] = 1'b0; #50;
   end
endmodule  // GPIO_example_tb

