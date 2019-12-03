/* Author: Ilhan Bok
   Class: ECE 552-1
   Group: Memory Loss
   Last Modified: Nov. 17, 2019 */

module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy,
						write_data_array, write_tag_array, memory_address,
						memory_data_valid, waitForICACHE, block_num);
input clk, rst_n;
// active high when tag match logic detects a miss
input miss_detected;

// address that missed the cache
input [15:0] miss_address;

// asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output reg fsm_busy = 1'b0;

// write enable to cache data array to signal when filling with memory_data
output reg write_data_array = 1'b0;

// write enable to cache tag array to signal when all words are filled in to data array
output reg write_tag_array = 1'b0;

// address to read from memory
output reg [15:0] memory_address = 16'h0000;

// block to store to cache
output reg [2:0] block_num = 3'b000;

// data returned by memory (after  delay)
//input [15:0] memory_data;

// active high indicates valid data returning on memory bus
input memory_data_valid;

// arbitration signal
input waitForICACHE;

// Create active high reset for convenience
assign rst = ~rst_n;

// store whether IDLE or WAITing
reg nxt_state = 1'b0;
wire state;
dff iFSM(.q(state), .d(nxt_state), .wen(1'b1), .clk(clk), .rst(rst));

// Keep track of number of words received, including overflow bit
wire [4:0] word_count;
reg [4:0] word_count_nxt = 5'b00000;

//assign memory_address = miss_address & 16'hFFE0 | {word_count, 1'b0};

// Indicate if state machine has lost it
reg error = 1'b0;
always @(*)
	casez({state, memory_data_valid, word_count, waitForICACHE})
		// memory_data_valid is true, so increment
		// No need to wait for ICACHE
		8'b11_000000 :
			begin
				word_count_nxt = 5'b00001; //0 + 1 = 1
				write_data_array = 1'b1;
				write_tag_array = 1'b0;
				memory_address = miss_address & 16'hFFF0 | 16'h0000;
				block_num = 3'b000;
			end
		// Keep waiting until memory is free
		8'b11_000001 :
			begin
				word_count_nxt = 5'b00000;
				write_data_array = 1'b0;
			end
		// All clear, so proceed
		8'b11_00001? :
			begin
				word_count_nxt = 5'b00010; //1 + 1 = 2
				write_data_array = 1'b1;
				memory_address = miss_address & 16'hFFF0 | 16'h0002;
				block_num = 3'b000;
			end
		8'b11_00010? :
			begin
				word_count_nxt = 5'b00011; //2 + 1 = 3
				write_data_array = 1'b1;
				memory_address = miss_address & 16'hFFF0 | 16'h0004;
				block_num = 3'b000;
			end
		8'b11_00011? :
			begin
				word_count_nxt = 5'b00100; //3 + 1 = 4
				write_data_array = 1'b1;
				memory_address = miss_address & 16'hFFF0 | 16'h0006;
				block_num = 3'b000;
			end
		8'b11_00100? :
			begin
				word_count_nxt = 5'b00101; //4 + 1 = 5
				write_data_array = 1'b1;
				memory_address = miss_address & 16'hFFF0 | 16'h0008;
				block_num = 3'b000;
			end
		8'b11_00101? :
			begin
				word_count_nxt = 5'b00110; //5 + 1 = 6
				write_data_array = 1'b1;
				memory_address = miss_address & 16'hFFF0 | 16'h000A;
				block_num = 3'b001;
			end
		8'b11_00110? :
			begin
				word_count_nxt = 5'b00111; //6 + 1 = 7
				write_data_array = 1'b1;
				memory_address = miss_address & 16'hFFF0 | 16'h000C;
				block_num = 3'b010;
			end
		8'b11_00111? :
			begin
				word_count_nxt = 5'b01000; //7 + 1 = 8
				write_data_array = 1'b1;
				memory_address = miss_address & 16'hFFF0 | 16'h000E;
				block_num = 3'b011;
			end
		8'b11_01000? :
			begin
				word_count_nxt = 5'b01001; //8 + 1 = 9
				write_data_array = 1'b1;
				block_num = 3'b100;
			end
		8'b11_01001? :
			begin
				word_count_nxt = 5'b01010; //9 + 1 = 10
				write_data_array = 1'b1;
				block_num = 3'b101;
			end
		8'b11_01010? :
			begin
				word_count_nxt = 5'b01011; //10 + 1 = 11
				write_data_array = 1'b1;
				block_num = 3'b110;
			end
		8'b11_01011? :
			begin
				word_count_nxt = 5'b01100; //11 + 1 = 12
				write_data_array = 1'b1;
				write_tag_array = 1'b1;
				block_num = 3'b111;
			end
		8'b11_01100? :
			begin
				word_count_nxt = 5'b10000; //11 + 1 = 12
				write_data_array = 1'b0;
				write_tag_array = 1'b0;
			end
		8'b1?_10000? :
			begin
				word_count_nxt = 5'b00000; // start over
				write_data_array = 1'b0;
				write_tag_array = 1'b0;
			end
		// finalize by sending tag array bit
		/*8'b11_10000? :
			begin
				word_count_nxt = 5'b00000; // start over
				write_data_array = 1'b0;
				write_tag_array = 1'b1;
			end*/
		// do not increment
		8'b10_?????? :
			begin
				word_count_nxt = word_count;
				write_data_array = 1'b0;
				write_tag_array = 1'b0;
			end
		// should never enter this state
		default :
			begin
				error = 1'b1;
			end
	endcase
	
Bit5Reg iCount(.clk(clk), .rst(rst), .write_en(1'b1), .reg_in(word_count_nxt), .reg_out(word_count));

// track whether IDLE or WAITing
// 0 : IDLE
// 1 : WAIT
always @(*)
	casez ({state, miss_detected, word_count_nxt[4]})
		// IDLE and no cache miss
		3'b00? :
			begin
				nxt_state = 1'b0; // Stay in IDLE until cache miss
				fsm_busy = 1'b0; // Not handling a miss
			end
		// IDLE and cache miss
		3'b01? :
			begin
				nxt_state = 1'b1; // Miss detected, so change state
				fsm_busy = 1'b1; // Handling a miss
				memory_address = miss_address;
			end
		// WAIT and more to receive
		3'b1?0 :
			begin
				nxt_state = 1'b1; // Still more data to receive
				fsm_busy = 1'b1; // Still handling a miss
			end
		// WAIT and done receiving
		3'b1?1 :
			begin
				nxt_state = 1'b0; // Return to IDLE state
				fsm_busy = 1'b0; // Done with the miss
			end
	endcase
endmodule
