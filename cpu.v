module cpu(clk, rst_n, hlt, pc);

	input clk;
	// Active low reset. A low on this signal resets the processor and causes
	// execution to start at address 0x0000
	// **** rst_n = active low reset
	// **** rst = active high reset
	input rst_n;
	// Assert when HLT encountered, after finishing prior instruction
	output hlt;
	output[15:0] pc; // program counter

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

	

	/////////////// D-MEM ////////////////////////
	wire[15:0] dmem_data_out;
	wire[15:0] dmem_data_in;
	wire[15:0] dmem_addr;
	wire dmem_enable;
	wire dmem_wr;

	memorylc DMEM(.data_out(dmem_data_out), .data_in(dmem_data_in), .addr(dmem_addr),
			.enable(dmem_enable), .wr(dmem_wr), .clk(clk), .rst(~rst_n));
	/////////////// D-MEM END////////////////////////

	/////////////// REG FILE ////////////////////////
	
	wire rst_reg = ~rst_n;
	wire RegWrite;
	// imem_data_out[7:4] is Rs
	// imem_data_out[3:0] is Rt in [OPCODE][Rd][Rs][Rt/imm]
	// imem_data_out[11:8]
	RegisterFile IREGFILE(.clk(clk), .rst(rst_reg), .SrcReg1(imem_data_out[7:4]), .SrcReg2(imem_data_out[3:0]), .DstReg(imem_data_out[11:8]), 
			.WriteReg(RegWrite), .DstData(), .SrcData1(ALU_In1), .SrcData2(RegFile_SrcData2));

	/////////////// REG FILE END ////////////////////////

	/////////////// ALU //////////////////////////
	wire[1:0] ALU_Opcode = pc[13:12];
	wire[15:0] ALU_In1, ALU_In2, RegFile_SrcData2;
	wire[15:0] ALU_Out;
	wire ALU_Error;

	assign ALU_In2 = ALUSRC ? {{12{imem_data_out[3]}}, imem_data_out[3:0]}: RegFile_SrcData2;

	ALU iALU(.ALU_Out(ALU_Out), .Error(ALU_Error), .ALU_In1(ALU_In1), .ALU_In2(ALU_In2),
			.Opcode(ALU_Opcode));
	/////////////// ALU END//////////////////////////

	/////////////// I-MEM ////////////////////////
	wire[15:0] imem_data_out;
	wire[15:0] imem_data_in;
	wire[15:0] imem_addr;
	wire imem_enable;
	wire imem_wr;

	memorylc IMEM(.data_out(imem_data_out), .data_in(imem_data_in), .addr(imem_addr),
			.enable(imem_enable), .wr(imem_wr), .clk(clk), .rst(~rst_n));

	// Determine if ALU result or read from memory is desired

	wire[15:0] imem_result;
	assign imem_addr = ALU_Out;
	assign imem_result = MemtoReg ? imem_data_out : ALU_Out;

	/////////////// I-MEM END////////////////////////

	/////////////// Control Signals //////////////
	////might move this to seperate module?/////
	wire [3:0]opcode;
	assign opcode = imem_data_out[15 : 12];

	// ALUSRC controls if RegisterSrcData2 or Signextedimm goes in to ALU src 2
	assign ALUSRC = ((~opcode[3]) & opcode[2]) & (~(opcode[1] & opcode[0]));
	//assign RegWrite = 


	///////////// Control Signals END//////////////
	

endmodule
