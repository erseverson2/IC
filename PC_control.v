/* Author: Ilhan Bok
   Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Oct. 13, 2019 */
   
module PC_control(C, I, F, PC_in, PC_out);

	input[2:0] C; // Condition codes
	input[8:0] I; // Branch offset
	input[2:0] F; // Flags - [2:0](Sign(N), Overflow(V), Zero(Z))
	wire N, V, Z;
	wire willBranch;
	
	input[15:0] PC_in;
	output[15:0] PC_out;
	
	wire[15:0] inc_addr;
	wire[15:0] branch_addr;
	wire[9:0] I_shift;
	
	assign I_shift = I << 1;
	
	cla_16bit iPC(.A(PC_in), .B(16'h0002), .Cin(1'b0), .S(inc_addr), .Cout(), .Ovfl());
	cla_16bit iBR(.A(inc_addr), .B({6'h00, I_shift}), .Cin(1'b0), .S(branch_addr), .Cout(), .Ovfl());
	
	assign Z = F[0];
	assign V = F[1];
	assign N = F[2];
	
	assign willBranch = (C == 3'b000) ? Z == 1'b0 : // Not Equal
						(C == 3'b001) ? Z == 1'b1 : // Equal
						(C == 3'b010) ? {N, Z} == 2'b00 : // Greater Than
						(C == 3'b011) ? N == 1'b1 : // Less Than
						(C == 3'b100) ? (Z | ~|{N, Z}) : // Greater Than or Equal
						(C == 3'b101) ? (Z | N) : // Less Than or Equal
						(C == 3'b110) ? V : // Overflow
						(C == 3'b111) ? 1'b1 : 1'b0; // Unconditional
						
	assign PC_Out = willBranch ? branch_addr : inc_addr;

endmodule