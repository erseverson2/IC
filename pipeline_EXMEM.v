module pipeline_EXMEM(clk, rst, WB, mem, flagsIn, Flags_Set, reg_data_in, DstReg_in, SrcReg2_in, MemWrite, MemRead, flagsOut, to_WBReg, reg_data_out, DstReg_out, SrcReg2_out, ALU_data_in, ALU_data_out, stall, PC_in, PC_out, nop, LBIns_EX, LBIns_MEM, is_noop_in, is_noop_out);

	input clk;
	input rst;
	input Flags_Set;
	input [3:0] WB;
	input [1:0] mem;
	input [2:0] flagsIn;
	input [15:0] reg_data_in;
	input [15:0] ALU_data_in;
	input [3:0] DstReg_in;
	input [3:0] SrcReg2_in;
	input stall;
	input nop;
	input LBIns_EX;

	output MemWrite, MemRead;
	output [2:0]flagsOut;
	output [3:0] to_WBReg;
	output [15:0] reg_data_out;
	output [15:0] ALU_data_out;
	output [3:0] DstReg_out;
	output [3:0] SrcReg2_out;
	output LBIns_MEM;

	assign stall_n = ~stall;
	
	// LBIns
	dff iLB(.q(LBIns_MEM), .d(LBIns_EX), .wen(stall_n), .clk(clk), .rst(rst));
	// MemWrite
	Bit2Reg memReg(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(nop ? 2'b00 : mem), .reg_out({MemWrite, MemRead}));
	// WB
	Bit4Reg to_WB(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(nop ? 4'h0 : WB), .reg_out(to_WBReg));
	// alu data out
	Bit16Reg Alu_out(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(nop ? 16'h0000 : reg_data_in), .reg_out(reg_data_out));
	// dest reg
	Bit4Reg FWD_reg_ExMem(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(nop ? 4'h0 : DstReg_in), .reg_out(DstReg_out));
	// ALU value reg
	Bit16Reg Alu_value(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(nop ? 16'h0000 : ALU_data_in), .reg_out(ALU_data_out));
	// Mem2Mem FWD reg
	Bit4Reg FWD_src_ExMem(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(nop ? 4'h0 : SrcReg2_in), .reg_out(SrcReg2_out));
	// flags reg
	Bit3Reg flags(.clk(clk), .rst(rst), .write_en(Flags_Set), .reg_in(flagsIn),/*nop ? 3'b000 : flagsIn),*/ .reg_out(flagsOut));
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


	// Fix PCS
	input [15:0] PC_in;
	output [15:0] PC_out;
	Bit16Reg PC_fwd(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(nop ? 16'h0000 : PC_in), .reg_out(PC_out));

	// Detect when to avoid regwrite
	input is_noop_in;
	output is_noop_out;
	dff iNOP(.q(is_noop_out), .d(nop ? 1'b0 : is_noop_in), .wen(stall_n), .clk(clk), .rst(rst));
endmodule
