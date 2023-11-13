/* left shift register for use in homework 4.
 *
 * Inputs:
 *   R      - input to load into register
 *   L      - signal to load new value
 *   E      - enable signal to shift bits
 *   w      - new bit to shift into register
 *   Clock  - should be connected to a 50 MHz clock
 *
 * Outputs:
 *   Q     - current stored value
 *
 * Parameters:
 *   n     - bit-length of register
 */
module shiftlne (R, L, E, w, Clock, Q);
	parameter n = 4;
	input [n-1:0] R;
	input L, E, w, Clock;
	output reg [n-1:0] Q;
	integer k;

	always @(posedge Clock)
	begin
		if (L)
			Q <= R;
		else if (E)
			begin
			/*
			Provided Code:
				Q[n-1] <= w;
				for (k = n-2; k >= 0; k = k-1)
					Q[k] <= Q[k+1];
			end
			
			CHANGE: The shifter does not append to the most signifcant bit and then shift right.
			It should append to the least significant bit and shift left
			*/
			
			// New code:
				Q[0] <= w;
				for(k = 1; k < n; k = k+1) begin
					Q[k] <= Q[k-1];
				end
			end
	end

endmodule

