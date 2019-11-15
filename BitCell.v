module BitCell(
input clk,
input rst,
input D,
input WriteEnable,
input ReadEnable1,
input ReadEnable2,
inout Bitline1,
inout Bitline2);

  wire q_bit;
  assign Bitline1 = ReadEnable1 ? q_bit : 1'bZ;
  assign Bitline2 = ReadEnable2 ? q_bit : 1'bZ;

  dff dff_1(.q(q_bit), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

endmodule
