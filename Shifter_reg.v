module Shifter_reg (Shift_Out, Shift_In, Shift_Val, Mode);

input [15:0] Shift_In; // This is the input data to perform shift operation on
input [3:0] Shift_Val; // Shift amount (used to shift the input data)
input  Mode; // To indicate 0=SLL or 1=SRA
output [15:0] Shift_Out; // Shifted output data

wire [15:0] Shift_1, Shift_2, Shift_4, Shift_8;

assign Shift_1 = Shift_Val[0] ? Mode? {Shift_In[15], Shift_In[15:1]} : {Shift_In[14:0], 1'b0}
                                : Shift_In;

assign Shift_2 = Shift_Val[1] ? Mode? {{2{Shift_1[15]}}, Shift_1[15:2]} : {Shift_1[13:0], 2'b00}
                                : Shift_1;

assign Shift_4 = Shift_Val[2] ? Mode? {{12{Shift_2[15]}}, Shift_2[15:4]} : {Shift_2[11:0], 4'h0}
                                : Shift_2;

assign Shift_8 = Shift_Val[3] ? Mode? {{8{Shift_4[15]}}, Shift_4[15:8]} : {Shift_4[7:0], 8'h00}
                                : Shift_4;

assign Shift_Out = Shift_8;

endmodule
