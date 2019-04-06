module Term_BCDcal(SW, HEX0, HEX1, HEX4, HEX5, HEX6, HEX7);

	input [16:0] SW; // 16: mode select, 15:8: left num, 7:0: right num, 
	output reg [6:0] HEX0, HEX1; // output segment
	output reg [6:0] HEX4, HEX5; // right segment
	output reg [6:0] HEX6, HEX7; // left segment
	parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111; parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100;
	parameter Seg4 = 7'b100_1100; parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010; parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;
	
	reg [7:0] left, right;
	reg [7:0] out;
	reg [7:0] convRight;
	
	Convert conv (SW[7:0], convRight);
	
	always@(*)
	begin
		left = SW[15:8];
		case(SW[16])
			1'b1: right = convRight;
			default: right = SW[7:0];
		endcase
	end
	
endmodule

// calculate whatever it is
module Calculator(outBCD, leftBCD, rightBCD);

	input leftBCD, rightBCD;
	output outBCD;
	
endmodule

// 4 bit adder
module Full_Adder(sumBCD, leftBCD, rightBCD);

	input leftBCD, rightBCD;
	output sumBCD;

endmodule

// get 9's and 10's complement of subtractBCD
module Convert(convertedBCD, subtractBCD);

	input subtractBCD;
	output convertedBCD;
	wire [7:0] temp;
	
	assign temp[7:4] = 4'b1111; // 9's complement
	assign temp[3:0] = 4'b1111; // 10's complement
	assign convertedBCD = temp;
	
endmodule
