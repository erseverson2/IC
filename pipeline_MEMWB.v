module pipeline_MEMWB(clk, rst, WB, reg_data_in, dmem_in, DstReg_in, RegWrite, MemtoReg, PCtoReg, Halt, reg_data_out, dmem_out, DstReg_out, PC_in, PC_out, nop, is_noop_in, is_noop_out);
	input clk;
	input rst;
	input [3:0]WB;
	input [15:0] reg_data_in;
	input [15:0] dmem_in;
	input [3:0] DstReg_in;
	input nop;
	output RegWrite;
	output MemtoReg;
	output PCtoReg;
	output Halt;
	output [15:0] reg_data_out;
	output [15:0] dmem_out;
	output [3:0] DstReg_out; 

	wire [3:0]to_WBReg;
	
	// WB
	Bit4Reg to_WB(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(nop ? 4'h0 : WB), .reg_out(to_WBReg));
	// alu data out
	Bit16Reg Alu_out(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(nop ? 16'h0000 : reg_data_in), .reg_out(reg_data_out));
	// dmem data out
	Bit16Reg dmem_out_Reg(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(nop ? 16'h0000 : dmem_in), .reg_out(dmem_out));
	// dest reg
	Bit4Reg FWD_reg_ExMem(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(nop ? 4'h0 : DstReg_in), .reg_out(DstReg_out));

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

	// Fix PCS
	input [15:0] PC_in;
	output [15:0] PC_out;
	Bit16Reg PC_fwd(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(nop ? 16'h0000 : PC_in), .reg_out(PC_out));

	// Detect when to avoid regwrite
	input is_noop_in;
	output is_noop_out;
	dff iNOP(.q(is_noop_out), .d(nop ? 1'b0 : is_noop_in), .wen(1'b1), .clk(clk), .rst(rst));
endmodule
