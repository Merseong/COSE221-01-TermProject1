module Term_BCDcal(SW, HEX0, HEX1, HEX4, HEX5, HEX6, HEX7, LEDG);

	input [16:0] SW; // 16: mode select, 15:8: left num, 7:0: right num, 
	output reg [0:6] HEX0, HEX1; // output segment
	output reg [0:6] HEX4, HEX5; // right segment
	output reg [0:6] HEX6, HEX7; // left segment
	output reg [8:8] LEDG;
	parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111; parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100;
	parameter Seg4 = 7'b100_1100; parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010; parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;
	parameter SegErr = 7'b111_1111;
	
	reg [7:0] left, right;
	wire [7:0] out;
	wire [7:0] conv_right;
	wire cal_err; // carry when calculating
	reg num_err; // error of BCD input
	
	Convert conv (conv_right, SW[7:0]);
	Calculator cal (out, left, right, cal_err);
	
	// setting values
	always@(*)
	begin
		left = SW[15:8];
		case(SW[16])
			1'b1: right = conv_right;
			default: right = SW[7:0];
		endcase
	end
	
	// to detect error of BCD input
	always@(*)
	begin
		if (SW[3:0] > 9 || SW[7:4] > 9 || SW[11:8] > 9 || SW[15:12] > 9)
			num_err = 1'b1;
		else num_err = 1'b0;
	end
	
	// show variables to segment
	always@(*)
	begin
		case({cal_err ^ SW[16], num_err}) // invalid BCD, overflow/underflow detection
			2'b00: begin
				case(out[3:0]) // out segment
					9:HEX0=Seg9;	8:HEX0=Seg8;	7:HEX0=Seg7;	6:HEX0=Seg6;
					5:HEX0=Seg5;	4:HEX0=Seg4;	3:HEX0=Seg3;	2:HEX0=Seg2;			
					1:HEX0=Seg1;	0:HEX0=Seg0;	default: HEX0 = SegErr;
				endcase
				case(out[7:4])
					9:HEX1=Seg9;	8:HEX1=Seg8;	7:HEX1=Seg7;	6:HEX1=Seg6;
					5:HEX1=Seg5;	4:HEX1=Seg4;	3:HEX1=Seg3;	2:HEX1=Seg2;			
					1:HEX1=Seg1;	0:HEX1=Seg0;	default: HEX1 = SegErr;
				endcase
				LEDG[8] = 1'b0;
			end
			2'b10: begin
				HEX0 = SegErr;
				HEX1 = SegErr;
				LEDG[8] = 1'b1;
			end
			default: begin
				HEX0 = SegErr;
				HEX1 = SegErr;
				LEDG[8] = 1'b0;
			end
		endcase
		case(SW[3:0]) // right segment
			9:HEX4=Seg9;    8:HEX4=Seg8;	7:HEX4=Seg7;	6:HEX4=Seg6;
			5:HEX4=Seg5;	4:HEX4=Seg4;	3:HEX4=Seg3;	2:HEX4=Seg2;
			1:HEX4=Seg1;	0:HEX4=Seg0;  	default: HEX4 = SegErr;
		endcase
		case(SW[7:4])
			9:HEX5=Seg9;	8:HEX5=Seg8;	7:HEX5=Seg7;	6:HEX5=Seg6;
			5:HEX5=Seg5;	4:HEX5=Seg4;	3:HEX5=Seg3;	2:HEX5=Seg2;
			1:HEX5=Seg1;	0:HEX5=Seg0;	default: HEX5 = SegErr;
		endcase
		case(SW[11:8]) // left segment
			9:HEX6=Seg9;	8:HEX6=Seg8;	7:HEX6=Seg7;	6:HEX6=Seg6;
			5:HEX6=Seg5;	4:HEX6=Seg4;	3:HEX6=Seg3;	2:HEX6=Seg2;			
			1:HEX6=Seg1;	0:HEX6=Seg0;	default: HEX6 = SegErr;
		endcase
		case(SW[15:12])
			9:HEX7=Seg9;	8:HEX7=Seg8;	7:HEX7=Seg7;	6:HEX7=Seg6;
			5:HEX7=Seg5;	4:HEX7=Seg4;	3:HEX7=Seg3;	2:HEX7=Seg2;			
			1:HEX7=Seg1;	0:HEX7=Seg0;	default: HEX7 = SegErr;
		endcase
	end
	
endmodule

// calculate whatever it is
module Calculator(outBCD, leftBCD, rightBCD, c_err);

	input [7:0] leftBCD, rightBCD;
	output [7:0] outBCD;
	output wire c_err; // if this is 1'b1, return overflow/underflow error
	wire c_out0;
	
	Full_Adder fulladd1(outBCD[3:0], c_out0, leftBCD[3:0], rightBCD[3:0], 1'b0);
	Full_Adder fulladd2(outBCD[7:4], c_err, leftBCD[7:4], rightBCD[7:4], c_out0);
	
endmodule

// 4 bit adder
module Full_Adder(sumBCD, c_out, leftBCD, rightBCD, c_in);

	input [3:0] leftBCD, rightBCD;
	input c_in;
	output reg [3:0] sumBCD;
	output reg c_out;
	wire [3:0] car; // carry
	wire [3:0] temp_out;
	
	assign temp_out[0] = leftBCD[0] ^ rightBCD[0] ^ c_in;
	assign car[0] = ((leftBCD[0] ^ rightBCD[0]) & c_in) | (leftBCD[0] & rightBCD[0]);
	
	assign temp_out[1] = leftBCD[1] ^ rightBCD[1] ^ car[0];
	assign car[1] = ((leftBCD[1] ^ rightBCD[1]) & car[0]) | (leftBCD[1] & rightBCD[1]);
	
	assign temp_out[2] = leftBCD[2] ^ rightBCD[2] ^ car[1];
	assign car[2] = ((leftBCD[2] ^ rightBCD[2]) & car[1]) | (leftBCD[2] & rightBCD[2]);
	
	assign temp_out[3] = leftBCD[3] ^ rightBCD[3] ^ car[2];
	assign car[3] = ((leftBCD[3] ^ rightBCD[3]) & car[2]) | (leftBCD[3] & rightBCD[3]);
	
	always@(*)
	begin
		if (car[3] == 0) begin
			case(temp_out)
				4'b1010: begin // 10
					sumBCD = 4'b0000;
					c_out = 1'b1;
					end
				4'b1011: begin // 11
					sumBCD = 4'b0001;
					c_out = 1'b1;
					end
				4'b1100: begin // 12
					sumBCD = 4'b0010;
					c_out = 1'b1;
					end
				4'b1101: begin // 13
					sumBCD = 4'b0011;
					c_out = 1'b1;
					end
				4'b1110: begin // 14
					sumBCD = 4'b0100;
					c_out = 1'b1;
					end
				4'b1111: begin // 15
					sumBCD = 4'b0101;
					c_out = 1'b1;
					end
				default: begin // 1~9
					sumBCD = temp_out;
					c_out = car[3];
					end
			endcase
		end
		else begin
			case(temp_out)
				4'b0000: sumBCD = 4'b0110; // 16
				4'b0001: sumBCD = 4'b0111; // 17
				4'b0010: sumBCD = 4'b1000; // 18
				4'b0011: sumBCD = 4'b1001; // 19
				default: sumBCD = 4'b0000; // except
			endcase
			c_out = 1'b1;
		end
	end
	
endmodule

// get 9's and 10's complement of subtractBCD
module Convert(outBCD, subtractBCD);

	input [7:0] subtractBCD;
	wire [7:0] convertedBCD;
	output wire [7:0] outBCD;
	wire out;
	
	// 9's complement
	assign convertedBCD[7] = ~subtractBCD[7] & ~subtractBCD[6] & ~subtractBCD[5]; 
	assign convertedBCD[6] = subtractBCD[6] ^ subtractBCD[5];
	assign convertedBCD[5] = subtractBCD[5];
	assign convertedBCD[4] = ~subtractBCD[4];
	// 10's complement
	assign convertedBCD[3] = (~subtractBCD[3] & ~subtractBCD[2]) & ( ~subtractBCD[1] | ~subtractBCD[0] );
	assign convertedBCD[2] = (subtractBCD[2] & ~subtractBCD[1]) | (~subtractBCD[2] & subtractBCD[1] & subtractBCD[0]) | (subtractBCD[2] & subtractBCD[1] & ~subtractBCD[0]);
	assign convertedBCD[1] = (subtractBCD[1] & subtractBCD[0]) | (~subtractBCD[1] & ~subtractBCD[0]);
	assign convertedBCD[0] = subtractBCD[0];
	
	assign outBCD = convertedBCD;
	
endmodule
