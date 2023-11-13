/* This example shows how to control a LED on the breadboard using a switch 
 * on the breadboard. The components on the breadboard are wired according 
 * to Step 5. Specifically, V_GPIO[24] (JP1 pin #24) is connected to a   
 * switch and V_GPIO[35] (JP1 pin #35) is connected to an LED.
 */
module GPIO_example (V_GPIO);
	// SW and KEY cannot be declared if V_GPIO is declared on LabsLand
	inout logic [35:0] V_GPIO;
	// Assign V_GPIO[35] (LED) to V_GPIO[24] (switch)
	assign V_GPIO[35] = V_GPIO[24];
endmodule  // GPIO_example
