/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Oct. 13, 2019 */
   
/* Add two bits together while calculating generate
   and propagate for CLA */
module full_adder_1bit(A, B, Cin, S, P, G);

	input A, B, Cin;
	output S, P, G;

	assign S = P ^ Cin;
	assign P = A ^ B; // Propagate
	assign G = A & B; // Generate

endmodule

/* Merge four 1-bit adders with generate/propagate unit,
   and produce group-generate and group-propagate bits */
module cla_4bit(A, B, C0, S, GrP, GrG, Ovfl, Cout);

	input[3:0] A, B;
	input C0;
	wire[3:0] P, G;
	wire C1, C2, C3;
	output[3:0] S;
	output GrP, GrG, Ovfl, Cout;

	full_adder_1bit FA0(.A(A[0]), .B(B[0]), .Cin(C0), .S(S[0]), .P(P[0]), .G(G[0]));
	full_adder_1bit FA1(.A(A[1]), .B(B[1]), .Cin(C1), .S(S[1]), .P(P[1]), .G(G[1]));
	full_adder_1bit FA2(.A(A[2]), .B(B[2]), .Cin(C2), .S(S[2]), .P(P[2]), .G(G[2]));
	full_adder_1bit FA3(.A(A[3]), .B(B[3]), .Cin(C3), .S(S[3]), .P(P[3]), .G(G[3]));

	//////////////////// CLA logic ///////////////////////

	assign C1 = G[0] | (P[0] & C0);
	assign C2 = G[1] | (P[1] & C1);
	assign C3 = G[2] | (P[2] & C2);
	assign Cout = GrG | (GrP & C0);
	assign Ovfl = Cout ^ C3;

	assign GrP = &P;
	assign GrG = G[3] | (G[2] & P[3]) | (G[1] & P[3] & P[2]) |
			(G[0] & P[3] & P[2] & P[1]);

endmodule

/* Create 16-bit hierarchy of four 4-bit adders, which covers all
   cases for the group project */
module cla_16bit(A, B, Cin, S, Cout, Ovfl);

	input[15:0] A, B;
	input Cin;
	wire[3:0] P, G;
	wire C4, C8, C12, C15;
	output[15:0] S;
	output Cout, Ovfl;

	// Collect the group-generate and propagate bits
	cla_4bit CLA0(.A(A[3:0]), .B(B[3:0]), .C0(Cin), .S(S[3:0]), .GrP(P[0]), .GrG(G[0]), .Ovfl(), .Cout());
	cla_4bit CLA1(.A(A[7:4]), .B(B[7:4]), .C0(C4), .S(S[7:4]), .GrP(P[1]), .GrG(G[1]), .Ovfl(), .Cout());
	cla_4bit CLA2(.A(A[11:8]), .B(B[11:8]), .C0(C8), .S(S[11:8]), .GrP(P[2]), .GrG(G[2]), .Ovfl(), .Cout());
	cla_4bit CLA3(.A(A[15:12]), .B(B[15:12]), .C0(C12), .S(S[15:12]), .GrP(P[3]), .GrG(G[3]), .Ovfl(Ovfl), .Cout());

	//////////////////// CLA logic ///////////////////////

	assign C4 = G[0] | (P[0] & Cin);
	assign C8 = G[1] | (P[1] & C4);
	assign C12 = G[2] | (P[2] & C8);
	assign Cout = G[3] | (P[3] & C12);

endmodule
