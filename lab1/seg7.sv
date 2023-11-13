/*
 * seg7 is the module which controls the HEX displays. It displays the current value of count
 * on HEX0 and HEX1. When the count is 16 it also displays "FULL" on HEX5-HEX2. When the count
 * is 0 is also displays "CLEAR" on HEX5-HEX1.
 */
module seg7 (
	input logic [4:0] count, 
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
	);
	
	parameter OFF = 7'b1111111;
	parameter C = 7'b1000110;
	parameter L = 7'b1000111;
	parameter E = 7'b0000110;
	parameter A = 7'b0001000; 
	parameter R = 7'b1001110; 
	parameter F = 7'b0001110;
	parameter U = 7'b1000001;
	parameter num0 = 7'b1000000;
	parameter num1 = 7'b1111001;
	parameter num2 = 7'b0100100;
	parameter num3 = 7'b0110000;
	parameter num4 = 7'b0011001;
	parameter num5 = 7'b0010010;
	parameter num6 = 7'b0000011;
	parameter num7 = 7'b1111000;
	parameter num8 = 7'b0000000;
	parameter num9 = 7'b0011000;
	
	// This case statement sets the values of the HEX displays based of the current value of count.	
	always_comb begin
		case (count)
			5'b00000: begin
					HEX0 = num0;
					HEX1 = R;
					HEX2 = A;
					HEX3 = E;
					HEX4 = L;
					HEX5 = C;
				end
			5'b00001: begin
					HEX0 = num1;
					HEX1 = OFF;
					HEX2 = OFF;
					HEX3 = OFF;
					HEX4 = OFF;
					HEX5 = OFF;
				end
			5'b00010: begin
					HEX0 = num2;
					HEX1 = OFF;
					HEX2 = OFF;
					HEX3 = OFF;
					HEX4 = OFF;
					HEX5 = OFF;
				end
			5'b00011: begin
					HEX0 = num3;
					HEX1 = OFF;
					HEX2 = OFF;
					HEX3 = OFF;
					HEX4 = OFF;
					HEX5 = OFF;
				end
			5'b00100: begin
				HEX0 = num4;
				HEX1 = OFF;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b00101: begin
				HEX0 = num5;
				HEX1 = OFF;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b00110: begin
				HEX0 = num6;
				HEX1 = OFF;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b00111: begin
				HEX0 = num7;
				HEX1 = OFF;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01000: begin
				HEX0 = num8;
				HEX1 = OFF;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01001: begin
				HEX0 = num9;
				HEX1 = OFF;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01010: begin
				HEX0 = num0;
				HEX1 = num1;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01011: begin
				HEX0 = num1;
				HEX1 = num1;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01100: begin
				HEX0 = num2;
				HEX1 = num1;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01101: begin
				HEX0 = num3;
				HEX1 = num1;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01110: begin
				HEX0 = num4;
				HEX1 = num1;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b01111: begin
				HEX0 = num5;
				HEX1 = num1;
				HEX2 = OFF;
				HEX3 = OFF;
				HEX4 = OFF;
				HEX5 = OFF;
			end
			5'b10000: begin
				HEX0 = num6;
				HEX1 = num1;
				HEX2 = L;
				HEX3 = L;
				HEX4 = U;
				HEX5 = F;
			end
			default: begin
				HEX0 = 7'bX;
				HEX1 = 7'bX;
				HEX2 = 7'bX;
				HEX3 = 7'bX;
				HEX4 = 7'bX;
				HEX5 = 7'bX;
			end
		endcase
	end
endmodule // seg7