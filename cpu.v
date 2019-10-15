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
	wire [15:0] reg_data1, reg_data2, reg_wrt_data, SrcReg1_in, SrcReg2_in;
	wire [15:0] ALU_In1, ALU_In2, RegFile_SrcData2, ALU_Out, ALU_mux_out, loaded_byte;
	wire [15:0] PC_out, PC_in;

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
	wire [15:0] PC_out, PC_in;

	/////////////// I-MEM ////////////////////////
	wire[15:0] imem_data_out;
	wire[15:0] imem_addr;

	memorylc IMEM(.data_out(imem_data_out), .data_in(imem_data_in), .addr(PC_out),
			.enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));

	/////////////// I-MEM END////////////////////////

	/////////////// Control Signals //////////////
	wire [3:0]opcode;
	wire [2:0]FLAGS, ALU_FLAG_out;
	assign opcode = imem_data_out[15 : 12];
	
	// ALUSRC controls if RegisterSrcData2 or Signextedimm goes in to ALU src 2, 1 for offset, 0 for Reg_out2
	assign ALUSRC = ((~opcode[3]) & opcode[2]) & (~(opcode[1] & opcode[0]));

	// RegWrite determines if writedata[15:0] will be writen into Dstreg
	assign RegWrite = (~opcode[3]) | ~(&opcode) ;

	// Reg1Src determines which bits from the opcode is going to used as the address in register src 1
	//assign Reg1Src = 1;

	// Reg2Src determines which bits from the opcode is going to used as the address in register src 2
	// Reg2Src only need to be asserted to 1 for SW, LLB, LHB
	assign Reg2Src = 1;

	// MemtoReg determines if write data in the registerfile will receive from the ALU or Data Memory
	assign MemtoReg = 1;

	// MemWrite determines if [15:0] data from Register output 2 gets writen into address from ALU output
	assign MemWrite = 1;

	// BranchType 0 if its Branch immediate ins, 1 if Branch Register
	assign BranchType = 1;

	// BranchIns, 1 if opcode is a branch instruction, 0 if not
	assign BranchIns = 1;

	// Halt
	assign Halt = &opcode;

	// LBIns, 1 if opcode is LoadBype instruction, 0 otherwise
	assign LBIns = 0;

	// PCtoReg, 1 if want to write PC to dstReg
	assign PCtoReg = 0;

	///////////// Control Signals END//////////////

	///////////// FLAG Register /////////////////////////
	FlagRegister iFG(.flag_reg_input(ALU_FLAG_out), .flag_reg_output(FLAGS), .clk(clk), .wen(~Halt), .rst(rst_reg));

	///////////// FLAG REGISTER END /////////////////////

	////////////// PC and PC control /////////////////////

	PC iPC(.clk(clk), .rst(rst_reg), .write_en(1'b1), .PC_in(PC_in), .PC_out(PC_out));
	//PC control needs to be changed to take care of branch register ins
	PC_control iPC_control(
	.C(imem_data_out[11:9]), 
	.I(imem_data_out[8:0]),
	.F(FLAGS),
	.PC_control_in(PC_out),
	.reg2_data(reg_data1),
	.branch_type(BranchType),
	.halt(Halt),
	.branch_ins(BranchIns),
	.PC_control_out(PC_in)
	);


	////////////// PC control END /////////////////

	/////////////// D-MEM //////////////////////////
	wire[15:0] dmem_data_out;
	wire[15:0] dmem_data_in;
	wire[15:0] dmem_addr;
	wire dmem_enable;
	wire dmem_wr;

	memory1c DMEM(.data_out(dmem_data_out), .data_in(dmem_data_in), .addr(dmem_addr),
			.enable(dmem_enable), .wr(dmem_wr), .clk(clk), .rst(~rst_n));

	
	/////////////// D-MEM END////////////////////////

	/////////////// Registers //////////////////////
	// @ imem_data_out[7:4] is Rs
	// @ imem_data_out[3:0] is Rt in [OPCODE][Rd][Rs][Rt/imm]
	// @ imem_data_out[11:8]
	
	// Reg2Src determines which bits from the instruction is going to used as the address in register src 2. 1 for []
	assign SrcReg1_in = imem_data_out[7:4];
	assign SrcReg2_in = Reg2Src? imem_data_out[11:8] :imem_data_out[3:0];
	RegisterFile IREGFILE(.clk(clk), .rst(rst_reg), .SrcReg1(SrcReg1_in), .SrcReg2(SrcReg2_in), .DstReg(imem_data_out[11:8]), 
			.WriteReg(RegWrite), .DstData(reg_wrt_data), .SrcData1(reg_data1), .SrcData2(reg_data2));

	assign reg_wrt_data = MemtoReg ? dmem_data_out : (PCtoReg ? PC_out: ALU_mux_out);
	/////////////// Registers End///////////////////

	/////////////// ALU ///////////////////////////
	wire[2:0] ALU_Opcode = pc[13:11];
	

	// handle Load Byte instructions
	// if opcode[0] is true, then it is load higher byte, lower byte otherwise
	assign loaded_byte = opcode[0]? ({{imem_data_out[7:0]},{reg_data2[7:0]}}): ({{reg_data2[15:8]},{imem_data_out[7:0]}});
	assign ALU_mux_out = LBIns ? loaded_byte : ALU_Out; 
	// ALUSRC controls if RegisterSrcData2 or Signextedimm goes in to ALU src 2, 1 for offset, 0 for Reg_out2
	assign ALU_In2 = ALUSRC ? {{12{imem_data_out[3]}}, imem_data_out[3:0]}: RegFile_SrcData2;

	ALU iALU(.ALU_Out(ALU_Out), .ALU_In1(ALU_In1), .ALU_In2(ALU_In2), .Opcode(ALU_Opcode), .Flags(FLAGS));
	/////////////// ALU END/////////////////////////

	
endmodule
