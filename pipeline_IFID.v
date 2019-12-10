/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 13, 2019 */

module pipeline_IFID(
	input clk,
	input rst,
	input stall,
	input flush,
	input Halt,
	output Halt_ID,
	input [15:0] PC_out_to_IFID,
	output [15:0] PC_out_from_IFID,
	input [15:0] imem_data_out_to_IFID,
	output [15:0] imem_data_out_from_IFID,
	input [15:0] PC_in,
	input [15:0] PC_out);

	wire stall_n;
	assign stall_n = ~stall;

	wire [15:0] imem_reg;
	assign imem_reg = flush ? 16'h0000 : imem_data_out_to_IFID;

	Bit16Reg iPC_reg_IFID(.clk(clk), .rst(rst), .write_en(stall_n | flush), .reg_in(flush ? 16'h0000 : PC_Out_to_IFID), .reg_out(PC_out_from_IFID));
	Bit16Reg IMEM_reg_IFID(.clk(clk), .rst(rst), .write_en(stall_n | flush), .reg_in(imem_reg), .reg_out(imem_data_out_from_IFID));

	dff iHalt_reg(.q(Halt_ID), .d(flush ? 1'b0 : Halt), .wen(stall_n | flush), .clk(clk), .rst(rst | flush));


	// Fix PCS
	Bit16Reg PC_fwd(.clk(clk), .rst(rst), .write_en(stall_n | flush), .reg_in(flush ? 16'h0000 : PC_in), .reg_out(PC_out));

endmodule
