module CLA_tb();

	wire[16:0] sum;
	wire[15:0] tSum;
	reg[31:0] stim = 32'h00000000;
	reg Cin;
	wire Cout;
	
	assign sum = stim[31:16] + stim[15:0] + Cin;

	cla_16bit iCLA(.A(stim[31:16]), .B(stim[15:0]), .Cin(Cin), .S(tSum), .Cout(Cout));

	initial begin
		repeat (100) begin
			stim = $random;
			Cin = 1'b0;
			#20;
			if (tSum != sum[15:0]) begin
				$display("[SUM0] CLA: %d, TB: %d, stim: %b", tSum, sum, stim);
				$stop;
			end
			if (Cout != sum[16]) begin
				$display("[COUT0] CLA: %d, TB: %d, stim: %b", Cout, sum[16], stim);
				$stop;
			end
			Cin = 1'b1;
			#20;
			if (tSum != sum[15:0]) begin
				$display("[SUM1] CLA: %d, TB: %d, stim: %b", tSum, sum, stim);
				$stop;
			end
			if (Cout != sum[16]) begin
				$display("[COUT1] CLA: %d, TB: %d, stim: %b", Cout, sum[16], stim);
				$stop;
			end
		end
		$display("It worked.");
	end

endmodule
