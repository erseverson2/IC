module pielineID(input clk, input rst, input ALUSRC, input RegWrite, input Reg2Src, input MemtoReg, input MemWrite, input BranchType, input BranchIns, input Halt, input LBIns, input PCtoReg);



dff ALUSRC(q, d, wen, clk, rst);
dff RegWrite(q, d, wen, clk, rst);
dff Reg2Src(q, d, wen, clk, rst);
dff MemtoReg(q, d, wen, clk, rst);
dff MemWrite(q, d, wen, clk, rst);
dff BranchType(q, d, wen, clk, rst);
dff BranchIns(q, d, wen, clk, rst);
dff Halt(q, d, wen, clk, rst);
dff LBIns(q, d, wen, clk, rst);
dff PCtoReg(q, d, wen, clk, rst);

Register_4_Bit( input clk, input rst, input [3:0] D, input WriteReg, input ReadEnable1, input ReadEnable2, inout [3:0] Bitline1, inout [3:0] Bitline2);
Register_8_Bit(input clk,input rst,input [7:0] D,input WriteReg,input ReadEnable1,input ReadEnable2,inout [7:0] Bitline1,inout [7:0] Bitline2);

Register(input clk, input rst, input [15:0] D, input WriteReg, input ReadEnable1, input ReadEnable2, inout [15:0] Bitline1, inout [15:0] Bitline2);




endmodule
