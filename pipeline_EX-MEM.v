module pielineEXMem(clk, rst, nop, WB, mem, flagsIn, reg_data_in, DstReg_in, MemWrite, flagsOut, to_WBReg, reg_data_out, DstReg_out);

	input clk;
	input rst;
	input nop; // Noop = 1 means insert Noop
	input WB;
	input mem;
	input [2:0] flagsIn;
	input [15:0] reg_data_in;
	input [3:0] DstReg_in;

	output MemWrite;
	output [2:0]flagsOut;
	output [3:0] to_WBReg;
	output [3:0] reg_data_out;
	output [3:0] DstReg_out; 
	
	// MemWrite
	dff memReg(.q(MemWrite), .d(mem), .wen(1'b1), .clk(clk), .rst(rst));
	// WB
	Bit4Reg to_WB(.clk(clk), .rst(rst), .write_en(1), .reg_in(WB), .reg_out(to_WBReg));
	// alu data out
	Bit16Reg Alu_out(.clk(clk), .rst(rst), .write_en(1), .reg_in(reg_data_in), .reg_out(reg_data_out));
	// dest reg
	Bit4Reg FWD_reg_ExMem(.clk(clk), .rst(rst), .write_en(1), .reg_in(DstReg_in), .reg_out(DstReg_out));
	// flags reg
	Bit3Reg flags(.clk(clk), .rst(rst), .write_en(1), .reg_in(flagsIn), .reg_out(flagsOut));
	// MEM:
	// @ MemWrite
	//
	// WB:
	// @ RegWrite
	// @ MemtoReg
	// @ PCtoReg
	// @ Halt
	// @ BranchType
	// @ BranchIns
endmodule