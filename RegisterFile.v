/* Author: Ilhan Bok feat. Jun Lin Tan, little thanks to E.Severson
   Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Oct. 1, 2019 */

module ReadDecoder_4_16(
input [3:0] RegId, 
output [15:0] Wordline);


Shifter_reg s1(.Shift_Out(Wordline), .Shift_In(16'h0001), .Shift_Val(RegId), .Mode(1'b0));

endmodule

module WriteDecoder_4_16(
input [3:0] RegId, 
input RegWrite, 
output [15:0] Wordline);
wire [15:0] s_out;

	Shifter_reg s1(.Shift_Out(s_out), .Shift_In(16'h0001), .Shift_Val(RegId), .Mode(1'b0));
	assign Wordline = (RegWrite) ? s_out : 16'b0;

endmodule

module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2,
				Bitline1, Bitline2);

	input clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2;
	inout Bitline1, Bitline2;

	wire q;

	dff iFLOP(.q(q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));
	
	assign Bitline1 = ReadEnable1 ? q : 1'bZ;
 	assign Bitline2 = ReadEnable2 ? q : 1'bZ;
	
endmodule

module Register(
input clk,
input rst,
input [15:0] D,
input WriteReg,
input ReadEnable1,
input ReadEnable2,
inout [15:0] Bitline1,
inout [15:0] Bitline2);

BitCell bc0(.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));
BitCell bc1(.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
BitCell bc2(.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
BitCell bc3(.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]));
BitCell bc4(.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]));
BitCell bc5(.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]));
BitCell bc6(.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]));
BitCell bc7(.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]));
BitCell bc8(.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]));
BitCell bc9(.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]));
BitCell bc10(.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]));
BitCell bc11(.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]));
BitCell bc12(.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]));
BitCell bc13(.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]));
BitCell bc14(.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]));
BitCell bc15(.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));

endmodule

module RegisterFile(
input clk, input rst, 
input [3:0] SrcReg1, 
input [3:0] SrcReg2, 
input [3:0] DstReg, 
input WriteReg, 
input [15:0] DstData, 
inout [15:0] SrcData1, 
inout [15:0] SrcData2);

wire [15:0] src_dec1, src_dec2, write_dec;
ReadDecoder_4_16 R_D1(.RegId(SrcReg1), .Wordline(src_dec1));
ReadDecoder_4_16 R_D2(.RegId(SrcReg2), .Wordline(src_dec2));
WriteDecoder_4_16 W_D(.RegId(DstReg), .RegWrite(WriteReg), .Wordline(write_dec));

Register Reg_0(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[0]), .ReadEnable1(src_dec1[0]), .ReadEnable2(src_dec2[0]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_1(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[1]), .ReadEnable1(src_dec1[1]), .ReadEnable2(src_dec2[1]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_2(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[2]), .ReadEnable1(src_dec1[2]), .ReadEnable2(src_dec2[2]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_3(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[3]), .ReadEnable1(src_dec1[3]), .ReadEnable2(src_dec2[3]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_4(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[4]), .ReadEnable1(src_dec1[4]), .ReadEnable2(src_dec2[4]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_5(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[5]), .ReadEnable1(src_dec1[5]), .ReadEnable2(src_dec2[5]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_6(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[6]), .ReadEnable1(src_dec1[6]), .ReadEnable2(src_dec2[6]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_7(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[7]), .ReadEnable1(src_dec1[7]), .ReadEnable2(src_dec2[7]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_8(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[8]), .ReadEnable1(src_dec1[8]), .ReadEnable2(src_dec2[8]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_9(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[9]), .ReadEnable1(src_dec1[9]), .ReadEnable2(src_dec2[9]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_10(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[10]), .ReadEnable1(src_dec1[10]), .ReadEnable2(src_dec2[10]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_11(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[11]), .ReadEnable1(src_dec1[11]), .ReadEnable2(src_dec2[11]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_12(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[12]), .ReadEnable1(src_dec1[12]), .ReadEnable2(src_dec2[12]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_13(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[13]), .ReadEnable1(src_dec1[13]), .ReadEnable2(src_dec2[13]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_14(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[14]), .ReadEnable1(src_dec1[14]), .ReadEnable2(src_dec2[14]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register Reg_15(.clk(clk),.rst(rst), .D(DstData), .WriteReg(write_dec[15]), .ReadEnable1(src_dec1[15]), .ReadEnable2(src_dec2[15]), .Bitline1(SrcData1), .Bitline2(SrcData2));


endmodule

