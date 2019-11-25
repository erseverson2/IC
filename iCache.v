module iCache (clk. rst, cacheAddress, cacheData, writeEnable);
     input clk, rst, writeEnable;
     input [15:0] cacheAddress; // address of data
     output [15:0] cacheData;   //

     wire [15:0] cacheMiss;   // signal for a cacheMiss
     wire [15:0] fromMemory;   // data to be put in cache


     // instantiate dataArray
     DataArray ICacheData(.clk(clk), .rst(rst), .DataIn(fromMemory), .Write(1), .BlockEnable(cacheAddress [9:4]), .WordEnable(cacheAddress [3:0]), .DataOut(cacheData));

     // instantiate MetaDataArray
     MetaDataArray IMetaDataArray(.clk(clk), .rst(rst), .DataIn(cacheAddress[15:10]), .Write(1), .BlockEnable(cacheAddress [9:4]), .DataOut(tagValid));

     // instantiate FSM for misses
     cache_fill_FSM(.clk(), .rst(), )
     // compare metadataArray output and DataArray output if same then cache hit else cache miss


     // if cacchemiss send signal to FSM 



     //3.1 Cache/Memory Specification
     //a. The processor will have separate single-cycle instruction and data caches, which are byte-
     //   addressable. Your caches will be 2KB (i.e,. 2048B) in size, 2-way set-associative, with cache 
     //   blocks of 16B each. Correspondingly, the data array would have 128 lines in total, each being 
     //   16 bytes wide. The meta-data array would have 128 total entries composed of 64 sets with 2 ways each. 
     //   Each entry in the meta-data array should contain the tag bits, the valid bit and one bit for LRU 
     //   replacement.
     //b. The cache write policy is write-through and write-allocate. This means that on hits, it writes to the
     //   cache and main memory in parallel. On misses it finds the block in main memory and brings that block 
     //   to the cache, and then re-performs the write (which will now be a cache hit; thus it will write to 
     //   both cache and memory in parallel).
     //c. The cache read policy is to read from the cache for a hit; on a miss, the data is brought back from 
     //   main memory to the cache and then the required word (from the block) is read out.
     //d. The memory module is the same as before, except for the longer read latency and a ?data_valid? output
     //   bit. A 2-byte write to memory from the processor will take one cycle, while a 2-byte read from memory 
     //   will take 4 cycles. Memory is pipelined, so read requests can be issued to memory on every cycle.
     //e. The cache modules will have the following interface: one 16-bit (2-byte) data output port, 
     //   one 16-bit (2-byte) address input port and a one-bit write-enable input 
     //   signal.
     //f. Note that the interaction between the memory and caches should occur at cache block (16-byte) 
     //   granularity. Considering that the data ports are only 2 bytes wide, this would require a burst of 8 
     //   consecutive data transfers.






endmodule
