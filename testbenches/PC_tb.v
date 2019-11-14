module pc_tb();

	reg[15:0] PC_in = 16'h1234;
	wire[15:0] PC_out;
	reg clk, rst;

	PC iPC(.clk(clk), .rst(rst), .write_en(1'b1), .PC_in(PC_in), .PC_out(PC_out));

	initial begin
		rst = 1;
		clk = 0;
		repeat (2) @(posedge clk);
		rst = 0;
		repeat (2) @(posedge clk);
		$stop();
	end
	always #20 clk = ~clk;

endmodule
