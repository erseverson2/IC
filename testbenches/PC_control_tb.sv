module PC_control_tb();

reg clk;
reg [2:0]stim_C, stim_F;
reg [8:0]stim_I;
reg [15:0]stim_PC_in;
reg [15:0]stim_reg2_data;
reg stim_branch_type, stim_halt, stim_branch_ins;
wire [15:0]mon_PC_out;

PC_control iDUT(
.C(stim_C), 
.I(stim_I),
.F(stim_F),
.PC_control_in(stim_PC_in),
.reg2_data(stim_reg2_data),
.branch_type(stim_branch_type),
.halt(stim_halt),
.branch_ins(stim_branch_ins),
.PC_control_out(mon_PC_out)
);


initial begin
  clk = 0;
  
  // test for normal PC increment
  @(negedge clk);
  stim_branch_ins = 0;
  stim_halt = 0;
  stim_C = 3'b000;
  stim_F = 3'b001;
  stim_I = 10;
  stim_PC_in = 16'd10;
  stim_branch_type = 0;
  @(posedge clk);
  if(mon_PC_out != 16'd12)begin
    $display("Error: PC did not increment properly");
    $stop();
  end

  // test for PC branch immediate
  @(negedge clk);
  stim_branch_ins = 1;
  stim_C = 3'b111;
  stim_F = 3'b001;
  stim_I = -16'd2;
  stim_PC_in = 16'd10;
  stim_branch_type = 0;
  @(posedge clk);
  if(mon_PC_out != (16'd8))begin
    $display("Error: C branch immediate");
    $stop();
  end

  // test for PC branch register
  @(negedge clk);
  stim_reg2_data = 16'd1000;
  stim_C = 3'b111;
  stim_F = 3'b001;
  stim_PC_in = 16'd10;
  stim_branch_type = 1;
  @(posedge clk);
  if(mon_PC_out != (16'd1000))begin
    $display("Error: PC branch register");
    $stop();
  end

  // test for PC HALT
  @(negedge clk);
  stim_halt = 1;
  stim_PC_in = 16'd100;
  stim_branch_type = 1;
  @(posedge clk);
  if(mon_PC_out != (16'd100))begin
    $display("Error: HALT");
    $stop();
  end

  $display("all tests passed");
  $stop();
end

always #5 clk = ~clk;

endmodule
