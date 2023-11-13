/* negated register for use in homework 4.
 *
 * Inputs:
 *   R      - input to register
 *   Clock  - should be connected to a 50 MHz clock
 *   Resetn - negated reset (resets on 0)
 *   E      - enable signal to load new input into register
 *
 * Outputs:
 *   Q     - current stored value
 *
 * Parameters:
 *   n     - bit-length of register
 */
module regne (R, Clock, Resetn, E, Q);
	parameter n = 8;
	input [n-1:0] R;
	input Clock, Resetn, E;
	output reg [n-1:0] Q;

	always @(posedge Clock, negedge Resetn)
		if (Resetn == 0)
			Q <= 0;
		else if (E)
			Q <= R;

endmodule

