module cache (clk, rst, cacheAddress, cacheDataOut, cacheDataIn, writeEnable, memory_data_valid, cache_stall, memory_address, waitForICACHE);
	input clk, rst, writeEnable;
	input [15:0] cacheAddress; // address of data
	input [15:0] cacheDataIn; // Data into cache
	input memory_data_valid;
	input waitForICACHE; // Arbitration check
	output [15:0] cacheDataOut; // Data read from cache
	output cache_stall; // stall if FSM busy
	output [15:0] memory_address; // sequential memory address to read

	wire [127:0] decode_set_data0, decode_set_data1;
	wire [7:0] decode_offset_data0, decode_offset_data1;

	wire [6:0] even_addr, odd_addr;
	wire [15:0] arrayDataOut1, arrayDataOut2;

	wire [2:0] block_num;

	wire write_data_array, write_tag_array;

	assign even_addr = cacheAddress[9:3] & 7'b111_1110;
	assign odd_addr = cacheAddress[9:3] | 7'b000_0001;

	// instantiate dataArray with decoder
	Dec7to128 iData_block0(.data(even_addr), .dec(decode_set_data0));
	Dec3to8 iData_word0(.data(cacheAddress[3:1]), .dec(decode_offset_data0), .wen(1'b1));

	Dec7to128 iData_block1(.data(odd_addr), .dec(decode_set_data1));
	Dec3to8 iData_word1(.data(cacheAddress[3:1]), .dec(decode_offset_data1), .wen(1'b1));

	wire LRU0 = 1'b1;
	wire [7:0] block_num_dec;
	wire [7:0] data0_word = cache_stall ? block_num_dec : decode_offset_data0;

	DataArray ICacheData0(
	.clk(clk),
	.rst(rst),
	.DataIn(cacheDataIn),
	.Write(write_data_array & writeEnable), //& LRU0 & writeEnable),
	.BlockEnable(decode_set_data0),
	.WordEnable(data0_word),
	.DataOut(arrayDataOut1));

	Dec3to8 find_Block0(.data(block_num), .dec(block_num_dec), .wen(1'b1));

	DataArray ICacheData1(
	.clk(clk),
	.rst(rst),
	.DataIn(cacheDataIn),
	.Write(write_data_array & writeEnable),//~LRU0 & writeEnable),
	.BlockEnable(decode_set_data1),
	.WordEnable(cache_stall ? block_num : decode_offset_data1),
	.DataOut(arrayDataOut2));

	cache_fill_FSM iFSM(
	.clk(clk),
	.rst_n(~rst),
	.miss_detected(miss_detected),
	.miss_address(cacheAddress),
	.fsm_busy(cache_stall),
	.write_data_array(write_data_array),
	.write_tag_array(write_tag_array),
	.memory_address(memory_address),
	.memory_data_valid(memory_data_valid),
	.waitForICACHE(waitForICACHE),
	.block_num(block_num));

	wire [127:0] decode_set_meta0, decode_set_meta1;
	wire [7:0] tagValid0, tagValid1;

	// instantiate MetaDataArrays
	// two such arrays are needed for parallel lookup
	Dec7to128 iMeta_block0(.data(even_addr), .dec(decode_set_meta0));
	Dec7to128 iMeta_block1(.data(odd_addr), .dec(decode_set_meta1));
	MetaDataArray IMetaDataArray0(
	.clk(clk),
	.rst(rst),
	.DataIn({2'b11, cacheAddress[15:10]}),//{1'b1, LRU0, cacheAddress[15:10]}),
	.Write(write_tag_array & writeEnable),// & LRU0 & writeEnable),
	.BlockEnable(decode_set_meta0),
	.DataOut(tagValid0));

	MetaDataArray IMetaDataArray1(
	.clk(clk),
	.rst(rst),
	.DataIn({2'b11, cacheAddress[15:10]}),//{1'b1, ~LRU0, cacheAddress[15:10]}),
	.Write(write_tag_array & writeEnable),// & ~LRU0 & writeEnable),
	.BlockEnable(decode_set_meta1),
	.DataOut(tagValid1));

	//dff iLRU(.q(LRU0), .d(data1Hit ? 1'b0 : data2Hit ? 1'b1 : ~tagValid0[6]), .wen(~write_tag_array), .clk(clk), .rst(rst));

	assign data1Hit = tagValid0[7] & (tagValid0[5:0] == cacheAddress[15:10]);
	assign data2Hit = tagValid1[7] & (tagValid1[5:0] == cacheAddress[15:10]);
	assign cacheDataOut = data1Hit ? arrayDataOut1 : data2Hit ? arrayDataOut2 : 16'h0000;

	assign miss_detected = ~(data1Hit | data2Hit);
	//assign LRU0 = data1Hit ? 1'b0 : data2Hit ? 1'b1 : ~tagValid0[6];

endmodule
