/* Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 8, 2019 */

module cpu(clk, rst_n, hlt, pc);

	input clk;

	// Active low reset. A low on this signal resets the processor and causes
	// execution to start at address 0x0000
	input rst_n;
	wire rst_reg = ~rst_n;

	// Assert when HLT encountered, after finishing prior instruction
	output hlt;
	output[15:0] pc; // program counter

	// Register and ALU , and PC wires
	wire [15:0] reg_data1, reg_data2, reg_wrt_data;
	wire [3:0] SrcReg1_in, SrcReg2_in;
	wire [15:0] ALU_In1, ALU_In2, RegFile_SrcData2, ALU_Out, ALU_mux_out, loaded_byte;
	wire [15:0] PC_out_to_IFID, PC_out_from_IFID;
	wire [15:0] PC_in;

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
	memory1c IMEM(.data_out(imem_data_out_to_IFID), .data_in(), .addr(PC_out_to_IFID),
			.enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));

	//////////////// Opcode and control //////////
	wire[3:0] opcode;// TODO: forward opcode to ID?
	assign opcode = imem_data_out_to_IFID[15 : 12];
	// BranchType 0 if its Branch immediate ins, 1 if Branch Register
	assign BranchType = opcode[0];

	// BranchIns, 1 if opcode is a branch instruction, 0 if not
	assign BranchIns = opcode[3]&opcode[2]&~opcode[1];

	/////////////// PC and PC control ////////////
	wire[2:0] FLAGS, ALU_FLAG_out;
	FlagRegister iFG(.flag_reg_input(ALU_FLAG_out), .flag_reg_output(FLAGS), .clk(clk), .wen(~Halt), .rst(rst_reg));

	PC iPC(.clk(clk), .rst(rst_reg), .write_en(1'b1), .PC_in(PC_in), .PC_out(PC_out_to_IFID));

	PC_control iPC_control(
	.C(imem_data_out_to_IFID[11:9]), 
	.I(imem_data_out_to_IFID[8:0]),
	.F(FLAGS),
	.PC_control_in(PC_out_to_IFID),
	.reg2_data(reg_data1),
	.branch_type(BranchType),
	.halt(Halt),
	.branch_ins(BranchIns),
	.PC_control_out(PC_in)
	);

	assign hlt = Halt;
	assign pc = PC_out_to_IFID;

/////////////// IF/ID ///////////////////////////

	pipeline_IFID iPipe_IFID(.clk(clk), .rst(rst_reg), .PC_out_to_IFID(PC_out_to_IFID), .PC_out_from_IFID(PC_out_from_IFID),
			.imem_data_out_to_IFID(imem_data_out_to_IFID), .imem_data_out_from_IFID(imem_data_out_from_IFID));

/////////////// DECODE (ID) ////////////////////////////

	/////////////// Control Signals //////////////

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

	// Halt
	assign Halt = &opcode;

	// LBIns, 1 if opcode is LoadBype instruction, 0 otherwise
	assign LBIns = opcode[3];

	// PCtoReg, 1 if want to write PC to dstReg
	assign PCtoReg = opcode[3]&opcode[2]&opcode[1]&~opcode[0];

	///////////// Control Signals END//////////////

	/////////////// Registers //////////////////////
	// @ imem_data_out_from_IFID[7:4] is Rs
	// @ imem_data_out_from_IFID[3:0] is Rt in [OPCODE][Rd][Rs][Rt/imm]
	// @ imem_data_out_from_IFID[11:8]

	wire[15:0] dmem_data_out;
	
	// Reg2Src determines which bits from the instruction is going to used as the address in register src 2. 1 for []
	assign SrcReg1_in = imem_data_out_from_IFID[7:4];
	assign SrcReg2_in = Reg2Src? imem_data_out_from_IFID[11:8] :imem_data_out_from_IFID[3:0];
	RegisterFile IREGFILE(.clk(clk), .rst(rst_reg), .SrcReg1(SrcReg1_in), .SrcReg2(SrcReg2_in), .DstReg(imem_data_out_from_IFID[11:8]), 
			.WriteReg(RegWrite), .DstData(reg_wrt_data), .SrcData1(reg_data1), .SrcData2(reg_data2));

	//PC_in here, because it will be the output from PC_control, which is the already incremented PC
	assign reg_wrt_data = MemtoReg ? dmem_data_out : (PCtoReg ? PC_in: ALU_mux_out);
	/////////////// Registers End///////////////////

/////////////// ID/EX ///////////////////////////

	/*Bit16Reg RF1_reg_IDEX(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(reg_data1_to_IDEX), .reg_out(reg_data1_from_IDEX));
	Bit16Reg RF2_reg_IDEX(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(reg_data2_to_IDEX), .reg_out(reg_data2_from_IDEX));

	Bit4Reg FWD_reg1_IDEX(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(SrcReg1_in_to_IDEX), .reg_out(SrcReg1_in_from_IDEX));
	Bit4Reg FWD_reg2_IDEX(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(SrcReg2_in_to_IDEX), .reg_out(SrcReg2_in_from_IDEX));*/

/////////////// EXECUTE (EX) /////////////////////////

	/////////////// ALU ///////////////////////////
	wire[2:0] ALU_Opcode = imem_data_out_from_IFID[15:12] == 4'b1001 ? 3'b000 : imem_data_out_from_IFID[14:12];
	
	// handle Load Byte instructions
	// if opcode[0] is true, then it is load higher byte, lower byte otherwise
	assign loaded_byte = opcode[0]? ({{imem_data_out_from_IFID[7:0]},{reg_data2[7:0]}}): ({{reg_data2[15:8]},{imem_data_out_from_IFID[7:0]}});
	assign ALU_mux_out = LBIns ? loaded_byte : ALU_Out; 
	// ALUSrc controls if RegisterSrcData2 or Signextedimm goes in to ALU src 2, 1 for offset, 0 for Reg_out2
	assign ALU_In1 = reg_data1;//fwd_ALU_1 ? ALU_src1_fwd : reg_data1_from_IDEX;
	assign ALU_In2 = ALUSrc ? {{11{imem_data_out_from_IFID[3]}}, imem_data_out_from_IFID[3:0], 1'b0}: reg_data2;//fwd_ALU_2 ? ALU_src2_fwd : (ALUSrc ? {{11{imem_data_out[3]}}, imem_data_out[3:0], 1'b0}: reg_data2_from_IDEX);

	ALU iALU(.ALU_Out(ALU_Out), .ALU_In1(ALU_In1), .ALU_In2(ALU_In2), .Opcode(ALU_Opcode), .Flags(FLAGS));
	/////////////// ALU END/////////////////////////

/////////////// EX/MEM ///////////////////////////

	/*Bit16Reg LB_reg_EXMEM(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(ALU_mux_out_to_EXMEM), .reg_out(ALU_mux_out_from_EXMEM));
	Bit16Reg ALU_reg_EXMEM(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(ALU_Out_to_EXMEM), .reg_out(ALU_Out_from_EXMEM));
	Bit16Reg REG_reg_EXMEM(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(ALU_In2), .reg_out(ALU_In2_from_EXMEM));*/

/////////////// MEMORY (MEM) /////////////////////////

	/////////////// D-MEM //////////////////////////
	wire[15:0] dmem_data_in;
	wire[15:0] dmem_addr;
	wire dmem_wr;

	memory1c DMEM(.data_out(dmem_data_out), .data_in(dmem_data_in), .addr(dmem_addr),
			.enable(1'b1), .wr(dmem_wr), .clk(clk), .rst(~rst_n));

	assign dmem_data_in = ALU_In2;//fwd_MEM ? MEM_src1_fwd : ALU_In2_from_EXMEM;
	assign dmem_addr = ALU_Out;
	assign dmem_wr = MemWrite;
	/////////////// D-MEM END////////////////////////

/////////////// MEM/WB ///////////////////////////

	//Bit16Reg DMEM_reg_MEMWB(.clk(clk), .rst(rst_reg), .write_en(1'b1), .reg_in(dmem_data_out_to_MEMWB), .reg_out(dmem_data_out_from_MEMWB));

/////////////// WRITEBACK (WB) ///////////////////////

/////////////// FORWARDING ///////////////////////////
	
endmodule
