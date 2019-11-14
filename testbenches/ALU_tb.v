/* Author: Ilhan Bok
   Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Sep. 22, 2019 */

module ALU_tb;

	/////////////// Opcodes //////////////////////
	// ADD		000
	// SUB		001
	// XOR		010
	// RED		011
	// SLL		100
	// SRA		101
	// ROR		110
	// PADDSB	111
	/////////////// Opcodes //////////////////////

	/* Define all the Opcodes to prevent confusion */
	localparam ADD = 3'b000;
	localparam SUB = 3'b001;
	localparam XOR = 3'b010;
	localparam RED = 3'b011;
	localparam SLL = 3'b100;
	localparam SRA = 3'b101;
	localparam ROR = 3'b110;
	localparam PADDSB = 3'b111;

	wire[15:0] ALU_Out;
	
	reg[2:0] Opcode = 3'b000;
	reg signed[31:0] stim = 32'h00000000;

	// These operations can oveflow
	wire signed[4:0] B0, B1, B2, B3;
	wire signed[16:0] Sum, Diff;
	wire[15:0] SumLess, DiffLess;

	// These cannot
	wire[15:0] tXOR, tSLL, tROR, tPADDSB, Red, Red_unsigned;
	wire[3:0] BA, BB, BC, BD;
	wire[15:0] FSum, FDiff;

	// These cannot, but have sign
	wire signed[15:0] tSRA;
	reg signed[15:0] stimA, stimB;


	/* Simplified logic to test the ALU */
	assign Sum = stimA + stimB; // Addition
	assign Diff = stimA - stimB; // Subtraction
	assign tXOR = stim[31:16] ^ stim[15:0]; // XOR
	assign Red_unsigned = stim[31:24] + stim[23:16] + stim[15:8] + stim[7:0]; // RED
	assign Red = {{6{Red_unsigned[9]}}, Red_unsigned[9:0]};
	assign tSLL = stim[31:16] << stim[3:0]; // SLL
	assign tSRA = stimA >>> stim[3:0]; // SRA
	assign tROR = {stim[31:16], stim[31:16]} >> stim[3:0]; // ROR
	assign tPADDSB = {BD, BC, BB, BA};

	/* Check for overflow for + and - */
	assign FSum = (Sum < -32768) ? 16'h8000 : 
			(Sum > 32767) ? 16'h7FFF : Sum[15:0];
	assign FDiff = (Diff < -32768) ? 16'h8000 : 
			(Diff > 32767) ? 16'h7FFF : Diff[15:0];

	/* PADDSB requires more effort */
	assign BA = (B0 < -8) ? 4'b1000 :
			(B0 > 7) ? 4'b0111 : B0[3:0];
	assign BB = (B1 < -8) ? 4'b1000 :
			(B1 > 7) ? 4'b0111 : B1[3:0];
	assign BC = (B2 < -8) ? 4'b1000 :
			(B2 > 7) ? 4'b0111 : B2[3:0];
	assign BD = (B3 < -8) ? 4'b1000 :
			(B3 > 7) ? 4'b0111 : B3[3:0];
	assign B0 = {stim[3], stim[3:0]} + {stim[19], stim[19:16]};
	assign B1 = {stim[7], stim[7:4]} + {stim[23], stim[23:20]};
	assign B2 = {stim[11], stim[11:8]} + {stim[27], stim[27:24]};
	assign B3 = {stim[15], stim[15:12]} + {stim[31], stim[31:28]};

	ALU iALU(.ALU_Out(ALU_Out), .ALU_In1(stim[31:16]), .ALU_In2(stim[15:0]), .Opcode(Opcode));
	
	initial begin
	/* Bracketed [TERMS] indicate the type of error.
	   Test for addition, subtraction, overflow, XOR, and NAND */
		repeat (8) begin
		repeat (100) begin
			stim[31:0] = $random;
			stimA = stim[31:16];
			stimB = stim[15:0];
			#20;
			case (Opcode)
				ADD: begin
					if (ALU_Out != FSum) begin
						$display("[ADD] ALU: %d, TB: %d, A: %d, B: %d", ALU_Out, FSum, stimA, stimB);
						$stop;
					end
				end
				SUB: begin
					if (ALU_Out != FDiff) begin
						$display("[SUB] ALU: %d, TB: %d, A: %d, B: %d", ALU_Out, FDiff, stimA, stimB);
						$stop;
					end
				end
				XOR: begin
					if (ALU_Out != tXOR) begin
						$display("[XOR] ALU: %d, TB: %d, stim: %b", ALU_Out, tXOR, stim);
						$stop;
					end
				end
				RED: begin
					if (ALU_Out != Red) begin
						$display("[RED] ALU: %d, TB: %d, A: %d, B: %d, C: %d, D: %d", ALU_Out, Red, stim[31:24], stim[23:16], stim[15:8], stim[7:0]);
						$stop;
					end
				end
				SLL: begin
					if (ALU_Out != tSLL) begin
						$display("[SLL] ALU: %d, TB: %d, Shift_In: %b %d, shamt: %d", ALU_Out, tSLL, stim[31:16], stim[31:16], stim[3:0]);
						$stop;
					end
				end
				SRA: begin
					if (ALU_Out != tSRA) begin
						$display("[SRA] ALU: %d, TB: %d, Shift_In: %b %d, shamt: %d", ALU_Out, tSRA, stim[31:16], stim[31:16], stim[3:0]);
						$stop;
					end
				end
				ROR: begin
					if (ALU_Out != tROR) begin
						$display("[ROR] ALU: %d, TB: %d, Shift_In: %b %d, shamt: %d", ALU_Out, tROR, stim[31:16], stim[31:16], stim[3:0]);
						$stop;
					end
				end
				PADDSB: begin
					if (ALU_Out != tPADDSB) begin
						$display("[PADDSB] ALU: %d, TB: %d, stim: %b", ALU_Out, tPADDSB, stim);
						$stop;
					end
				end
				default:
					$error("Illegal case");
			endcase
		end
                assign Opcode = Opcode + 1'b1;
		end
		$display("All tests passed.");
	end
	
endmodule
