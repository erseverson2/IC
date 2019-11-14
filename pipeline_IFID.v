/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 13, 2019 */

module pipeline_IFID(
	input clk,
	input rst,
	input stall,
	input [15:0] PC_out_to_IFID,
	output [15:0] PC_out_from_IFID,
	input [15:0] imem_data_out_to_IFID,
	output [15:0] imem_data_out_from_IFID);

	wire stall_n;
	assign stall_n = ~stall;

	Bit16Reg iPC_reg_IFID(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(PC_out_to_IFID), .reg_out(PC_out_from_IFID));
	Bit16Reg IMEM_reg_IFID(.clk(clk), .rst(rst), .write_en(stall_n), .reg_in(imem_data_out_to_IFID), .reg_out(imem_data_out_from_IFID));

endmodule
