//Property of Prof. J. Marpaung and Northeastern University
//Not to be distributed elsewhere without a written consent from Prof. J. Marpaung
//All Rights Reserved


`timescale 1ns/10ps
module cpu3_testbench();

reg [31:0] ibustm[0:30], ibus;
wire [31:0] abus;
wire [31:0] bbus;
wire [31:0] dbus;
reg clk;

reg [31:0] dontcare, abusin[0:30], bbusin[0:30], dbusout[0:30];
integer error, k, ntests;

parameter ADDI = 6'b000011;
parameter SUBI = 6'b000010;
parameter XORI = 6'b000001;
parameter ANDI = 6'b001111;
parameter ORI = 6'b001100;
parameter Rformat = 6'b000000;
parameter ADD = 6'b000011;
parameter SUB = 6'b000010;
parameter XOR = 6'b000001;
parameter AND = 6'b000111;
parameter OR = 6'b000100;


cpu3 dut(.ibus(ibus), .clk(clk), .abus(abus), .bbus(bbus), .dbus(dbus));


initial begin


// ---------- 
// 1.  XOR R1, R0, R0
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[0]={Rformat, 5'b00000, 5'b00000, 5'b00001, 5'b00000, XOR};
abusin[0]=32'h00000000;
bbusin[0]=32'h00000000;
dbusout[0]=32'h00000000;


// ----------
//  2. ORI R1, R0, #00FF
// ----------

//        opcode source1   dest      Immediate... 
ibustm[1]={ORI, 5'b00000, 5'b00001, 16'hFFFF};
abusin[1]=32'h00000000;
bbusin[1]=32'hFFFFFFFF;
dbusout[1]=32'hFFFFFFFF;



// ---------- 
// 3. Begin TEST # 0 ADDI R2, R0, #FFFF
// ----------

//        opcode source1   dest      Immediate... 
ibustm[2]={ADDI, 5'b00000, 5'b00010, 16'h00FF};
abusin[2]=32'h00000000;
bbusin[2]=32'h000000FF;
dbusout[2]=32'h000000FF;

// ---------- 
// 4. Begin TEST # 1  XORI R3, R1,#000F
// ----------

//        opcode source1   dest      Immediate... 
ibustm[3]={XORI, 5'b00001, 5'b00011, 16'h000F};
abusin[3]=32'hFFFFFFFF;
bbusin[3]=32'h0000000F;
dbusout[3]=32'hFFFFFFF0;


// ---------- 
// 5. Begin TEST # 2 AND R4, R1, R2
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[4]={Rformat, 5'b00001, 5'b00010, 5'b00100, 5'b00000, AND};
abusin[4]=32'hFFFFFFFF;
bbusin[4]=32'h000000FF;
dbusout[4]=32'h000000FF;

// ---------- 
// 6. Begin TEST # 3  ORI R2, R0, #FF00
// ----------

//        opcode source1   dest      Immediate... 
ibustm[5]={ORI, 5'b00000, 5'b00011, 16'hFF00};
abusin[5]=32'h00000000;
bbusin[5]=32'hFFFFFF00;
dbusout[5]=32'hFFFFFF00;


// ---------- 
// 7. Begin TEST # 4 ANDI R5, R1, #0001
// ----------

//        opcode source1   dest      Immediate... 
ibustm[6]={ANDI, 5'b00001, 5'b00101, 16'h0001};
abusin[6]=32'hFFFFFFFF;
bbusin[6]=32'h00000001;
dbusout[6]=32'h00000001;


// ---------- 
// 8. Begin TEST # 5 OR R6, R1, R3
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[7]={Rformat, 5'b00001, 5'b0001, 5'b00110, 5'b00000, OR};
abusin[7]=32'hFFFFFFFF;
bbusin[7]=32'hFFFFFFFF;
dbusout[7]=32'hFFFFFFFF;



// ---------- 
// 9. Begin TEST # 6 SUBI R7, R2, #0001
// ----------

//        opcode source1   dest      Immediate... 
ibustm[8]={SUBI, 5'b00010, 5'b00111, 16'h00001};
abusin[8]=32'h000000FF;
bbusin[8]=32'h000000001;
dbusout[8]=32'h000000FE;

// ---------- 
// 10. Begin TEST # 7 ADDI R8, R3, #00F0
// ----------

//        opcode source1   dest      Immediate... 
ibustm[9]={ADDI, 5'b00011, 5'b01000, 16'h00F0};
abusin[9]=32'hFFFFFF00;
bbusin[9]=32'h000000F0;
dbusout[9]=32'hFFFFFFF0;

// ------------ 
// 11. Begin TEST # 8 SUBI R9, R1, #F00F  
// ------------

//        opcode source1   dest      Immediate... 
ibustm[10]={SUBI, 5'b00001, 5'b01001, 16'hF00F};
abusin[10]=32'hFFFFFFFF;
bbusin[10]=32'hFFFFF00F;
dbusout[10]=32'h00000FF0;


// ------------ 
// 12. Begin TEST # 9  ORI R10, R3, #0000
// ------------

//         opcode source1   dest      Immediate... 
ibustm[11]={XORI, 5'b00011, 5'b01010, 16'h0000};
abusin[11]=32'hFFFFFF00;
bbusin[11]=32'h00000000;
dbusout[11]=32'hFFFFFF00;


// --------- 
// 13. Begin TEST # 10  SUB R11, R1, R5
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[12]={Rformat, 5'b00001, 5'b00101, 5'b01011, 5'b00000, SUB};
abusin[12]=32'hFFFFFFFF;
bbusin[12]=32'h00000001;
dbusout[12]=32'hFFFFFFFE;

// --------- 
// 14. Begin TEST # 11 OR R12, R7, R3
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[13]={Rformat, 5'b00011, 5'b00111, 5'b01011, 5'b00000, OR};
abusin[13]=32'hFFFFFF00;
bbusin[13]=32'h000000FE;
dbusout[13]=32'hFFFFFFFE;

// --------- 
// 15. Begin TEST # 12 XORI R8, R0, #0FF0
// ---------

//         opcode source1   dest      Immediate... 
ibustm[14]={XORI, 5'b00000, 5'b01000, 16'h0FF0};
abusin[14]=32'h00000000;
bbusin[14]=32'h00000FF0;
dbusout[14]=32'h00000FF0;

// --------- 
// 16. Begin TEST # 13 SUBI R31, R0, #011F 
// ---------

//         opcode source1   dest      Immediate... 
ibustm[15]={ADDI, 5'b00000, 5'b11111, 16'h011F};
abusin[15]=32'h00000000;
bbusin[15]=32'h0000011F;
dbusout[15]=32'h0000011F;



// --------- 
// 17. Begin TEST # 14 ADD R17, R3, R21
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[16]={Rformat, 5'b00011, 5'b10101, 5'b10001, 5'b00000, ADD};
abusin[16]=32'h00007334;
bbusin[16]=32'hFFFFF98B;
dbusout[16]=32'h00006CBF;



// 31*2
ntests = 34;

$timeformat(-9,1,"ns",12); 

end


initial begin
  error = 0;
  clk=0;
  for (k=0; k<= 18; k=k+1) begin
    
    //check input operands from 2nd previous instruction
    
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    if (k >= 3) begin
      $display ("  Testing input operands for instruction %d", k-3);
      $display ("    Your abus =    %b", abus);
      $display ("    Correct abus = %b", abusin[k-3]);
      $display ("    Your bbus =    %b", bbus);
      $display ("    Correct bbus = %b", bbusin[k-3]);
     
      if ((abusin[k-3] !== abus) ||(bbusin[k-3] !== bbus)) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    
    end

    clk=1;
    #25	
    
    //check output operand from 3rd previous instruction on bbus
    
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    if (k >= 3) begin
      $display ("  Testing output operand for instruction %d", k-3);
      $display ("    Your dbus =    %b", dbus);
      $display ("    Correct dbus = %b", dbusout[k-3]);
      
      if (dbusout[k-3] !== dbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
      
    end

    //put next instruction on ibus
    ibus=ibustm[k];
    $display ("  ibus=%b %b %b %b %b for instruction %d", ibus[31:26], ibus[25:21], ibus[20:16], ibus[15:11], ibus[10:0], k);
    clk = 0;
    #25
    error = error;
  
  end
 
  if ( error !== 0) begin 
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED----------");
    $display(" No. Of Errors = %d", error);
  end
  if ( error == 0) 
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");

end

endmodule