/* Author: Ilhan Bok
   Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Oct. 1, 2019 */

module ReadDecoder_4_16(RegId, Wordline);
	
	input[3:0] RegId;
	output[15:0] Wordline;
	
	Decoder_4_16 iDEC(.RegId(RegId), .Wordline(Wordline));
	
endmodule

module WriteDecoder_4_16(RegId, WriteReg, Wordline);
	
	input[3:0] RegId;
	input WriteReg;
	output[15:0] Wordline;
	
	wire[15:0] Wordline_dec;
	
	assign Wordline = Wordline_dec & {16{WriteReg}};
	
	Decoder_4_16 iDEC(.RegId(RegId), .Wordline(Wordline_dec));
	
endmodule

module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2,
				Bitline1, Bitline2);

	input clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2;
	inout Bitline1, Bitline2;

	wire q;

	dff iFLOP(.q(q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));
	
	Bitline1 = ReadEnable1 ?
				WriteEnable ? D :
				q : 1'bz;
	Bitline2 = ReadEnable2 ? 
				WriteEnable ? D :
				q : 1'bz;

endmodule

module Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2,
				Bitline1, Bitline2);
				
	input clk, rst, WriteReg, ReadEnable1, ReadEnable2;
	input[15:0] D;
	
	inout[15:0] Bitline1, Bitline2;
	
	BitCell iBit0(.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));
	BitCell iBit1(.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
	BitCell iBit2(.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
	BitCell iBit3(.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]));
	BitCell iBit4(.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]));
	BitCell iBit5(.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]));
	BitCell iBit6(.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]));
	BitCell iBit7(.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]));
	BitCell iBit8(.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]));
	BitCell iBit9(.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]));
	BitCell iBit10(.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]));
	BitCell iBit11(.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]));
	BitCell iBit12(.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]));
	BitCell iBit13(.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]));
	BitCell iBit14(.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]));
	BitCell iBit15(.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg),
					.ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
					.Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));
endmodule

module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData,
					SrcData1, SrcData2);
		
	input clk, rst, WriteReg;
	input[3:0] SrcReg1, SrcReg2, DstReg;
	input[15:0] DstData;
	
	inout[15:0] SrcData1, SrcData2;
	
	wire[15:0] SrcOneHot1, SrcOneHot2, DstOneHot;
	
	ReadDecoder_4_16 OneHot1(.RegId(SrcReg1), .Wordline(SrcOneHot1));
	ReadDecoder_4_16 OneHot2(.RegId(SrcReg2), .Wordline(SrcOneHot2));
	
	WriteDecoder_4_16 WriteHot1(.RegId(DstReg), .WriteReg(WriteReg),
								.Wordline(DstOneHot));
	
	Register iReg0(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[0]),
					.ReadEnable1(SrcOneHot1[0]), .ReadEnable2(SrcOneHot2[0]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg1(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[1]),
					.ReadEnable1(SrcOneHot1[1]), .ReadEnable2(SrcOneHot2[1]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg2(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[2]),
					.ReadEnable1(SrcOneHot1[2]), .ReadEnable2(SrcOneHot2[2]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg3(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[3]),
					.ReadEnable1(SrcOneHot1[3]), .ReadEnable2(SrcOneHot2[3]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg4(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[4]),
					.ReadEnable1(SrcOneHot1[4]), .ReadEnable2(SrcOneHot2[4]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg5(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[5]),
					.ReadEnable1(SrcOneHot1[5]), .ReadEnable2(SrcOneHot2[5]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg6(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[6]),
					.ReadEnable1(SrcOneHot1[6]), .ReadEnable2(SrcOneHot2[6]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg7(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[7]),
					.ReadEnable1(SrcOneHot1[7]), .ReadEnable2(SrcOneHot2[7]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg8(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[8]),
					.ReadEnable1(SrcOneHot1[8]), .ReadEnable2(SrcOneHot2[8]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg9(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[9]),
					.ReadEnable1(SrcOneHot1[9]), .ReadEnable2(SrcOneHot2[9]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg10(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[10]),
					.ReadEnable1(SrcOneHot1[10]), .ReadEnable2(SrcOneHot2[10]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg11(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[11]),
					.ReadEnable1(SrcOneHot1[11]), .ReadEnable2(SrcOneHot2[11]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg12(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[12]),
					.ReadEnable1(SrcOneHot1[12]), .ReadEnable2(SrcOneHot2[12]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg13(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[13]),
					.ReadEnable1(SrcOneHot1[13]), .ReadEnable2(SrcOneHot2[13]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg14(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[14]),
					.ReadEnable1(SrcOneHot1[14]), .ReadEnable2(SrcOneHot2[14]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
	Register iReg15(.clk(clk), .rst(rst), .D(DstData), .WriteReg(DstOneHot[15]),
					.ReadEnable1(SrcOneHot1[15]), .ReadEnable2(SrcOneHot2[15]), 
					.Bitline1(SrcData1), .Bitline2(SrcData2));
		
endmodule

module Decoder_4_16(RegId, res);

	input[3:0] RegId;
	output[15:0] Wordline;
	
	assign Wordline[0] = ~regId[3] & ~regId[2] & ~regId[1] & ~regId[0],
			Wordline[1] = ~regId[3] & ~regId[2] & ~regId[1] & regId[0],
			Wordline[2] = ~regId[3] & ~regId[2] & regId[1] & ~regId[0],
			Wordline[3] = ~regId[3] & ~regId[2] & regId[1] & regId[0],
			Wordline[4] = ~regId[3] & regId[2] & ~regId[1] & ~regId[0],
			Wordline[5] = ~regId[3] & regId[2] & ~regId[1] & regId[0],
			Wordline[6] = ~regId[3] & regId[2] & regId[1] & ~regId[0],
			Wordline[7] = ~regId[3] & regId[2] & regId[1] & regId[0],
			Wordline[8] = regId[3] & ~regId[2] & ~regId[1] & ~regId[0],
			Wordline[9] = regId[3] & ~regId[2] & ~regId[1] & regId[0],
			Wordline[10] = regId[3] & ~regId[2] & regId[1] & ~regId[0],
			Wordline[11] = regId[3] & ~regId[2] & regId[1] & regId[0],
			Wordline[12] = regId[3] & regId[2] & ~regId[1] & ~regId[0],
			Wordline[13] = regId[3] & regId[2] & ~regId[1] & regId[0],
			Wordline[14] = regId[3] & regId[2] & regId[1] & ~regId[0],
			Wordline[15] = regId[3] & regId[2] & regId[1] & regId[0];

endmodule