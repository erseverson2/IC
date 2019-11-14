/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 13, 2019 */

module hazDetect(memRead_DX, registerRd_DX, registerRs_FD, registerRt_FD, memWrite_FD, go, BranchIns, stall);
	input memRead_DX; 	// ID/EX
	input [3:0] registerRd_DX;	// ID/EX
	input [3:0] registerRs_FD;	// IF/ID
	input [3:0] registerRt_FD;	// IF/ID
	input memWrite_FD;	// IF/ID
	input go;
	input BranchIns;
	
	output stall;		//

	assign regRd = registerRd_DX != 4'h0;
	assign regRD_RS = registerRd_DX == registerRs_FD;
	assign regRD_RT = registerRd_DX == registerRt_FD;
	assign notMemWrite = ~memWrite_FD;

	
	assign stall = (memRead_DX & regRd & (regRD_RS | (regRD_RT & notMemWrite)))
			| (BranchIns & ~go);

endmodule
