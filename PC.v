module PC (clk, rst, write_en, PC_in, PC_out);
	input clk, rst, write_en;
	input [15:0] PC_in;
	output [15:0] PC_out;

	dff PC0(.q(PC_out[0]), .d(PC_in[0]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC1(.q(PC_out[1]), .d(PC_in[1]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC2(.q(PC_out[2]), .d(PC_in[2]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC3(.q(PC_out[3]), .d(PC_in[3]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC4(.q(PC_out[4]), .d(PC_in[4]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC5(.q(PC_out[5]), .d(PC_in[5]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC6(.q(PC_out[6]), .d(PC_in[6]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC7(.q(PC_out[7]), .d(PC_in[7]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC8(.q(PC_out[8]), .d(PC_in[8]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC9(.q(PC_out[9]), .d(PC_in[9]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC10(.q(PC_out[10]), .d(PC_in[10]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC11(.q(PC_out[11]), .d(PC_in[11]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC12(.q(PC_out[12]), .d(PC_in[12]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC13(.q(PC_out[13]), .d(PC_in[13]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC14(.q(PC_out[14]), .d(PC_in[14]), .wen(write_en), .clk(clk), .rst(rst));
	dff PC15(.q(PC_out[15]), .d(PC_in[15]), .wen(write_en), .clk(clk), .rst(rst));

endmodule
