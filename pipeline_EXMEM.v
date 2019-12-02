module pipeline_EXMEM(clk, rst, WB, mem, flagsIn, Flags_Set, reg_data_in, rt_in, DstReg_in, SrcReg2_in, MemWrite, MemRead, flagsOut, to_WBReg, reg_data_out, rt_out, DstReg_out, SrcReg2_out, ALU_data_in, ALU_data_out, stall);

	input clk;
	input rst;
	input Flags_Set;
	input [3:0] WB;
	input [1:0] mem;
	input [2:0] flagsIn;
	input [15:0] reg_data_in;
	input [15:0] rt_in;
	input [15:0] ALU_data_in;
	input [3:0] DstReg_in;
	input [3:0] SrcReg2_in;
	input stall;

	output MemWrite, MemRead;
	output [2:0]flagsOut;
	output [3:0] to_WBReg;
	output [15:0] reg_data_out;
	output [15:0] rt_out;
	output [15:0] ALU_data_out;
	output [3:0] DstReg_out;
	output [3:0] SrcReg2_out;
	
	// MemWrite
	Bit2Reg memReg(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(stall ? 2'b00 : mem), .reg_out({MemWrite, MemRead}));
	// WB
	Bit4Reg to_WB(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(stall ? 4'h0 : WB), .reg_out(to_WBReg));
	// alu data out
	Bit16Reg Alu_out(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(stall ? 16'h0000 : reg_data_in), .reg_out(reg_data_out));
	// register rt to SW
	Bit16Reg SW_reg(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(stall ? 16'h0000 : rt_in), .reg_out(rt_out));
	// dest reg
	Bit4Reg FWD_reg_ExMem(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(stall ? 4'h0 : DstReg_in), .reg_out(DstReg_out));
	// ALU value reg
	Bit16Reg Alu_value(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(stall ? 16'h0000 : ALU_data_in), .reg_out(ALU_data_out));
	// Mem2Mem FWD reg
	Bit4Reg FWD_src_ExMem(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(stall ? 4'h0 : SrcReg2_in), .reg_out(SrcReg2_out));
	// flags reg
	Bit3Reg flags(.clk(clk), .rst(rst), .write_en(Flags_Set), .reg_in(stall ? 3'b000 : flagsIn), .reg_out(flagsOut));
	// MEM:
	// @ MemWrite
	//
	// WB:
	// @ RegWrite
	// @ MemtoReg
	// @ PCtoReg
	// @ Halt
	// * BranchType
	// * BranchIns
endmodule
