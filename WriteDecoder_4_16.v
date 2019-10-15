module WriteDecoder_4_16(
input [3:0] RegId, 
input WriteReg, 
output [15:0] Wordline);
wire [15:0] s_out;

  Shifter s1(.Shift_Out(s_out), .Shift_In(16'h0001), .Shift_Val(RegId), .Mode(1'b0));
  assign Wordline = (WriteReg) ? s_out : 16'b0;
endmodule
