module Shifter_tb ();
reg [15:0] Shift_In; 	// This is the input data to perform shift operation on
reg [3:0] Shift_Val; 	// Shift amount (used to shift the input data)
reg  Mode; 		// To indicate 0=SLL or 1=SRA 
reg clk;

wire [15:0] Shift_Out; 	// Shifted output data

integer i;
reg [15:0] f;
reg [31:0] e;

// instantiate DUT
Shifter DUT(.Shift_Out(Shift_Out), .Shift_In(Shift_In), .Shift_Val(Shift_Val), .Mode(Mode));

initial begin
    clk = 0;
        
    Mode = 00;
    for(i = 0; i <= 20; i=i+1)begin
        //@(posedge clk)	    
	Shift_In = $random;
        Shift_Val = $random;
	    f = Shift_In << Shift_Val;
	    //$display("%d, %d, %d, %d, %d", a, b, arith, f, error);
	    if(Shift_Out != f) begin
	      $display("Incorrect match in SLL %d << %d != %d", Shift_In, Shift_Val, Shift_Out);
	      $stop;
	    end
    end
	  //$stop;

    Mode = 01;
    for(i = 0; i <= 20; i=i+1)begin
        //@(posedge clk)	    
	Shift_In = $random;
        Shift_Val = $random;
	    f = Shift_In >>> Shift_Val;
	    //$display("%d, %d, %d, %d, %d", a, b, arith, f, error);
	    if(Shift_Out != f) begin
	      $display("Incorrect match in SLL %d >>> %d != %d", Shift_In, Shift_Val, Shift_Out);
	      $stop;
	    end
    end
	  //$stop;

    Mode = 10;
    for(i = 0; i <= 20; i=i+1)begin
        //@(posedge clk)	    
	Shift_In = $random;
        Shift_Val = $random;
	    e = {Shift_In, Shift_In} >> Shift_Val;
	    f = e[15:0] ;
	    //$display("%d, %d, %d, %d, %d", a, b, arith, f, error);
	    if(Shift_Out != f) begin
	      $display("Incorrect match in SLL %d >>> %d != %d", Shift_In, Shift_Val, Shift_Out);
	      $stop;
	    end
    end
	  //$stop;
     	  $display("All tests passed");
	  $stop;
end

always
    #5 clk = ~clk;

endmodule