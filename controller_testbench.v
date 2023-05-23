//Property of Prof. J. Marpaung and Northeastern University
//Not to be distributed elsewhere without a written consent from Prof. J. Marpaung
//All Rights Reserved


`timescale 1ns/10ps
module controller_testbench();

reg [31:0] ibustm[0:31], ibus, Ref_Aselect[0:31], Ref_Bselect[0:31],Ref_Dselect[0:31];
reg clk, Ref_Imm[0:31], Ref_Cin[0:31];
reg [2:0] Ref_S[0:31];
wire [2:0] S;
wire Cin,Imm;
wire [31:0] Aselect,Bselect, Dselect;
 
reg [31:0] dontcare;
reg neglect;
reg [2:0] neg;
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
parameter SADD = 3'b010;
parameter SSUB = 3'b011;
parameter SXOR = 3'b000;
parameter SAND = 3'b110;
parameter SOR = 3'b100;


controller dut(.ibus(ibus), .clk(clk), .Cin(Cin), .Imm(Imm), .S(S) , .Aselect(Aselect) , .Bselect(Bselect), .Dselect(Dselect));


initial begin
dontcare = 32'hxxxxxxxx;
neglect = 1'bx;
neg = 3'bxxx;



// ----------
// 1. Begin test clear XOR R1, R0, R0
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[0]={Rformat, 5'b00000, 5'b00000, 5'b00001, 5'b00000, XOR};
ibustm[1]={Rformat, 5'b00000, 5'b00000, 5'b00001, 5'b00000, XOR};

Ref_Aselect[1] = 32'b00000000000000000000000000000001; //input 1
Ref_Bselect[1] = 32'b00000000000000000000000000000001; //input 1
Ref_Dselect[1] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
Ref_Imm[1] =1'bx;
Ref_Cin[1] =1'bx;
Ref_S[1] = 3'bxxx;

// ----------
//  2. ADDI R2, R0, #000F
// ----------

//        opcode source1   dest      Immediate...
ibustm[2]={ADDI, 5'b00000, 5'b00010, 16'h000F};

Ref_Aselect[2] = 32'b00000000000000000000000000000001; //input2 
Ref_Bselect[2] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input2 
Ref_Dselect[2] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input0 
Ref_Imm[2] =1'b0;  //input1
Ref_Cin[2] =1'b0;  //input1
Ref_S[2] = SXOR; //input1



// ---------- 
// 3. ANDI R3, R0, 16'h000FF
// ----------
//        opcode source1   dest      Immediate...
ibustm[3]= {ANDI, 5'b00000, 5'b00011, 16'h000FF};

Ref_Aselect[3] = 32'b0000000000000000000000000000000; //input3
Ref_Bselect[3] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input3
Ref_Dselect[3] = 32'b0000000000000000000000000000010; //input1
Ref_Imm[3] =1'b1;  //input2
Ref_Cin[3] =1'b0;  //input2 
Ref_S[3] = SADD; //input2

// ---------- 
// 4. SUB R4, R1, R2
// ----------

ibustm[4]={Rformat, 5'b00001, 5'b00000, 5'b00100, 5'b00000, SUB};

Ref_Aselect[4] = 32'b00000000000000000000000000000010; //input4
Ref_Bselect[4] = 32'b00000000000000000000000000000001; //input4
Ref_Dselect[4] = 32'b00000000000000000000000000000100; //input2
Ref_Imm[4] =1'b1;  //input3
Ref_Cin[4] =1'b0;  //input3
Ref_S[4] = SAND; //input3


// ---------- 
// 5. AND R5, R1, R2
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[5]={Rformat, 5'b00001, 5'b00010, 5'b00101, 5'b00000, AND};

Ref_Aselect[5] = 32'b0000000000000000000000000000010; //input5
Ref_Bselect[5] = 32'b0000000000000000000000000000100; //input5
Ref_Dselect[5] = 32'b0000000000000000000000000001000; //input3
Ref_Imm[5] =1'b0;  //input4
Ref_Cin[5] =1'b1;  //input4
Ref_S[5] = SSUB; //input4

// ---------- // 6. XORI R6, R0, #FF00
// ----------

//        opcode source1   dest      Immediate...
ibustm[6]={XORI, 5'b00000, 5'b00110, 16'hFF00};

Ref_Aselect[6] = 32'b00000000000000000000000000000001; //input6
Ref_Bselect[6] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input6
Ref_Dselect[6] = 32'b0000000000000000000000000010000; //input4
Ref_Imm[6] =1'b0;  //input5
Ref_Cin[6] =1'b0;  //input5
Ref_S[6] = SAND; //input5


// ---------- 
// 7. ORI R7, R1, #0FF0
// ----------

//        opcode source1   dest      Immediate...
ibustm[7]={ANDI, 5'b00001, 5'b00111, 16'h0FF0};

Ref_Aselect[7] = 32'b00000000000000000000000000000010;//input7
Ref_Bselect[7] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input7
Ref_Dselect[7] = 32'b0000000000000000000000000100000; //input5
Ref_Imm[7] =1'b1; //input6
Ref_Cin[7] =1'b0; //input6
Ref_S[7] = SXOR; //input6


// ---------- 
// 8. OR R1, R3, R2
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[8]={Rformat, 5'b00011, 5'b00010, 5'b00001, 5'b00000, OR};

Ref_Aselect[8] = 32'b00000000000000000000000000001000; //input8
Ref_Bselect[8] = 32'b00000000000000000000000000000100; //input8
Ref_Dselect[8] = 32'b0000000000000000000000001000000; //input6
Ref_Imm[8] =1'b1;  //input7
Ref_Cin[8] =1'b0;  //input7
Ref_S[8] = SAND; //input7


// ---------- 
// 9. SUBI R8, R3, #0001
// ----------

//        opcode source1   dest      Immediate...
ibustm[9]={SUBI, 5'b00011, 5'b01000, 16'h0001};

Ref_Aselect[9] = 32'b00000000000000000000000000001000;//input9
Ref_Bselect[9] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input9
Ref_Dselect[9] = 32'b0000000000000000000000010000000;//input7
Ref_Imm[9] =1'b0;  //input8
Ref_Cin[9] =1'b0;  //input8
Ref_S[9] = SOR; //input8


// ---------- 
// 10. XOR R9, R5, R2
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[10]={Rformat, 5'b00101, 5'b00010, 5'b01001, 5'b00000, XOR};

Ref_Aselect[10] = 32'b00000000000000000000000000100000; //input10
Ref_Bselect[10] = 32'b00000000000000000000000000000100; //input10
Ref_Dselect[10] = 32'b00000000000000000000000000000010; //input8
Ref_Imm[10] =1'b1; //input9
Ref_Cin[10] =1'b1; //input9
Ref_S[10] = SSUB; //input9


// ------------ 
// 11. XORI R10, R3, #FFFF  
// ------------

//        opcode source1   dest      Immediate...
ibustm[11]={ORI, 5'b00011, 5'b01010, 16'hFFFF};
Ref_Aselect[11] = 32'b00000000000000000000000000001000;//input11
Ref_Bselect[11] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input11
Ref_Dselect[11] = 32'b0000000000000000000000100000000;//input9
Ref_Imm[11] =1'b0;  //input10
Ref_Cin[11] =1'b0;  //input10
Ref_S[11] = SXOR; //input10

// ------------ 
// 12. XORI R11, R3, #FFFF
// ------------

//         opcode source1   dest      Immediate...
ibustm[12]={ANDI, 5'b00011, 5'b01011, 16'hFFFF};

Ref_Aselect[12] = 32'b00000000000000000000000000001000; //input12
Ref_Bselect[12] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input12
Ref_Dselect[12] = 32'b0000000000000000000001000000000; //input10
Ref_Imm[12] =1'b1;  //input11
Ref_Cin[12] =1'b0;  //input11
Ref_S[12] = SOR; //input11


// --------- 
// 13. OR R12, R5, R6
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[13]={Rformat, 5'b00101, 5'b00110, 5'b01100, 5'b00000, OR};

Ref_Aselect[13] = 32'b00000000000000000000000000100000;//input13
Ref_Bselect[13] = 32'b00000000000000000000000001000000;//input13
Ref_Dselect[13] = 32'b0000000000000000000010000000000;//input11
Ref_Imm[13] =1'b1;  //input12
Ref_Cin[13] =1'b0;  //input12
Ref_S[13] = SAND; //input12


// --------- 
// 14. SUB R13, R3, R0
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[14]={Rformat, 5'b00011, 5'b00000, 5'b01101, 5'b00000, SUB};

Ref_Aselect[14] = 32'b00000000000000000000000000001000; //input14
Ref_Bselect[14] = 32'b00000000000000000000000000000001; //input14
Ref_Dselect[14] = 32'b0000000000000000000100000000000; //input12
Ref_Imm[14] =1'b0;  //input13
Ref_Cin[14] =1'b0;  //input13
Ref_S[14] = SOR; //input13


// --------- 
// 15. ANDI R14, R4, #0FF0
// ---------

//         opcode source1   dest      Immediate...
ibustm[15]={ANDI, 5'b00100, 5'b01110, 16'h0FF0};

Ref_Aselect[15] = 32'b00000000000000000000000000010000;//input15
Ref_Bselect[15] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input15
Ref_Dselect[15] = 32'b0000000000000000001000000000000;//input13
Ref_Imm[15] =1'b0;  //input14
Ref_Cin[15] =1'b1;  //input14
Ref_S[15] = SSUB; //input14

// --------- 
// 16. XORI R16, R11, #0001  
// ---------

//         opcode source1   dest      Immediate...
ibustm[16]={XORI, 5'b01011, 5'b10000, 16'h0001};

Ref_Aselect[16] = 32'b00000000000000000000100000000000; //input16
Ref_Bselect[16] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input16
Ref_Dselect[16] = 32'b0000000000000000010000000000000; //input14
Ref_Imm[16] =1'b1;  //input15
Ref_Cin[16] =1'b0;  //input15
Ref_S[16] = SAND; //input15


ntests = 16;

$timeformat(-9,1,"ns",12); 

end


initial begin
  error = 0;
  clk=0;
  $display("-------------------------------");
  $display("Time=%t   Instruction Number: 0 ",$realtime);
  $display("-------------------------------");
  ibus = ibustm[0];
  #25;
 
  for (k=1; k<= 16; k=k+1) begin
  $display("-------------------------------");
  $display("Time=%t   Instruction Number: %d ",$realtime,k);
 $display("-------------------------------");
    clk=1;
    #5
    
    if (k>=1) begin
    
      $display ("  Testing Immediate, Cin and S for instruction %d", k-1);
      $display ("    Your Imm     = %b", Imm);
      $display ("    Correct Imm  = %b", Ref_Imm[k]);
      
      if ( (Imm !== Ref_Imm[k]) && (Ref_Imm[k] !== 1'bx) ) begin
         error = error+1;
         $display("-------ERROR. Mismatch Has Occured--------");
      end
    
      $display ("    Your Cin     = %b", Cin);
      $display ("    Correct Cin  = %b", Ref_Cin[k]);
      
      if ( (Cin !== Ref_Cin[k]) && (Ref_Cin[k] !== 1'bx) ) begin
          error = error+1;
          $display("-------ERROR. Mismatch Has Occured--------");
      end
      
      $display ("    Your S     = %b", S);
      $display ("    Correct S  = %b", Ref_S[k]);
    
      if ( (S !== Ref_S[k]) && (Ref_S[k] !== 3'bxxx) ) begin
         error = error+1;
         $display("-------ERROR. Mismatch Has Occured--------");
      end
    
    end
     
    if (k>=2) begin
      $display ("  Testing Destination Registers for instruction %d", k-2);
      $display ("    Your Dselect     = %b", Dselect);
      $display ("    Correct Dselect  = %b", Ref_Dselect[k]);
      
      if ( (Dselect !== Ref_Dselect[k]) && (Ref_Dselect[k] !== dontcare) ) begin
         error = error+1;
 $display("-------ERROR. Mismatch Has Occured--------");
      end
    end
               
    #20	
    clk = 0;
    $display ("-------------------------------");
    $display ("          Time=%t              ",$realtime);
    $display ("-------------------------------");
    ibus = ibustm[k+1];
    
    #5
    
    $display ("  Testing Source Registers for instruction %d", k);
    $display ("    Your Aselect     = %b", Aselect);
    $display ("    Correct Aselect  = %b", Ref_Aselect[k]);

    if ( (Aselect !== Ref_Aselect[k]) && (Ref_Aselect[k]) ) begin
        error = error+1;
        $display("-------------ERROR. Mismatch Has Occured---------------");
    end 
      
    $display ("    Your Bselect     = %b", Bselect);
    $display ("    Correct Bselect  = %b", Ref_Bselect[k]);
        
    if ( (Bselect !== Ref_Bselect[k]) && (Ref_Bselect[k] !== dontcare) ) begin
       error = error+1;
       $display("-------------ERROR. Mismatch Has Occured---------------");
    end
    
    #20
    clk = 0;
  end
 
  if ( error !== 0) begin 
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
    $display(" No. Of Errors = %d", error);
  end

  if ( error == 0) 
 $display("-----------YOU DID IT :-) !!! SIMULATION SUCCESFULLY FINISHED----------");

end
      
endmodule