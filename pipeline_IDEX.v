/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 13, 2019 */

module pipeline_IDEX(
	input clk, 
	input rst,
	input [2:0] ALU_Opcode,
	input ALUSrc, 
	input RegWrite, 
	input MemtoReg, 
	input MemWrite,
	input MemRead, 
	input Reg2Src,
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
	input [3:0] LLB_LHB_to_IDEX,
	//output nop_IDEX,
	output Reg2Src_EX,
	output [4:0]to_EXReg,
	output [1:0] to_Mem,
	output [3:0] to_WBReg,
	output [15:0] reg_data1_from_IDEX,
	output [15:0] reg_data2_from_IDEX,
	output [3:0] SrcReg1_in_from_IDEX,
	output [3:0] SrcReg2_in_from_IDEX,
	output [3:0] DstReg1_in_from_IDEX,
	output [3:0] LLB_LHB_from_IDEX); 

	wire [4:0] EXReg;
	wire [3:0] WBReg;
	wire [1:0] mem;
	wire [15:0] data1;
	wire [15:0] data2; 

	wire [3:0] srcReg1; 
	wire [3:0] srcReg2; 
	wire [3:0] dstReg1;
	wire [3:0] loadByte1;

	// nop forwarding (allows for one-cycle stall)
	//dff iNOP(.q(nop_IDEX), .d(nop), .wen(1'b1), .clk(clk), .rst(rst));
	dff iReg2Src(.q(Reg2Src_EX), .d((nop ? 1'b0 : Reg2Src)), .wen(1'b1), .clk(clk), .rst(rst));

	// @ EX
	assign EXReg = nop ? 5'h00 : {ALU_Opcode, ALUSrc, LBIns};
	Bit5Reg to_EX(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(EXReg), .reg_out(to_EXReg));

	// @ MEM
	assign mem = nop ? 2'b00 : {MemWrite, MemRead};
	Bit2Reg MemReg(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(mem), .reg_out(to_Mem));

	// @ WB
	assign WBReg = nop ? 6'h00 :{RegWrite, MemtoReg, PCtoReg, Halt};
	Bit4Reg to_WB(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(WBReg), .reg_out(to_WBReg));
	// @ RegWrite
	// @ MemtoReg
	// @ PCtoReg
	// @ Halt

	// Numbers used in ALU
	assign data1 = nop ? 16'h0000 : reg_data1_to_IDEX;
	assign data2 = nop ? 16'h0000 : reg_data2_to_IDEX;
	Bit16Reg RF1_reg_IDEX(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(data1), .reg_out(reg_data1_from_IDEX));
	Bit16Reg RF2_reg_IDEX(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(data2), .reg_out(reg_data2_from_IDEX));
	// Reg used
	assign srcReg1 = nop ? 4'h0: SrcReg1_in_to_IDEX;
	assign srcReg2 = nop ? 4'h0: SrcReg2_in_to_IDEX;
	assign dstReg1 = nop ? 4'h0: DstReg1_in_to_IDEX;
	assign loadByte1 = nop ? 4'h0: LLB_LHB_to_IDEX;
	Bit4Reg FWD_reg1_IDEX(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(srcReg1), .reg_out(SrcReg1_in_from_IDEX));
	Bit4Reg FWD_reg2_IDEX(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(srcReg2), .reg_out(SrcReg2_in_from_IDEX));
	Bit4Reg FWD_reg3_IDEX(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(dstReg1), .reg_out(DstReg1_in_from_IDEX));
	Bit4Reg FWD_llhb_IDEX(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(loadByte1), .reg_out(LLB_LHB_from_IDEX));

endmodule
