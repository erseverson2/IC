module pielineMEMWB(clk, rst, WB, reg_data_in, dmem_in, DstReg_in, RegWrite, MemtoReg, PCtoReg, Halt, reg_data_out, dmem_out, DstReg_out);
	input clk;
	input rst;
	input [3:0]WB;
	input [15:0] reg_data_in;
	input [15:0] dmem_in;
	input [3:0] DstReg_in;
	output RegWrite;
	output MemtoReg;
	output PCtoReg;
	output Halt;
	output [15:0] reg_data_out;
	output [15:0] dmem_out;
	output [3:0] DstReg_out; 

	wire [3:0]to_WBReg;
	
	// WB
	Bit4Reg to_WB(.clk(clk), .rst(rst), .write_en(1), .reg_in(WB), .reg_out(to_WBReg));
	// alu data out
	Bit16Reg Alu_out(.clk(clk), .rst(rst), .write_en(1), .reg_in(reg_data_in), .reg_out(reg_data_out));
	// dmem data out
	Bit16Reg dmem_out_Reg(.clk(clk), .rst(rst), .write_en(1), .reg_in(dmem_in), .reg_out(dmem_out));
	// dest reg
	Bit4Reg FWD_reg_ExMem(.clk(clk), .rst(rst), .write_en(1), .reg_in(DstReg_in), .reg_out(DstReg_out));

	assign RegWrite = to_WBReg[3];
	assign MemtoReg = to_WBReg[2];
	assign PCtoReg = to_WBReg[1];
	assign Halt = to_WBReg[0];

	// WB:
	// @ RegWrite
	// @ MemtoReg
	// @ PCtoReg
	// @ Halt
	// @ BranchType
	// @ BranchIns
endmodule