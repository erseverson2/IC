module decoder_tb();

	reg clk;
	reg [7:0] decode_this = 7'h00;
	wire [127:0] verify_me;

	Dec7to128 iDec(.data(decode_this), .dec(verify_me));
	
	initial begin
		clk = 0;
		while (decode_this < 8'd128) begin
			@(posedge clk);
			decode_this = decode_this + 1;
		end
		$stop;
	end

    	always #5 clk = ~clk;

endmodule
