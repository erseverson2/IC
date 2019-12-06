/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 13, 2019 */

// TODO: Fix PCS
// TODO: Verify that LRU works
// TODO: Verify that cache writes work as specified

// Order of Flags: {Z, V, N}
module cpu(clk, rst_n, hlt, pc_out);

	input clk;

	// Active low reset. A low on this signal resets the processor and causes
	// execution to start at address 0x0000
	input rst_n;
	wire rst_reg = ~rst_n;

	// Assert when HLT encountered, after finishing prior instruction
	output hlt;
	output[15:0] pc_out; // program counter

	// Register and ALU , and PC wires
	wire [15:0] reg_wrt_data;
	wire [15:0] reg_data1_to_IDEX, reg_data1_from_IDEX;
	wire [15:0] ALU_In1, ALU_In2, ALU_Out, ALU_mux_out, loaded_byte;
	wire [15:0] PC_out_to_IFID, PC_out_from_IFID;
	wire [15:0] PC_in;
	wire[15:0] PC_out_IFID, PC_out_IDEX, PC_out_EXMEM, PC_out_MEMWB;

	/////////////// Opcodes //////////////////////
	// ADD		0000
	// SUB		0001
	// XOR		0010
	// RED		0011
	// SLL		0100
	// SRA		0101
	// ROR		0110
	// PADDSB	0111
	// LW		1000
	// SW		1001
	// LLB		1010
	// LHB		1011
	// B		1100
	// BR		1101
	// PCS		1110
	// HLT		1111
	/////////////// Opcodes //////////////////////

/////////////// FETCH (IF) ///////////////////////////

	///////////// Instruction Memory /////////////
	wire[15:0] imem_data_out_to_IFID, imem_data_out_from_IFID;

	// ICACHE would go here, but is placed near MCM

	/////////////// PC and PC control ////////////
	wire[2:0] FLAGS, FLAGS_MEM;
	wire Halt_WB, branch_taken;
	wire[15:0] reg_data2_from_IDEX;

	// Halt
	assign Halt = &imem_data_out_to_IFID[15 : 12] & ~branch_taken;

	PC iPC(
	.clk(clk),
	.rst(rst_reg),
	.write_en(1'b1),
	.PC_in(PC_in),
	.PC_out(PC_out_to_IFID));

	PC_control iPC_control(
	.C(imem_data_out_from_IFID[11:9]), 
	.I(imem_data_out_from_IFID[8:0]),
	.F(FLAGS_MEM),
	.PC_control_in(PC_out_to_IFID),
	.reg2_data(reg_data1_to_IDEX),// one not two (not a typo)
	.branch_type(BranchType),
	.halt(Halt),
	.stall(stall | ISTALL | DSTALL),
	.branch_taken(branch_taken),
	.branch_ins(BranchIns),
	.PC_control_out(PC_in)
	);

	// Actually halt only when Halt reaches WB
	assign hlt = Halt_WB;

	assign pc_out = PC_out_to_IFID;

/////////////// IF/ID ///////////////////////////

	pipeline_IFID iPipe_IFID(
	.clk(clk),
	.rst(rst_reg),
	.stall(stall),// | DSTALL),
	.flush(branch_taken | ISTALL),
	.Halt(Halt),
	.Halt_ID(Halt_ID),
	.PC_out_to_IFID(PC_out_to_IFID),
	.PC_out_from_IFID(PC_out_from_IFID),
	.imem_data_out_to_IFID(imem_data_out_to_IFID),
	.imem_data_out_from_IFID(imem_data_out_from_IFID),
	.PC_in(PC_in),
	.PC_out(PC_out_IFID));

/////////////// DECODE (ID) ////////////////////////////

	/////////////// Control Signals //////////////

	//////////////////////////////////////////////
	// ID:
	// 
	// EX:
	// @ ALUSrc
	// @ LBIns
	// @ Reg2Src
	//
	// MEM:
	// @ MemWrite
	//
	// WB:
	// @ RegWrite
	// @ MemtoReg
	// @ PCtoReg
	// @ Halt
	//
	// Not decided:
	// @ BranchType
	// @ BranchIns
	//////////////////////////////////////////////

	//////////////// Opcode and control //////////

	wire[3:0] opcode;
	assign opcode = imem_data_out_from_IFID[15 : 12];

	// BranchType 0 if its Branch immediate ins, 1 if Branch Register
	assign BranchType = opcode[0];

	// BranchIns, 1 if opcode is a branch instruction, 0 if not
	assign BranchIns = opcode[3]&opcode[2]&~opcode[1];	
	
	// ALUSrc controls if RegisterSrcData2 or Signextedimm goes in to ALU src 2, 1 for offset, 0 for Reg_out2
	assign ALUSrc = opcode[3]| (opcode[2] & (~(opcode[1]&opcode[0])));

	// RegWrite determines if writedata[15:0] will be writen into Dstreg
	assign RegWrite = (~opcode[3]) | opcode[3]&((~opcode[2]&~opcode[1]&~opcode[0])| (~opcode[2]&opcode[1]&~opcode[0])
							|(~opcode[2]&opcode[1]&opcode[0])|(opcode[2]&opcode[1]&~opcode[0]));

	// Reg2Src determines which bits from the opcode is going to used as the address in register src 2
	// Reg2Src only need to be asserted to 1 for SW, LLB, LHB
	assign Reg2Src = opcode[3];

	// MemtoReg determines if write data in the registerfile will receive from the ALU or Data Memory
	assign MemtoReg = opcode[3]&~opcode[2]&~opcode[1]&~opcode[0];

	// MemWrite determines if [15:0] data from Register output 2 gets writen into address from ALU output
	assign MemWrite = opcode[3]&~opcode[2]&~opcode[1]&opcode[0];

	// MemRead determines if current instruction is a load
	assign MemRead = opcode[3]&~opcode[2]&~opcode[1]&~opcode[0];

	// LBIns, 1 if opcode is LoadBype instruction, 0 otherwise
	assign LBIns = opcode[3] & ~opcode[2] & opcode[1];

	// PCtoReg, 1 if want to write PC to dstReg
	assign PCtoReg = opcode[3]&opcode[2]&opcode[1]&~opcode[0];

	wire[2:0] ALU_Opcode = (opcode == 4'b1001) ? 3'b000 : opcode[2:0];

	///////////// Control Signals END//////////////

	/////////////// Registers //////////////////////
	// @ imem_data_out_from_IFID[7:4] is Rs
	// @ imem_data_out_from_IFID[3:0] is Rt in [OPCODE][Rd][Rs][Rt/imm]
	// @ imem_data_out_from_IFID[11:8]

	wire[15:0] dmem_data_out;
	wire[15:0] reg_data2_to_IDEX;
	wire[3:0] DstReg1_in_to_IDEX, DstReg1_in_from_IDEX;
	wire[3:0] LLB_LHB_to_IDEX, LLB_LHB_from_IDEX;
	wire[3:0] SrcReg1_in_to_IDEX, SrcReg1_in_from_IDEX;
	wire[3:0] SrcReg2_in_to_IDEX, SrcReg2_in_from_IDEX;
	wire[3:0] DstReg1_in_from_MEMWB;
	
	// Reg2Src determines which bits from the instruction is going to used as the address in register src 2. 1 for []
	assign SrcReg1_in_to_IDEX = imem_data_out_from_IFID[7:4];
	assign SrcReg2_in_to_IDEX = Reg2Src? imem_data_out_from_IFID[11:8] :imem_data_out_from_IFID[3:0];
	assign DstReg1_in_to_IDEX = imem_data_out_from_IFID[11:8];
	assign LLB_LHB_to_IDEX = imem_data_out_from_IFID[3:0];

	wire RegWrite_MEMWB, MemtoReg_WB, PCtoReg_WB;

	RegisterFile IREGFILE(
	.clk(clk),
	.rst(rst_reg),
	.SrcReg1(SrcReg1_in_to_IDEX),
	.SrcReg2(SrcReg2_in_to_IDEX),
	.DstReg(DstReg1_in_from_MEMWB), 
	.WriteReg(RegWrite_MEMWB),
	.DstData(reg_wrt_data),
	.SrcData1(reg_data1_to_IDEX),
	.SrcData2(reg_data2_to_IDEX));

	// PC_in here, because it will be the output from PC_control, which is the already incremented PC
	wire[15:0] dmem_data_out_WB;
	wire[15:0] ALU_mux_out_WB;
	assign reg_wrt_data = MemtoReg_WB ? dmem_data_out_WB : (PCtoReg_WB ? PC_out_MEMWB: ALU_mux_out_WB);
	/////////////// Registers End///////////////////

/////////////// ID/EX ///////////////////////////

	wire [2:0] ALU_Opcode_EX;
	wire ALUSrc_EX, LBIns_EX, Reg2Src_EX;
	wire [1:0] Control_EX_to_MEM;
	wire [3:0] Control_EX_to_WB;
	//wire go; // The forwarded stall signal
	
	// {ALU_Opcode, ALUSrc, LBIns}
	// {MemWrite, MemRead}
	// {RegWrite, MemtoReg, PCtoReg, Halt}
	pipeline_IDEX iPipe_IDEX(
	.clk(clk),
	.rst(rst_reg),
	.ALU_Opcode(ALU_Opcode),
	.ALUSrc(ALUSrc),
	.RegWrite(RegWrite),
	.Reg2Src(Reg2Src),
	.Reg2Src_EX(Reg2Src_EX),
	.MemtoReg(MemtoReg),
	.MemWrite(MemWrite),
	.MemRead(MemRead),
	.Halt(Halt_ID),
	.LBIns(LBIns),
	.PCtoReg(PCtoReg),
	.nop(stall),
	.stall(DSTALL),
	.reg_data1_to_IDEX(reg_data1_to_IDEX),
	.reg_data2_to_IDEX(reg_data2_to_IDEX),
	.SrcReg1_in_to_IDEX(SrcReg1_in_to_IDEX),
	.SrcReg2_in_to_IDEX(SrcReg2_in_to_IDEX),
	.DstReg1_in_to_IDEX(DstReg1_in_to_IDEX),
	.LLB_LHB_to_IDEX(LLB_LHB_to_IDEX),
	.LLB_LHB_from_IDEX(LLB_LHB_from_IDEX),
	.to_EXReg({ALU_Opcode_EX, ALUSrc_EX, LBIns_EX}),
	.to_Mem(Control_EX_to_MEM),
	.to_WBReg(Control_EX_to_WB),
	.reg_data1_from_IDEX(reg_data1_from_IDEX),
	.reg_data2_from_IDEX(reg_data2_from_IDEX),
	.SrcReg1_in_from_IDEX(SrcReg1_in_from_IDEX),
	.SrcReg2_in_from_IDEX(SrcReg2_in_from_IDEX), 
	.DstReg1_in_from_IDEX(DstReg1_in_from_IDEX),
	.PC_in(PC_out_IFID),
	.PC_out(PC_out_IDEX));

/////////////// EXECUTE (EX) /////////////////////////

	//////////////////////////////////////////////
	// ID:
	// @ Reg2Src
	// 
	// EX:
	// @ ALUSrc
	// @ LBIns
	//
	// MEM:
	// @ MemWrite
	//
	// WB:
	// @ RegWrite
	// @ MemtoReg
	// @ PCtoReg
	// @ Halt
	// @ BranchType
	// @ BranchIns
	//////////////////////////////////////////////

	/////////////// ALU ///////////////////////////
	wire[1:0] ALU_src1_fwd, ALU_src2_fwd, LB_ins_fwd;
	wire[15:0] load_higher_byte, load_lower_byte;
	wire[15:0] ALU_mux_out_MEM;

	wire X2X_LB, M2X_LB;
	wire[15:0] LB_ins_input;
	assign X2X_LB = LB_ins_fwd[1];
	assign M2X_LB = LB_ins_fwd[0];
	
	// handle Load Byte instructions
	// if opcode[0] is true, then it is load higher byte, lower byte otherwise
	assign loaded_byte = ALU_Opcode_EX[0] ? load_higher_byte : load_lower_byte;
	// Determine whether to use forwarded register value or not
	assign LB_ins_input = X2X_LB ? ALU_mux_out_MEM : (M2X_LB ? ALU_mux_out_WB : reg_data2_from_IDEX);
	// LOWER 8 bits (LHB)
	assign load_higher_byte = {{SrcReg1_in_from_IDEX, LLB_LHB_from_IDEX},{LB_ins_input[7:0]}};
	// UPPER 8 bits (LLB)
	assign load_lower_byte = {{LB_ins_input[15:8]},{SrcReg1_in_from_IDEX, LLB_LHB_from_IDEX}};
	assign ALU_mux_out = LBIns_EX ? loaded_byte : ALU_Out;

	wire X2X_1, M2X_1, X2X_2, M2X_2;
	assign X2X_1 = ALU_src1_fwd[1];
	assign M2X_1 = ALU_src1_fwd[0];
	assign X2X_2 = ALU_src2_fwd[1];
	assign M2X_2 = ALU_src2_fwd[0];

	wire [15:0] imm_unshifted, imm_shifted;
	wire [15:0] ALU_data;
	assign imm_unshifted = {{12{LLB_LHB_from_IDEX[3]}}, LLB_LHB_from_IDEX[3:0]};
	assign {junk, imm_shifted} = {imm_unshifted, 1'b0};

	// ALUSrc_EX controls if RegisterSrcData2 or Signextedimm goes in to ALU src 2, 1 for offset, 0 for Reg_out2
	// Also uses forwarded data if necessary
	assign ALU_In1 = X2X_1 ? ALU_mux_out_MEM : (M2X_1 ? reg_wrt_data : reg_data1_from_IDEX);
	assign ALU_In2 = X2X_2 ? ALU_mux_out_MEM : (M2X_2 ? reg_wrt_data : 
						(ALUSrc_EX ? ((|Control_EX_to_MEM) ? imm_shifted : imm_unshifted): reg_data2_from_IDEX));
	assign ALU_data = X2X_2 ? ALU_mux_out_MEM : (M2X_2 ? reg_wrt_data : reg_data2_from_IDEX);

	wire Flags_Set;

	ALU iALU(
	.ALU_Out(ALU_Out),
	.ALU_In1(ALU_In1),
	.ALU_In2(ALU_In2),
	.Opcode(ALU_Opcode_EX),
	.isALU(~Reg2Src_EX),
	.Flags(FLAGS),
	.Flags_Set(Flags_Set));

	/////////////// ALU END/////////////////////////

/////////////// EX/MEM ///////////////////////////

	wire MemWrite_MEM, MemRead_MEM;
	wire[15:0] ALU_data_MEM;
	wire[3:0] Control_MEM_to_WB;
	wire[3:0] DstReg1_in_from_EXMEM, SrcReg2_in_from_EXMEM;

	// FLAGS register is built into pipeline
	pipeline_EXMEM iPipe_EXMEM(
	.clk(clk),
	.rst(rst_reg),
	.WB(Control_EX_to_WB),
	.mem(Control_EX_to_MEM),
	.flagsIn(FLAGS),
	.reg_data_in(ALU_mux_out),
	.ALU_data_in(ALU_data),
	.ALU_data_out(ALU_data_MEM),
	.DstReg_in(DstReg1_in_from_IDEX),
	.SrcReg2_in(SrcReg2_in_from_IDEX),
	.MemWrite(MemWrite_MEM),
	.MemRead(MemRead_MEM),
	.Flags_Set(Flags_Set),
	.stall(DSTALL),
	.flagsOut(FLAGS_MEM),
	.to_WBReg(Control_MEM_to_WB),
	.reg_data_out(ALU_mux_out_MEM),
	.DstReg_out(DstReg1_in_from_EXMEM),
	.SrcReg2_out(SrcReg2_in_from_EXMEM),
	.PC_in(PC_out_IDEX),
	.PC_out(PC_out_EXMEM));

/////////////// MEMORY (MEM) /////////////////////////

	/////////////// D-MEM //////////////////////////
	wire[15:0] dmem_data_in;
	wire[15:0] dmem_addr;
	wire dmem_wr, DMEM_fwd;

	// DCACHE would go here, but is placed near MCM

	assign dmem_data_in = DMEM_fwd ? dmem_data_out_WB : ALU_data_MEM;
	assign dmem_addr = ALU_mux_out_MEM;
	assign dmem_wr = MemWrite_MEM;
	/////////////// D-MEM END////////////////////////

/////////////// MEM/WB ///////////////////////////

	pipeline_MEMWB iPipe_MEMWB(
	.clk(clk),
	.rst(rst_reg),
	.WB(Control_MEM_to_WB),
	.reg_data_in(ALU_mux_out_MEM),
	.dmem_in(dmem_data_out),
	.DstReg_in(DstReg1_in_from_EXMEM),
	.RegWrite(RegWrite_MEMWB),
	.MemtoReg(MemtoReg_WB),
	.PCtoReg(PCtoReg_WB),
	.Halt(Halt_WB),
	.reg_data_out(ALU_mux_out_WB),
	.dmem_out(dmem_data_out_WB),
	.DstReg_out(DstReg1_in_from_MEMWB),
	.PC_in(PC_out_EXMEM),
	.PC_out(PC_out_MEMWB));

/////////////// WRITEBACK (WB) ///////////////////////

/////////////// FORWARDING ///////////////////////////

forwarding_unit iFWD(
	.ALU_src1_fwd(ALU_src1_fwd),
	.ALU_src2_fwd(ALU_src2_fwd),
	.LB_ins_fwd(LB_ins_fwd),
	.RegWrite_EXMEM(Control_MEM_to_WB[3]),
	.RegWrite_MEMWB(RegWrite_MEMWB),
	.MemWrite_MEM(MemWrite_MEM),
	.SrcReg2_in_from_EXMEM(SrcReg2_in_from_EXMEM),
	.DstReg1_in_from_EXMEM(DstReg1_in_from_EXMEM),
	.DstReg1_in_from_MEMWB(DstReg1_in_from_MEMWB),
	.SrcReg1_in_from_IDEX(SrcReg1_in_from_IDEX),
	.SrcReg2_in_from_IDEX(SrcReg2_in_from_IDEX),
	.DstReg1_in_from_IDEX(DstReg1_in_from_IDEX),
	.MemRead_MEM(MemRead_MEM),
	.DMEM_fwd(DMEM_fwd));

/////////////// STALLS ///////////////////////////

hazDetect iHaz(
	.memRead_DX(Control_EX_to_MEM[0]),
	.memRead_XM(MemRead_MEM),
	.registerRd_DX(DstReg1_in_from_IDEX),
	.registerRs_FD(SrcReg1_in_to_IDEX),
	.registerRt_FD(LLB_LHB_to_IDEX),
	.registerRd_XM(DstReg1_in_from_EXMEM),
	.memWrite_FD(MemWrite),
	.Flags_Set(Flags_Set),
	.BranchIns(BranchIns),
	.BranchType(BranchType),
	.stall(stall));

/////////////// MEMORY ///////////////////////////

wire [15:0] mcm_data_out;
wire [15:0] ICACHE_read_addr, DCACHE_read_addr;
wire mcm_data_valid;

memory4c MCMEM(
	.data_out(mcm_data_out),
	.data_in(dmem_data_in),
	.addr(ISTALL ? ICACHE_read_addr : DCACHE_read_addr),
	.enable(ISTALL | DSTALL),
	.wr(MemWrite_MEM & ~ISTALL & ~DCACHE_miss),
	.clk(clk),
	.rst(rst_reg),
	.data_valid(mcm_data_valid));

/*memory1c IMEM(
	.data_out(imem_data_out_to_IFID),
	.data_in(),
	.addr(PC_out_to_IFID),
	.enable(1'b1),
	.wr(1'b0),
	.clk(clk),
	.rst(rst_reg));*/

cache ICACHE(
	.clk(clk),
	.rst(rst_reg),
	.cacheAddress(PC_out_to_IFID),
	.cacheDataOut(imem_data_out_to_IFID),
	.cacheDataIn(mcm_data_out),
	.writeEnable(1'b0),//ISTALL),
	.memory_data_valid(mcm_data_valid),
	.cache_stall(ISTALL),
	.memory_address(ICACHE_read_addr),
	.waitForICACHE(1'b0),
	.miss_detected());


memory1c DMEM(
	.data_out(dmem_data_out),
	.data_in(dmem_data_in),
	.addr(dmem_addr),
	.enable(MemWrite_MEM | MemRead_MEM),
	.wr(dmem_wr),
	.clk(clk),
	.rst(rst_reg));

wire [15:0] DCACHE_addr = (MemWrite_MEM | MemRead_MEM) ? dmem_addr : 16'h0000;

cache DCACHE(
	.clk(clk),
	.rst(rst_reg),
	.cacheAddress(DCACHE_addr),
	.cacheDataOut(dmem_data_out),
	.cacheDataIn(dmem_data_in),
	.writeEnable(MemWrite_MEM),
	.memory_data_valid(mcm_data_valid),
	.cache_stall(DSTALL),
	.memory_address(DCACHE_read_addr),
	.waitForICACHE(ISTALL),
	.miss_detected(DCACHE_miss));
	
endmodule
