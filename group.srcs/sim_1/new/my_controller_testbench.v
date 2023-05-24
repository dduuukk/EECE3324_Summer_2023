//Property of Prof. J. Marpaung and Northeastern University
//Not to be distributed elsewhere without a written consent from Prof. J. Marpaung
//All Rights Reserved


`timescale 1ns/10ps
module my_controller_testbench();

reg [31:0] ibustm[0:32], ibus, Ref_Aselect[0:32], Ref_Bselect[0:32],Ref_Dselect[0:32];
reg clk, Ref_Imm[0:32], Ref_Cin[0:32];
reg [2:0] Ref_S[0:32];
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


// ---------- 
// 6. XORI R6, R0, #FF00
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
ibustm[11]={XORI, 5'b00011, 5'b01010, 16'hFFFF};
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
Ref_S[12] = SXOR; //input11


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

  // ----------
  //  17. SUBI R1, R0, #00C8
  // ----------
  //        opcode source1   dest      Immediate...
  ibustm[17]={SUBI, 5'b00000, 5'b00001, 16'h00C8};

  Ref_Aselect[17] = 32'b00000000000000000000000000000001; //input17 (R0)
  Ref_Bselect[17] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input17 (IMM)
  Ref_Dselect[17] = 32'b00000000000000000100000000000000; //input15 (R14)
  Ref_Imm[17] =1'b1;  //input16 
  Ref_Cin[17] =1'b0;  //input16 
  Ref_S[17] = SXOR; //input16 


  // ---------- 
  // 18. ADDI R10, R5, #FF38
  // ----------
  //        opcode source1   dest      Immediate...
  ibustm[18]={ADDI, 5'b00101, 5'b01010, 16'hFF38};

  Ref_Aselect[18] = 32'b0000000000000000000000000100000; //input18 (R5)
  Ref_Bselect[18] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input18 (IMM)
  Ref_Dselect[18] = 32'b0000000000000010000000000000000; //input16 (R16)
  Ref_Imm[18] =1'b1;  //input17 
  Ref_Cin[18] =1'b1;  //input17 
  Ref_S[18] = SSUB; //input17 

  
  // ---------- 
  // 19. SUBI R15, R1, #1388
  // ----------
  //        opcode source1   dest      Immediate...
  ibustm[19]={SUBI, 5'b00001, 5'b01111, 16'h1388};

  Ref_Aselect[19] = 32'b00000000000000000000000000000010; //input19 (R1)
  Ref_Bselect[19] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input19 (IMM)
  Ref_Dselect[19] = 32'b00000000000000000000000000000010; //input17 (R1)
  Ref_Imm[19] =1'b1;  //input18 
  Ref_Cin[19] =1'b0;  //input18 
  Ref_S[19] = SADD; //input18 


  // ---------- 
  // 20. XOR R0, R1, R5
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[20]={Rformat, 5'b00001, 5'b00101, 5'b00000, 5'b00000, XOR};

  Ref_Aselect[20] = 32'b0000000000000000000000000000010; //input20 (R1)
  Ref_Bselect[20] = 32'b0000000000000000000000000100000; //input20 (R5)
  Ref_Dselect[20] = 32'b0000000000000000000010000000000; //input18 (R10)
  Ref_Imm[20] =1'b1;  //input19 
  Ref_Cin[20] =1'b1;  //input19 
  Ref_S[20] = SSUB; //input19 


  // ---------- 
  // 21. ANDI R7, R10, #80FFF
  // ----------
  //        opcode source1   dest      Immediate...
  ibustm[21]={ANDI, 5'b01010, 5'b00111, 16'h0FFF};

  Ref_Aselect[21] = 32'b00000000000000000000010000000000; //input21 (R10)
  Ref_Bselect[21] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input21 (IMM)
  Ref_Dselect[21] = 32'b00000000000000001000000000000000; //input19 (R15) 
  Ref_Imm[21] =1'b0;  //input20 
  Ref_Cin[21] =1'b0;  //input20
  Ref_S[21] = SXOR; //input20 


  // ---------- 
  // 22. ORI R27, R15, #F777 
  // ----------
  //        opcode source1   dest      Immediate...
  ibustm[22]={ORI, 5'b01111, 5'b11011, 16'hF777}; 

  Ref_Aselect[22] = 32'b00000000000000001000000000000000;//input22 (R15)
  Ref_Bselect[22] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input22 (IMM)
  Ref_Dselect[22] = 32'b00000000000000000000000000000001; //input20 (R0)
  Ref_Imm[22] =1'b1; //input21 
  Ref_Cin[22] =1'b0; //input21 
  Ref_S[22] = SAND; //input21 


  // ---------- 
  // 23. ADD R19, R1, R0
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[23]={Rformat, 5'b00001, 5'b00000, 5'b10011, 5'b00000, ADD};

  Ref_Aselect[23] = 32'b00000000000000000000000000000010; //input23 (R1)
  Ref_Bselect[23] = 32'b00000000000000000000000000000001; //input23 (R0)
  Ref_Dselect[23] = 32'b00000000000000000000000010000000; //input21 (R7)
  Ref_Imm[23] =1'b1;  //input22 
  Ref_Cin[23] =1'b0;  //input22 
  Ref_S[23] = SOR; //input22 


  // ---------- 
  // 24. ORI R31, R27, #1914
  // ----------
  //        opcode source1   dest      Immediate...
  ibustm[24]={ORI, 5'b11011, 5'b11111, 16'h1914}; 

  Ref_Aselect[24] = 32'b00001000000000000000000000000000;//input24 (R27)
  Ref_Bselect[24] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input24 (IMM)
  Ref_Dselect[24] = 32'b00001000000000000000000000000000;//input22 (R27)
  Ref_Imm[24] =1'b0;  //input23 
  Ref_Cin[24] =1'b0;  //input23 
  Ref_S[24] = SADD; //input23 


// ---------- 
// 25. AND R6, R27, R19
// ----------
//         opcode   source1   source2   dest      shift     Function...
  ibustm[25]={Rformat, 5'b11011, 5'b10011, 5'b00110, 5'b00000, AND};

  Ref_Aselect[25] = 32'b00001000000000000000000000000000; //input25 (R27)
  Ref_Bselect[25] = 32'b00000000000010000000000000000000; //input25 (R19)
  Ref_Dselect[25] = 32'b00000000000010000000000000000000; //input23 (R19)
  Ref_Imm[25] =1'b1; //input24 
  Ref_Cin[25] =1'b0; //input24 
  Ref_S[25] = SOR; //input24 
  
// ---------- 
// 26. ADDI R29, R31, #1B39
// ----------
//        opcode source1   dest      Immediate...
ibustm[26]={ADDI, 5'b11111, 5'b11101, 16'h1B39}; // 

Ref_Aselect[26] = 32'b10000000000000000000000000000000;//input26 (R31)
Ref_Bselect[26] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input26 (IMM)
Ref_Dselect[26] = 32'b10000000000000000000000000000000;//input24 (R31)
Ref_Imm[26] =1'b0;  //input25
Ref_Cin[26] =1'b0;  //input25
Ref_S[26] = SAND; //input25

  // ---------- 
  // 27. ADD R22, R6, R19
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[27]={Rformat, 5'b00110, 5'b10011, 5'b10110, 5'b00000, ADD};

  Ref_Aselect[27] = 32'b00000000000000000000000001000000; //input27 (R6)
  Ref_Bselect[27] = 32'b00000000000010000000000000000000; //input27 (R19)
  Ref_Dselect[27] = 32'b00000000000000000000000001000000; //input25 (R6)
  Ref_Imm[27] =1'b1;  //input26 
  Ref_Cin[27] =1'b0;  //input26 
  Ref_S[27] = SADD; //input26 
  
  // ---------- 
  // 28. SUB R24, R1, R14
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[28]={Rformat, 5'b00001, 5'b01110, 5'b11000, 5'b00000, SUB};

  Ref_Aselect[28] = 32'b00000000000000000000000000000010; //input28 (R1)
  Ref_Bselect[28] = 32'b00000000000000000100000000000000; //input28 (R14)
  Ref_Dselect[28] = 32'b00100000000000000000000000000000; //input26 (R29)
  Ref_Imm[28] =1'b0;  //input27 
  Ref_Cin[28] =1'b0;  //input27 
  Ref_S[28] = SADD; //input27 
  
  // ---------- 
  // 29. AND R17, R6, R5
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[29]={Rformat, 5'b00110, 5'b00101, 5'b10001, 5'b00000, AND};

  Ref_Aselect[29] = 32'b00000000000000000000000001000000; //input29 (R6)
  Ref_Bselect[29] = 32'b00000000000000000000000000100000; //input29 (R5)
  Ref_Dselect[29] = 32'b00000000010000000000000000000000; //input27 (R22)
  Ref_Imm[29] =1'b0;  //input28 
  Ref_Cin[29] =1'b1;  //input28 
  Ref_S[29] = SSUB; //input28 
  
  // ---------- 
  // 30. OR R3, R19, R27
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[30]={Rformat, 5'b10011, 5'b11011, 5'b00011, 5'b00000, OR};

  Ref_Aselect[30] = 32'b00000000000010000000000000000000; //input30 (R19)
  Ref_Bselect[30] = 32'b00001000000000000000000000000000; //input30 (R27)
  Ref_Dselect[30] = 32'b00000001000000000000000000000000; //input28 (R24)
  Ref_Imm[30] =1'b0;  //input29 
  Ref_Cin[30] =1'b0;  //input29 
  Ref_S[30] = SAND; //input29 
  
  // ---------- 
  // 31. ADD R1, R7, R9
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[31]={Rformat, 5'b00111, 5'b01001, 5'b00001, 5'b00000, OR};

  Ref_Aselect[31] = 32'b00000000000000000000000010000000; //input31 (R7)
  Ref_Bselect[31] = 32'b00000000000000000000001000000000; //input31 (R9)
  Ref_Dselect[31] = 32'b00000000000000100000000000000000; //input29 (R17)
  Ref_Imm[31] =1'b0;  //input30 
  Ref_Cin[31] =1'b0;  //input30 
  Ref_S[31] = SOR; //input30 

  // ---------- 
  // 31. XOR R5, R6, R10
  // ----------
  //         opcode   source1   source2   dest      shift     Function...
  ibustm[32]={Rformat, 5'b00101, 5'b00110, 5'b01010, 5'b00000, XOR};

  Ref_Aselect[32] = 32'b00000000000000000000000000100000; //input32 (R7)
  Ref_Bselect[32] = 32'b00000000000000000000000001000000; //input32 (R9)
  Ref_Dselect[32] = 32'b00000000000000000000000000001000; //input30 (R17)
  Ref_Imm[32] =1'b0;  //input31 
  Ref_Cin[32] =1'b0;  //input31 
  Ref_S[32] = SOR; //input31 
ntests = 32;

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
 
  for (k=1; k<= 32; k=k+1) begin
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