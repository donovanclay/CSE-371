/* mux for use in homework 4.
 *
 * Inputs:
 *   D0    - first signal bit
 *   D1    - second signal bit
 *   Sel   - input selector
 *   Clock - should be connected to a 50 MHz clock
 *
 * Outputs:
 *   Q     - selected signal bit
 */
module muxdff (D0, D1, Sel, Clock, Q);
	input D0, D1, Sel, Clock;
	output reg Q;

	always @(posedge Clock)
	 	if (!Sel)
			Q <= D0;
		else 
			Q <= D1;
		
endmodule

