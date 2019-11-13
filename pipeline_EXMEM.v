module pipeline_EXMEM(clk, rst, WB, mem, flagsIn, reg_data_in, rt_in, DstReg_in, MemWrite, MemRead, flagsOut, to_WBReg, reg_data_out, rt_out, DstReg_out);

	input clk;
	input rst;
	input [3:0] WB;
	input [1:0] mem;
	input [2:0] flagsIn;
	input [15:0] reg_data_in;
	input [15:0] rt_in;
	input [3:0] DstReg_in;

	output MemWrite, MemRead;
	output [2:0]flagsOut;
	output [3:0] to_WBReg;
	output [15:0] reg_data_out;
	output [15:0] rt_out;
	output [3:0] DstReg_out; 
	
	// MemWrite
	Bit2Reg memReg(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(mem), .reg_out({MemWrite, MemRead}));
	// WB
	Bit4Reg to_WB(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(WB), .reg_out(to_WBReg));
	// alu data out
	Bit16Reg Alu_out(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(reg_data_in), .reg_out(reg_data_out));
	// register rt to SW
	Bit16Reg SW_reg(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(rt_in), .reg_out(rt_out));
	// dest reg
	Bit4Reg FWD_reg_ExMem(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(DstReg_in), .reg_out(DstReg_out));
	// flags reg
	Bit3Reg flags(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(flagsIn), .reg_out(flagsOut));
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
