module Dec2to4(input [1:0] data, output [3:0] dec, input wen);
	// 2-to-4 decoder
	// Fundamental unit of decoder hierarchy
	assign dec[0] = wen & ~data[1] & ~data[0];
	assign dec[1] = wen & ~data[1] & data[0];
	assign dec[2] = wen & data[1] & ~data[0];
	assign dec[3] = wen & data[1] & data[0];

endmodule

module Dec3to8(input [2:0] data, output [7:0] dec, input wen);
	// 3-to-8 decoder
	// Use hierarchy
	Dec2to4 iDec2to4_lo(.data(data[1:0]), .dec(dec[3:0]), .wen(wen & ~data[2]));
	Dec2to4 iDec2to4_hi(.data(data[1:0]), .dec(dec[7:4]), .wen(wen & data[2]));

endmodule

module Dec4to16(input [3:0] data, output [15:0] dec, input wen);
	// 4-to-16 decoder
	// Use hierarchy
	Dec3to8 iDec3to8_lo(.data(data[2:0]), .dec(dec[7:0]), .wen(wen & ~data[3]));
	Dec3to8 iDec3to8_hi(.data(data[2:0]), .dec(dec[15:8]), .wen(wen & data[3]));

endmodule

module Dec5to32(input [4:0] data, output [31:0] dec, input wen);
	// 5-to-32 decoder
	// Use hierarchy
	Dec4to16 iDec4to16_lo(.data(data[3:0]), .dec(dec[15:0]), .wen(wen & ~data[4]));
	Dec4to16 iDec4to16_hi(.data(data[3:0]), .dec(dec[31:16]), .wen(wen & data[4]));

endmodule

module Dec6to64(input [5:0] data, output [63:0] dec, input wen);
	// 6-to-64 decoder
	// Use hierarchy
	Dec5to32 iDec5to32_lo(.data(data[4:0]), .dec(dec[31:0]), .wen(wen & ~data[5]));
	Dec5to32 iDec5to32_hi(.data(data[4:0]), .dec(dec[63:32]), .wen(wen & data[5]));

endmodule

module Dec7to128(input [6:0] data, output [127:0] dec);
	// 7-to-128 decoder
	// Use hierarchy (this is top level)
	Dec6to64 iDec6to64_lo(.data(data[5:0]), .dec(dec[63:0]), .wen(~data[6]));
	Dec6to64 iDec6to64_hi(.data(data[5:0]), .dec(dec[127:64]), .wen(data[6]));

endmodule
