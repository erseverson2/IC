module forwarding_unit(ALU_src1_fwd, ALU_src2_fwd, LB_ins_fwd, RegWrite_EXMEM, RegWrite_MEMWB, MemWrite_MEM, DstReg1_in_from_EXMEM, DstReg1_in_from_MEMWB, SrcReg1_in_from_IDEX, SrcReg2_in_from_IDEX, DstReg1_in_from_IDEX, SrcReg1_in_from_EXMEM, DMEM_fwd);

input RegWrite_EXMEM; // for ex hazards, The ALU operand is forwarded from the prior ALU result
input RegWrite_MEMWB; // for memory hazards, The ALU operand is forwarded from data memory or an earlier ALU result.
input MemWrite_MEM; // for mem2mem forwarding (only on stores)

input [3:0] DstReg1_in_from_EXMEM, DstReg1_in_from_MEMWB, SrcReg1_in_from_IDEX, SrcReg2_in_from_IDEX, DstReg1_in_from_IDEX,
		SrcReg1_in_from_EXMEM;

output [1:0] ALU_src1_fwd, ALU_src2_fwd, LB_ins_fwd;
output DMEM_fwd;

///////EX hazard forwarding////////////////////////////////////////////
//if (EX/MEM.RegWrite
//and (EX/MEM.RegisterRd ? 0)
//and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) ForwardA = 10

//if (RegWrite_EXMEM
//and (DstReg1_in_from_EXMEM ? 0)
//and (DstReg1_in_from_EXMEM = SrcReg2_in_from_IDEX)) ForwardB = 10

//TODO: possible room for logic optimization (redundant logic)?
assign ALU_src1_fwd[1] = RegWrite_EXMEM & (|DstReg1_in_from_EXMEM) & (DstReg1_in_from_EXMEM == SrcReg1_in_from_IDEX);

assign ALU_src2_fwd[1] = RegWrite_EXMEM & (|DstReg1_in_from_EXMEM) & (DstReg1_in_from_EXMEM == SrcReg2_in_from_IDEX);

// LLB and LHB forwarding (EX to EX)
assign LB_ins_fwd[1] = RegWrite_EXMEM & (|DstReg1_in_from_EXMEM) & (DstReg1_in_from_EXMEM == DstReg1_in_from_IDEX);

///////MEM to ex fowarding////////////////////////////////////////////
//if (MEMWB_RegWrite
//and (DstReg1_in_from_MEMWB ? 0)
//and not(RegWrite_EXMEM and (DstReg1_in_from_EXMEM ? 0)
//and (DstReg1_in_from_EXMEM ?SrcReg1_in_from_IDEX))
//and (DstReg1_in_from_MEMWB = SrcReg1_in_from_IDEX)) ForwardA = 01

//if (MEM/WB.RegWrite
//and (MEM/WB.RegisterRd ? 0)
//and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd ? 0)
//and (EX/MEM.RegisterRd ? ID/EX.RegisterRt))
//and (MEM/WB.RegisterRd = ID/EX.RegisterRt)) ForwardB = 01
assign  ALU_src1_fwd[0] = RegWrite_MEMWB & |(DstReg1_in_from_MEMWB) & 
	~(RegWrite_EXMEM & |(DstReg1_in_from_EXMEM) & (DstReg1_in_from_EXMEM == SrcReg1_in_from_IDEX)) & (DstReg1_in_from_MEMWB == SrcReg1_in_from_IDEX);

assign  ALU_src2_fwd[0] = RegWrite_MEMWB & |(DstReg1_in_from_MEMWB) & 
	~(RegWrite_EXMEM & |(DstReg1_in_from_EXMEM) & (DstReg1_in_from_EXMEM == SrcReg2_in_from_IDEX)) & (DstReg1_in_from_MEMWB == SrcReg2_in_from_IDEX);

// LLB and LHB MEM to EX
assign LB_ins_fwd[0] = RegWrite_MEMWB & |(DstReg1_in_from_MEMWB) &
	~(RegWrite_EXMEM & |(DstReg1_in_from_EXMEM) & (DstReg1_in_from_EXMEM == DstReg1_in_from_IDEX)) & (DstReg1_in_from_MEMWB == DstReg1_in_from_IDEX);

///////MEM to MEM forwarding
//if ( EX/MEM.MemWrite and MEM/WB.RegWrite and (MEM/WB.RegisterRd ? 0)
//and (MEM/WB.RegisterRd = EX/MEM.RegisterRt)
//) enable MEM-to-MEM forwarding;

assign DMEM_fwd = MemWrite_MEM & RegWrite_MEMWB & (|DstReg1_in_from_MEMWB) & (DstReg1_in_from_MEMWB == SrcReg1_in_from_EXMEM);

endmodule
