/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 13, 2019 */

module hazDetect(memRead_DX, memRead_XM, registerRd_DX, registerRs_FD, registerRt_FD, memWrite_FD, registerRd_XM, Flags_Set, BranchIns, BranchType, stall_mem, stall_br,
		registerRs_DX, registerRd_MW);
	input memRead_DX; 	// ID/EX
	input memRead_XM;
	input [3:0] registerRd_DX;	// ID/EX
	input [3:0] registerRs_FD;	// IF/ID
	input [3:0] registerRt_FD;	// IF/ID
	input [3:0] registerRd_XM;	// EX/MEM
	input [3:0] registerRs_DX;
	input [3:0] registerRd_MW;	// MEM/WB
	input memWrite_FD;	// IF/ID
	input Flags_Set;
	input BranchIns, BranchType;
	
	output stall_mem;
	output stall_br;

	assign regRd = registerRd_DX != 4'h0;
	assign regRd_br = registerRd_XM != 4'h0;
	assign regRD_RS = registerRd_DX == registerRs_FD;
	assign regRD_RS_br = registerRd_XM == registerRs_DX;
	assign regRD_RS_MEM = registerRd_XM == registerRs_FD;
	assign regRD_RS_MEM_br = registerRd_MW == registerRs_DX;
	assign regRD_RT = registerRd_DX == registerRt_FD;
	assign notMemWrite = ~memWrite_FD;

	
	assign stall_mem = (memRead_DX & regRd & (regRD_RS | (regRD_RT & notMemWrite))); // load-to-use
	assign stall_br = (BranchIns & (// branch?
				(~BranchType & Flags_Set & regRd_br) // Branch immediate B (not reg dependent)
				| (BranchType & (regRD_RS_br | (regRD_RS_MEM_br))) // Branch register BR (reg dependent)
			));

endmodule
