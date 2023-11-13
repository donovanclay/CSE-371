/* top-level divider circuit for use in homework 4.
 *
 * Inputs:
 *   Clock  - should be connected to a 50 MHz clock
 *   Resetn - negated reset (resets on 0)
 *   s      - signal to start running
 *   LA     - signal to load DataA into left shift register
 *   EB     - signal to enable negated register to store DataB
 *   DataA  - numerator/dividend number for division
 *   DataB  - denominator/divisor number for division
 *
 * Outputs:
 *   R     - remainder from division
 *   Q     - quotient from division
 *   Done  - signal circut finished dividing
 *
 * Parameters:
 *   n     - bit-length of input nums
 *   logn  - log base 2 of the bit-length of input nums
 */
module divider (Clock, Resetn, s, LA, EB, DataA, DataB, R, Q, Done);
	parameter n = 8, logn = 3;
	input Clock, Resetn, s, LA, EB;
	input [n-1:0] DataA, DataB;
	output [n-1:0] R, Q;
	output reg Done;
	//CHANGE: some regs changed to wires to get the module to compile
	wire Cout, z, R0;
	wire [n-1:0] DataR;
	wire [n:0] Sum;
	reg [1:0] y, Y;
	wire [n-1:0] A, B;
	wire [logn-1:0] Count;
	reg EA, Rsel, LR, ER, ER0, LC, EC;
	integer k;

// control circuit

	parameter S1 = 2'b00, S2 = 2'b01, S3 = 2'b10;

	always @(s, y,  z)
	begin: State_table
		case (y)
			S1:	if (s == 0) Y = S1;
				else Y = S2;
			S2:	if (z == 0) Y = S2;
				else Y = S3;
			S3:	if (s == 1) Y = S3;
				else Y = S1;
			default: Y = 2'bxx;
		endcase
	end

	always @(posedge Clock, negedge Resetn)
	begin: State_flipflops
		if (Resetn == 0)
			y <= S1;
		else
			y <= Y;
	end

	always @(y, s, Cout, z)
	begin: FSM_outputs
		// defaults
		LR = 0; ER = 0; ER0 = 0; LC = 0; EC = 0; EA = 0;
		Rsel = 0; Done = 0;
		case (y)
			S1:	begin
					LC = 1; ER = 1;
					if (s == 0)
					begin
						LR = 1; ER0 = 0;
					end
					else
					begin
						LR = 0; EA = 1; ER0 = 1;
					end
				end
			S2:	begin
					Rsel = 1; ER = 1; ER0 = 1; EA = 1;
					if (Cout) LR = 1;
					else LR = 0;
					if (z == 0) EC = 1;
					else EC = 0;
				end
			S3:	Done = 1;
		endcase
	end

//datapath circuit

	regne RegB (DataB, Clock, Resetn, EB, B);
		defparam RegB.n = n;
	shiftlne ShiftR (DataR, LR, ER, R0, Clock, R);
		defparam ShiftR.n = n;
	muxdff FF_R0 (1'b0, A[n-1], ER0, Clock, R0);
	shiftlne ShiftA (DataA, LA, EA, Cout, Clock, A);
		defparam ShiftA.n = n;
	assign Q = A;
	//CHANGE: down counter starts at max, not zero
	downcount Counter (3'b111, Clock, EC, LC, Count);
		defparam Counter.n = logn;

	assign z = (Count == 0);
	assign Sum = {1'b0, R[n-2:0], R0} + {1'b0, ~B} + 1;
	assign Cout = Sum[n];
	
	// define the n 2-to-1 multiplexers
	assign DataR = Rsel ? Sum : 0;

endmodule
