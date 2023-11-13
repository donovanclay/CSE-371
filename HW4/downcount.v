/* down counting circuit for use in homework 4.
 *
 * Inputs:
 *   R     - input to load into counter
 *   Clock - should be connected to a 50 MHz clock
 *   E     - enable signal to decrement count
 *   L     - signal to load new value
 *
 * Outputs:
 *   Q     - current count
 *
 * Parameters:
 *   n     - bit-length of count
 */
module downcount (R, Clock, E, L, Q);
	parameter n = 8;
	input [n-1:0] R;
	input Clock, L, E;
	output reg [n-1:0] Q;

	always @(posedge Clock)
		if (L)
			Q <= R;
		else if (E)
			Q <= Q - 1;

endmodule
