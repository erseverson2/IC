/* Group: Memory Loss
   Class: ECE 552-1 */

module ALU(ALU_Out, ALU_In1, ALU_In2, Opcode, Flags);

	input[15:0] ALU_In1, ALU_In2;
	input[2:0] Opcode;
	output[15:0] ALU_Out;
	output[2:0] Flags;
	wire V, N, Z;
	assign Flags[0] = Z;
	assign Flags[1] = N;
	assign Flags[2] = V;
	
	wire sub, Ovfl, Sign;
	assign sub = Opcode[0];

	wire[15:0] Sum, XOR, Res, Shift_Out, PADDSB;
	wire[3:0] PADDSB3, PADDSB2, PADDSB1, PADDSB0;
	wire[3:0] P3_Raw, P2_Raw, P1_Raw, P0_Raw;
	wire[3:0] PADD_Ovfl, PADD_Cout;
	wire[15:0] Sum_Sat;

	/////////////// PADDSB saturation //////////////////////
	assign PADDSB0 = PADD_Ovfl[0] ? // Is there overflow?
			 PADD_Cout[0] ? // Is it negative?
			 	4'b1000 : 4'b0111
			 : // No overflow
			 P0_Raw;
	assign PADDSB1 = PADD_Ovfl[1] ? // Is there overflow?
			 PADD_Cout[1] ? // Is it negative?
			 	4'b1000 : 4'b0111
			 : // No overflow
			 P1_Raw;
	assign PADDSB2 = PADD_Ovfl[2] ? // Is there overflow?
			 PADD_Cout[2] ? // Is it negative?
			 	4'b1000 : 4'b0111
			 : // No overflow
			 P2_Raw;
	assign PADDSB3 = PADD_Ovfl[3] ? // Is there overflow?
			 PADD_Cout[3] ? // Is it negative?
			 	4'b1000 : 4'b0111
			 : // No overflow
			 P3_Raw;
	
	// Connect together all the partial adds
	assign PADDSB = {PADDSB3, PADDSB2, PADDSB1, PADDSB0};
	/////////////// END PADDSB saturation //////////////////////

	assign Sum_Sat = Ovfl ? // Oveflow?
			 Sign ? // Negative?
			 16'h8000 : 16'h7FFF:
			 Sum;
	/////////////// Opcodes //////////////////////
	// ADD		000
	// SUB		001
	// XOR		010
	// RED		011
	// SLL		100
	// SRA		101
	// ROR		110
	// PADDSB	111
	/////////////// Opcodes //////////////////////

	/* Perform differing operation based on opcode */
	assign ALU_Out = (Opcode == 3'b000) ? Sum_Sat :
			(Opcode == 3'b001) ? Sum_Sat :
			(Opcode == 3'b010) ? XOR :
			(Opcode == 3'b011) ? Res :
			(Opcode == 3'b100) ? Shift_Out :
			(Opcode == 3'b101) ? Shift_Out :
			(Opcode == 3'b110) ? Shift_Out :
			(Opcode == 3'b111) ? PADDSB : 16'h0000;

	// Zero flag
	assign Z = (Opcode == 3'b000) ? ~|Sum :
		(Opcode == 3'b001) ? ~|Sum :
		(Opcode == 3'b010) ? ~|XOR :
		(Opcode == 3'b100) ? ~|Shift_Out :
		(Opcode == 3'b101) ? ~|Shift_Out :
		(Opcode == 3'b110) ? ~|Shift_Out : 1'b0;

	// Negative flag (only for ADD and SUB)
	assign N = (Opcode == 3'b000) ? Sign :
		(Opcode == 3'b001) ? Sign : 1'b0;

	// Overflow flag (only for ADD and SUB)
	assign V = (Opcode == 3'b000) ? Ovfl :
		(Opcode == 3'b001) ? Ovfl : 1'b0;
	// XOR: Simple bitwise XOR
	assign XOR = ALU_In1 ^ ALU_In2;
	// ADD, SUB: Adder/subtractor using modified 16-bit CLA adder
	addsub_16bit iADD(.Sum(Sum), .Ovfl(Ovfl), .Sign(Sign), .A(ALU_In1), .B(ALU_In2), .sub(sub));
	// PADDSB: Four separate, saturating additions
	cla_4bit i4CLA0(.A(ALU_In1[3:0]), .B(ALU_In2[3:0]), .C0(1'b0), .S(P0_Raw), .GrP(), .GrG(), .Ovfl(PADD_Ovfl[0]), .Cout(PADD_Cout[0]));
	cla_4bit i4CLA1(.A(ALU_In1[7:4]), .B(ALU_In2[7:4]), .C0(1'b0), .S(P1_Raw), .GrP(), .GrG(), .Ovfl(PADD_Ovfl[1]), .Cout(PADD_Cout[1]));
	cla_4bit i4CLA2(.A(ALU_In1[11:8]), .B(ALU_In2[11:8]), .C0(1'b0), .S(P2_Raw), .GrP(), .GrG(), .Ovfl(PADD_Ovfl[2]), .Cout(PADD_Cout[2]));
	cla_4bit i4CLA3(.A(ALU_In1[15:12]), .B(ALU_In2[15:12]), .C0(1'b0), .S(P3_Raw), .GrP(), .GrG(), .Ovfl(PADD_Ovfl[3]), .Cout(PADD_Cout[3]));
	// RED: Reduction operator also using CLA adders
	red iRED(.A(ALU_In1), .B(ALU_In2), .Res(Res));
	// SLL, SRA, ROR: Shift left (logical), right (arithmetic) and rotate right unit
	Shifter iSHIFT(.Shift_Out(Shift_Out), .Shift_In(ALU_In1),
		.Shift_Val(ALU_In2[3:0]), .Mode(Opcode[1:0]));

endmodule

/* Adder/Subtractor that can be rigged to do either.
   Also detects oveflow */
module addsub_16bit(Sum, Ovfl, Sign, A, B, sub);

    input[15:0] A, B;
    input sub;
    output Ovfl, Sign;
    output[15:0] Sum;

    wire[15:0] B_XOR;

    assign B_XOR = {16{sub}} ^ B;

    cla_16bit iCLA(.A(A), .B(B_XOR), .Cin(sub), .S(Sum), .Cout(Sign), .Ovfl(Ovfl));

endmodule

/* Reduces 16 bit addition to 8 bit addition of four numbers */
module red(A, B, Res);

    input[15:0] A, B;
    output[15:0] Res;
    wire[9:0] sum;

    wire [7:0] hiSum, loSum;
    wire hiCout, loCout, cla4lo, cla4mid, cla4high;
    wire [1:0] upperSum;

    // Sign extend the result
    assign Res = {{6{sum[9]}}, sum};

    // Perform the two 8 bit additions
    cla_8bit CLAhi(.A(A[15:8]), .B(B[15:8]), .Cin(1'b0), .S(hiSum[7:0]), .Cout(hiCout));
    cla_8bit CLAlo(.A(A[7:0]), .B(B[7:0]), .Cin(1'b0), .S(loSum[7:0]), .Cout(loCout));

    // Add the results together
    cla_4bit CLAbot(.A(hiSum[3:0]), .B(loSum[3:0]), .C0(1'b0), .S(sum[3:0]), .GrP(), .GrG(), .Ovfl(), .Cout(cla4lo));
    cla_4bit CLAmid(.A(hiSum[7:4]), .B(loSum[7:4]), .C0(cla4lo), .S(sum[7:4]), .GrP(), .GrG(), .Ovfl(), .Cout(cla4mid));
    cla_4bit CLAup(.A({3'b000, hiCout}), .B({3'b000, loCout}), .C0(cla4mid), .S({upperSum, sum[9:8]}), .GrP(), .GrG(), .Ovfl(), .Cout());

endmodule

/* Performs logical shift left, arithmetic shift right, and rotate right */
module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
    input [15:0] Shift_In; 	// This is the input data to perform shift operation on
    input [3:0] Shift_Val; 	// Shift amount (used to shift the input data)
    input [1:0] Mode; 		// To indicate 00 = SLL, 01 = SRA, 10 = ROR

    wire [15:0] Shift_1, Shift_2, Shift_4;
    output [15:0] Shift_Out; 	// Shifted output data

    assign Shift_1 = Shift_Val[0] ? Mode[1] ? {Shift_In[0], Shift_In[15:1]} : Mode[0] ? {Shift_In[15], Shift_In[15:1]} : {Shift_In[14:0], 1'b0} : {Shift_In}; // shift by 1
    assign Shift_2 = Shift_Val[1] ? Mode[1] ? {Shift_1[1:0], Shift_1[15:2]} : Mode[0] ? {{2{Shift_1[15]}}, Shift_1[15:2]} : {Shift_1[13:0], 2'b00} : {Shift_1}; // shift by 2
    assign Shift_4 = Shift_Val[2] ? Mode[1] ? {Shift_2[3:0], Shift_2[15:4]} : Mode[0] ? {{4{Shift_2[15]}}, Shift_2[15:4]} : {Shift_2[11:0], 4'h0} : {Shift_2}; // shift by 4
    assign Shift_Out = Shift_Val[3] ? Mode[1] ? {Shift_4[7:0], Shift_4[15:8]} : Mode[0] ? {{8{Shift_4[15]}}, Shift_4[15:8]} : {Shift_4[7:0], 8'h00} : {Shift_4}; // shift by 8
endmodule
