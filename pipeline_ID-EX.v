module pielineID(
	input clk, 
	input rst, 
	input ALUSRC, 
	input RegWrite, 
	input MemtoReg, 
	input MemWrite, 
	//input BranchType, 
	//input BranchIns, 
	input Halt, 
	input LBIns, 
	input PCtoReg,
	input nop, // Noop = 1 means insert Noop
	input [15:0] reg_data1_to_IDEX,
	input [15:0] reg_data2_to_IDEX,
	input [3:0] SrcReg1_in_to_IDEX,
	input [3:0] SrcReg2_in_to_IDEX,
	input [3:0] DstReg1_in_to_IDEX,
	output [1:0]to_EXReg,
	output to_Mem,
	output [3:0] to_WBReg,
	output [3:0] reg_data1_from_IDEX,
	output [3:0] reg_data2_from_IDEX,
	output [3:0] SrcReg1_in_from_IDEX,
	output [3:0] SrcReg2_in_from_IDEX,
	output [3:0] DstReg1_in_from_IDEX); 

	wire [1:0] EXReg;
	wire [5:0] WBReg;
	wire mem;
	wire data1;
	wire data2; 

	wire srcReg1; 
	wire srcReg2; 
	wire dstReg1;

	// @ EX
	assign EXReg = nop ? 2'b00 :{ALUSRC, LBIns};
	Bit2Reg to_EX(.clk(clk), .rst(rst), .write_en(1), .reg_in(EXReg), .reg_out(to_EXReg));

	// @ MEM
	assign mem = nop ? 1'b0 : MemWrite;
	dff MemReg(.q(to_Mem), .d(mem), .wen(1), .clk(clk), .rst(rst));

	// @ WB
	assign WBReg = nop ? 6'h00 :{RegWrite, MemtoReg, PCtoReg, Halt};
	Bit4Reg to_WB(.clk(clk), .rst(rst_reg), .write_en(1), .reg_in(WBReg), .reg_out(to_WBReg));
	// @ RegWrite
	// @ MemtoReg
	// @ PCtoReg
	// @ Halt

	// Numbers used in ALU
	assign data1 = nop ? 16'h0000 : reg_data1_to_IDEX;
	assign data2 = nop ? 16'h0000 : reg_data2_to_IDEX;
	Bit16Reg RF1_reg_IDEX(.clk(clk), .rst(rst), .write_en(1), .reg_in(data1), .reg_out(reg_data1_from_IDEX));
	Bit16Reg RF2_reg_IDEX(.clk(clk), .rst(rst), .write_en(1), .reg_in(data2), .reg_out(reg_data2_from_IDEX));
	// Reg used
	assign srcReg1 = nop ? 4'h0: SrcReg1_in_to_IDEX;
	assign srcReg2 = nop ? 4'h0: SrcReg2_in_to_IDEX;
	assign dstReg1 = nop ? 4'h0: DstReg1_in_to_IDEX;
	Bit4Reg FWD_reg1_IDEX(.clk(clk), .rst(rst), .write_en(1), .reg_in(SrcReg1_in_to_IDEX), .reg_out(SrcReg1_in_from_IDEX));
	Bit4Reg FWD_reg2_IDEX(.clk(clk), .rst(rst), .write_en(1), .reg_in(SrcReg2_in_to_IDEX), .reg_out(SrcReg2_in_from_IDEX));
	Bit4Reg FWD_reg3_IDEX(.clk(clk), .rst(rst), .write_en(1), .reg_in(DstReg1_in_to_IDEX), .reg_out(DstReg1_in_from_IDEX));



Bit6Reg (clk, rst, write_en, reg_in, reg_out);


endmodule
