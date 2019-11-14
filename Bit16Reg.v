module Bit16Reg (clk, rst, write_en, reg_in, reg_out);
	input clk, rst, write_en;
	input [15:0] reg_in;
	output [15:0] reg_out;

	dff R0(.q(reg_out[0]), .d(reg_in[0]), .wen(write_en), .clk(clk), .rst(rst));
	dff R1(.q(reg_out[1]), .d(reg_in[1]), .wen(write_en), .clk(clk), .rst(rst));
	dff R2(.q(reg_out[2]), .d(reg_in[2]), .wen(write_en), .clk(clk), .rst(rst));
	dff R3(.q(reg_out[3]), .d(reg_in[3]), .wen(write_en), .clk(clk), .rst(rst));
	dff R4(.q(reg_out[4]), .d(reg_in[4]), .wen(write_en), .clk(clk), .rst(rst));
	dff R5(.q(reg_out[5]), .d(reg_in[5]), .wen(write_en), .clk(clk), .rst(rst));
	dff R6(.q(reg_out[6]), .d(reg_in[6]), .wen(write_en), .clk(clk), .rst(rst));
	dff R7(.q(reg_out[7]), .d(reg_in[7]), .wen(write_en), .clk(clk), .rst(rst));
	dff R8(.q(reg_out[8]), .d(reg_in[8]), .wen(write_en), .clk(clk), .rst(rst));
	dff R9(.q(reg_out[9]), .d(reg_in[9]), .wen(write_en), .clk(clk), .rst(rst));
	dff R10(.q(reg_out[10]), .d(reg_in[10]), .wen(write_en), .clk(clk), .rst(rst));
	dff R11(.q(reg_out[11]), .d(reg_in[11]), .wen(write_en), .clk(clk), .rst(rst));
	dff R12(.q(reg_out[12]), .d(reg_in[12]), .wen(write_en), .clk(clk), .rst(rst));
	dff R13(.q(reg_out[13]), .d(reg_in[13]), .wen(write_en), .clk(clk), .rst(rst));
	dff R14(.q(reg_out[14]), .d(reg_in[14]), .wen(write_en), .clk(clk), .rst(rst));
	dff R15(.q(reg_out[15]), .d(reg_in[15]), .wen(write_en), .clk(clk), .rst(rst));

endmodule
