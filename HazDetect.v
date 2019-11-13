module hazDetect(memRead_DX, registerRd_DX, registerRs_FD, registerRt_FD, memWrite_FD, stall);
	input memRead_DX; 	// ID/EX
	input registerRd_DX;	// ID/EX
	input registerRs_FD;	// IF/ID
	input registerRt_FD;	// IF/ID
	input memWrite_FD;	// IF/ID
	
	output stall;		//

	assign regRd = registerRd_DX != 4'h0;
	assign regRD_RS = registerRd_DX == registerRs_FD;
	assign regRD_RT = registerRd_DX == registerRt_FD;
	assign notMemWrite = ~memWrite_FD;

	
	assign stall = (memRead_DX & regRd & (regRD_RS | (regRD_RT & notMemWrite)));

endmodule