module FlagRegister(flag_reg_input, flag_reg_output, clk, wen, rst);

output [2:0] flag_reg_output;
input [2:0] flag_reg_input;
input clk, rst, wen;

dff bit0(.q(flag_reg_output[0]), .d(flag_reg_input[0]), .wen(wen), .clk(clk), .rst(rst));
dff bit1(.q(flag_reg_output[1]), .d(flag_reg_input[1]), .wen(wen), .clk(clk), .rst(rst));
dff bit2(.q(flag_reg_output[2]), .d(flag_reg_input[2]), .wen(wen), .clk(clk), .rst(rst));

endmodule
