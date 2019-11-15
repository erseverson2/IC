module Bit2Reg (clk, rst, write_en, reg_in, reg_out);
	input clk, rst, write_en;
	input [1:0] reg_in;
	output [1:0] reg_out;

	dff R0(.q(reg_out[0]), .d(reg_in[0]), .wen(write_en), .clk(clk), .rst(rst));
	dff R1(.q(reg_out[1]), .d(reg_in[1]), .wen(write_en), .clk(clk), .rst(rst));

endmodule
