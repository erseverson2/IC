/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 15, 2019 */

// Order of Flags: {Z, V, N}
module PC_control(
input [2:0]C, 
input [8:0]I, 
input [2:0]F,
input [15:0]PC_control_in,
input [15:0]reg2_data,
input branch_type,
input halt,
input stall,
input branch_ins,
output [15:0]PC_control_out,
output branch_taken);

assign Z = F[2];
assign V = F[1];
assign N = F[0];

assign condition_met =	(C == 3'b000) ? ~Z: // Not equal
			(C == 3'b001) ? Z: // equal
			(C == 3'b010) ? {N, Z} == 2'b00: // greater than
			(C == 3'b011) ? N: // less than
			(C == 3'b100) ? (Z | ((~Z) & (~N))): // Greater Than or Equal
			(C == 3'b101) ? (N | Z): // less than or equals to
			(C == 3'b110) ? V: // overflow
			(C == 3'b111) ? 1'b1: 1'b0; // unconditional

wire [15:0]branch_address, PC_plus_imm, next_address, PC_plus2;

cla_16bit adder1(.A(PC_control_in), .B(16'h2), .Cin(1'b0), .S(PC_plus2), .Cout(), .Ovfl());
cla_16bit adder2(.A(PC_control_in),/*PC_plus2),*/ .B({{6{I[8]}},{I[8:0]}, 1'b0}), .Cin(1'b0), .S(PC_plus_imm), .Cout(), .Ovfl());

// @ branch_type, 0 for B, 1 for Br
assign branch_taken = branch_ins & condition_met & ~stall;
assign branch_address = branch_type? reg2_data : PC_plus_imm; 
assign next_address = branch_taken ? branch_address : PC_plus2;
assign PC_control_out = (halt | stall) ? PC_control_in: next_address;

endmodule
