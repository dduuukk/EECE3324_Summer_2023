//Property of Prof. J. Marpaung and Northeastern University
//Not to be distributed elsewhere without a written consent from Prof. J. Marpaung
//All Rights Reserved


`timescale 1ns/10ps     // THIS DEFINES A UNIT TIME FOR THE TEST BENCH AND ITS PRECISION //
module alupipe_testbench();

reg [31:0] a, b;       // DECLARING I/O PORTS AND ALSO INTERNAL WIRES //
wire [31:0] d;
  reg [2:0] S, Stm[0:45];
reg Cin, clk;
  reg [31:0] dontcare, str[0:33], ref[0:45], stma[0:45], stmb[0:45];
  reg Vstr[0:45], Vref[0:45], Coutstr[0:45], Coutref[0:45], Cinstm[0:45];

integer ntests, error, k, i;  // VARIABLES NOT RELATED TO ALU I/O , BUT REQUIRED FOR TESTBENCH //

alupipe dut(.abus(a), .bbus(b), .dbus(d), .Cin(Cin), .S(S), .clk(clk));  // DECLARES THE MODULE BEING TESTED ALONG WITH ITS I/O PORTS //

   
   //////////////////////////////////////////  			     //////////////////////////////////////////
  ///////// EXPECTED VALUES ////////////////			    //////////    INPUTS TO ALU      /////////
 //////////////////////////////////////////		       //////////////////////////////////////////
 

initial begin     //LOADING THE TEST REGISTERS WITH INPUTS AND EXPECTED VALUES//

  ref[0] = 32'h00000000;  Vref[0] = 1'bx;  Coutref[0] = 1'bx;	 Stm[0] = 3'b000;  stma[0] = 32'h0000FFFF;  stmb[0] = 32'h0000FFFF;  Cinstm[0] = 0; // Test XOR //
  ref[1] = 32'hFFFFFFFF;  Vref[1] = 1'bx;  Coutref[1] = 1'bx;	 Stm[1] = 3'b000;  stma[1] = 32'h0000FFFF;  stmb[1] = 32'hFFFF0000;  Cinstm[1] = 0;
  ref[2] = 32'hD1B446A8;  Vref[2] = 1'bx;  Coutref[2] = 1'bx;	 Stm[2] = 3'b000;  stma[2] = 32'h793A7192;  stmb[2] = 32'hA88E373A;  Cinstm[2] = 0;
  
  ref[3] = 32'h00000000;  Vref[3] = 1'bx;  Coutref[3] = 1'bx;	 Stm[3] = 3'b001;  stma[3] = 32'h0000FFFF;  stmb[3] = 32'hFFFF0000;  Cinstm[3] = 0; // Test XNOR //
  ref[4] = 32'hFFFFFFFF;  Vref[4] = 1'bx;  Coutref[4] = 1'bx;	 Stm[4] = 3'b001;  stma[4] = 32'h0000FFFF;  stmb[4] = 32'h0000FFFF;  Cinstm[4] = 0;
  ref[5] = 32'h3FDEA4B0;  Vref[5] = 1'bx;  Coutref[5] = 1'bx;	 Stm[5] = 3'b001;  stma[5] = 32'hC910604F;  stmb[5] = 32'h09313B00;  Cinstm[5] = 0;
  
  ref[6] = 32'h64424220;  Vref[6] = 1'bx;  Coutref[6] = 1'bx;  Stm[6] = 3'b010;  stma[6] = 32'h31312020;  stmb[6] = 32'h33112200;  Cinstm[6] = 0; // Test ADD //
  ref[7] = 32'hF6F4F2EA;  Vref[7] = 1'bx;  Coutref[7] = 1'bx;	 Stm[7] = 3'b010;  stma[7] = 32'hC612EBEF;  stmb[7] = 32'h30E206FB;  Cinstm[7] = 0;
  ref[8] = 32'h255DB52A;  Vref[8] = 1'bx;  Coutref[8] = 1'bx;	 Stm[8] = 3'b010;  stma[8] = 32'hC612EBEF;  stmb[8] = 32'h5F4AC93B;  Cinstm[8] = 0;
  
  ref[9] = 32'h00000001;  Vref[9] = 1'bx;  Coutref[9] = 1'bx;	 Stm[9] = 3'b010;  stma[9] = 32'h00000000;  stmb[9] = 32'h00000000;  Cinstm[9] = 1; // Test Carry //
  ref[10] = 32'h0000000F; Vref[10] = 1'bx; Coutref[10] = 1'bx;	 Stm[10] = 3'b010; stma[10] = 32'h0000000F; stmb[10] = 32'h00000000; Cinstm[10] = 0;
  ref[11] = 32'h00000010; Vref[11] = 1'bx; Coutref[11] = 1'bx;	 Stm[11] = 3'b010; stma[11] = 32'h0000000F; stmb[11] = 32'h00000000; Cinstm[11] = 1;
  ref[12] = 32'h000000FF; Vref[12] = 1'bx; Coutref[12] = 1'bx;	 Stm[12] = 3'b010; stma[12] = 32'h000000FF; stmb[12] = 32'h00000000; Cinstm[12] = 0;
  ref[13] = 32'h00000100; Vref[13] = 1'bx; Coutref[13] = 1'bx;	 Stm[13] = 3'b010; stma[13] = 32'h000000FF; stmb[13] = 32'h00000000; Cinstm[13] = 1;
  ref[14] = 32'h00000FFF; Vref[14] = 1'bx; Coutref[14] = 1'bx;	 Stm[14] = 3'b010; stma[14] = 32'h00000FFF; stmb[14] = 32'h00000000; Cinstm[14] = 0;
  ref[15] = 32'h00001000; Vref[15] = 1'bx; Coutref[15] = 1'bx;	 Stm[15] = 3'b010; stma[15] = 32'h00000FFF; stmb[15] = 32'h00000000; Cinstm[15] = 1;
  ref[16] = 32'h0000FFFF; Vref[16] = 1'bx; Coutref[16] = 1'bx;	 Stm[16] = 3'b010; stma[16] = 32'h0000FFFF; stmb[16] = 32'h00000000; Cinstm[16] = 0;
  ref[17] = 32'h00010000; Vref[17] = 1'bx; Coutref[17] = 1'bx;	 Stm[17] = 3'b010; stma[17] = 32'h0000FFFF; stmb[17] = 32'h00000000; Cinstm[17] = 1;
  ref[18] = 32'h000FFFFF; Vref[18] = 1'bx; Coutref[18] = 1'bx;	 Stm[18] = 3'b010; stma[18] = 32'h000FFFFF; stmb[18] = 32'h00000000; Cinstm[18] = 0;
  ref[19] = 32'h00100000; Vref[19] = 1'bx; Coutref[19] = 1'bx;	 Stm[19] = 3'b010; stma[19] = 32'h000FFFFF; stmb[19] = 32'h00000000; Cinstm[19] = 1;
  ref[20] = 32'h00FFFFFF; Vref[20] = 1'bx; Coutref[20] = 1'bx;	 Stm[20] = 3'b010; stma[20] = 32'h00FFFFFF; stmb[20] = 32'h00000000; Cinstm[20] = 0;
  ref[21] = 32'h01000000; Vref[21] = 1'bx; Coutref[21] = 1'bx;	 Stm[21] = 3'b010; stma[21] = 32'h00FFFFFF; stmb[21] = 32'h00000000; Cinstm[21] = 1;
  ref[22] = 32'h0FFFFFFF; Vref[22] = 1'bx; Coutref[22] = 1'bx;	 Stm[22] = 3'b010; stma[22] = 32'h0FFFFFFF; stmb[22] = 32'h00000000; Cinstm[22] = 0;
  ref[23] = 32'h10000000; Vref[23] = 1'bx; Coutref[23] = 1'bx;	 Stm[23] = 3'b010; stma[23] = 32'h0FFFFFFF; stmb[23] = 32'h00000000; Cinstm[23] = 1;
  
  ref[24] = 32'h64424221; Vref[24] = 1'bx; Coutref[24] = 1'bx;   Stm[24] = 3'b011; stma[24] = 32'h31312020; stmb[24] = 32'hCCEEDDFF; Cinstm[24] = 1; // Test SUB //
  ref[25] = 32'h00010001; Vref[25] = 1'bx; Coutref[25] = 1'bx;   Stm[25] = 3'b011; stma[25] = 32'h00000001; stmb[25] = 32'hFFFF0000; Cinstm[25] = 1;
  ref[26] = 32'hFFFF0002; Vref[26] = 1'bx; Coutref[26] = 1'bx;   Stm[26] = 3'b011; stma[26] = 32'h00000001; stmb[26] = 32'h0000FFFF; Cinstm[26] = 1;
  
  ref[27] = 32'h00000000; Vref[27] = 1'bx; Coutref[27] = 1'bx;   Stm[27] = 3'b100; stma[27] = 32'h00000000; stmb[27] = 32'h00000000; Cinstm[27] = 0; // Test OR //
  ref[28] = 32'hFFFFFFFF; Vref[28] = 1'bx; Coutref[28] = 1'bx;	 Stm[28] = 3'b100; stma[28] = 32'h0000FFFF; stmb[28] = 32'hFFFF0000; Cinstm[28] = 0;
  ref[29] = 32'hF111EFE9; Vref[29] = 1'bx; Coutref[29] = 1'bx;	 Stm[29] = 3'b100; stma[29] = 32'hF111EFE9; stmb[29] = 32'hF111EFE9; Cinstm[29] = 0;
  
  ref[30] = 32'h00000000; Vref[30] = 1'bx; Coutref[30] = 1'bx;	 Stm[30] = 3'b101; stma[30] = 32'hFFFFFFFF; stmb[30] = 32'h0000FFFF; Cinstm[30] = 0; // Test NOR //
  ref[31] = 32'hFFFFFFFF; Vref[31] = 1'bx; Coutref[31] = 1'bx;	 Stm[31] = 3'b101; stma[31] = 32'h00000000; stmb[31] = 32'h00000000; Cinstm[31] = 0;
  ref[32] = 32'hFFFF0000; Vref[32] = 1'bx; Coutref[32] = 1'bx;	 Stm[32] = 3'b101; stma[32] = 32'h0000FFFF; stmb[32] = 32'h00000000; Cinstm[32] = 0;
  
  ref[33] = 32'h0000FFFF; Vref[33] = 1'bx; Coutref[33] = 1'bx;	 Stm[33] = 3'b110; stma[33] = 32'hFFFFFFFF; stmb[33] = 32'h0000FFFF; Cinstm[33] = 0; // Test AND //
  ref[34] = 32'h00000000; Vref[34] = 1'bx; Coutref[34] = 1'bx;	 Stm[34] = 3'b110; stma[34] = 32'h00000000; stmb[34] = 32'h00000000; Cinstm[34] = 0;
  ref[35] = 32'h44400161; Vref[35] = 1'bx; Coutref[35] = 1'bx;	 Stm[35] = 3'b110; stma[35] = 32'h575069F3; stmb[35] = 32'h446A9765; Cinstm[35] = 0;
  
  ref[36] = 32'hx;        Vref[36] = 0;    Coutref[36] = 0;		 Stm[36] = 3'b010; stma[36] = 32'h00000000; stmb[36] = 32'h00000000; Cinstm[36] = 0; // Test Cout, V // 
  ref[37] = 32'hx;        Vref[37] = 0;    Coutref[37] = 1;		 Stm[37] = 3'b010; stma[37] = 32'hFFFFFFFF; stmb[37] = 32'hFFFFFFFF; Cinstm[37] = 0;
  ref[38] = 32'hx;        Vref[38] = 1;    Coutref[38] = 1;		 Stm[38] = 3'b010; stma[38] = 32'h80000000; stmb[38] = 32'h80000000; Cinstm[38] = 0;
  ref[39] = 32'hx;        Vref[39] = 1;    Coutref[39] = 0;		 Stm[39] = 3'b010; stma[39] = 32'h40000000; stmb[39] = 32'h40000000; Cinstm[39] = 0;
  
  ref[40] = 32'hx;        Vref[40] = 1'bx; Coutref[40] = 1'bx;	 Stm[40] = 3'b111; stma[40] = 32'hFFFFFFFF; stmb[40] = 32'h0000FFFF; Cinstm[40] = 0; // Test Don't Care //
  ref[41] = 32'hx;        Vref[41] = 1'bx; Coutref[41] = 1'bx;	 Stm[41] = 3'b111; stma[41] = 32'h00000000; stmb[41] = 32'h00000000; Cinstm[41] = 0;
  ref[42] = 32'hx;        Vref[42] = 1'bx; Coutref[42] = 1'bx;	 Stm[42] = 3'b111; stma[42] = 32'h50C0CA4E; stmb[42] = 32'hF795B1D8; Cinstm[42] = 0;
  ref[43] = 32'hx;        Vref[43] = 1'bx; Coutref[43] =1'bx;	 Stm[43] = 3'hx; stma[43] = 32'hx; 			stmb[43] = 32'hx; 		 Cinstm[43] =1'bx;
  ref[44] = 32'hx;        Vref[44] = 1'bx; Coutref[44] =1'bx;	 Stm[44] = 3'hx; stma[44] = 32'hx; 			stmb[44] = 32'hx; 		 Cinstm[44] =1'bx;
  
  dontcare = 32'hx;
  ntests = 44;
 
  $timeformat(-9,1,"ns",12);
 
end

//assumes positive edge FF.
//Change inputs in middle of period (falling edge).
initial begin
 error = 0;
    
 for (k=0; k<= ntests+1; k=k+1)   		     // LOOPING THROUGH ALL THE TEST VECTORS AND ASSIGNING IT TO THE ALU INPUTS EVERY 25ns //
    begin
    clk=1;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #12.5
    clk=0;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    a = stma[k] ; b = stmb[k];
    if (k >= 1) begin
      S = Stm[k-1]; Cin = Cinstm[k-1];
    end
    
    if (k >=2) begin
      if ( Stm[k-2] == 3'b000 )
      $display ("-----  TEST FOR A XOR B  -----");
    
      if ( Stm[k-2] == 3'b001 )
      $display ("-----  TEST FOR A XNOR B  -----");
  
      if ( Stm[k-2] == 3'b010 )
      $display ("-----  TEST FOR A + B/ CARRY CHAIN  -----");
    
      if ( Stm[k-2] == 3'b011 )
      $display ("-----  TEST FOR A - B  -----");
  
      if ( Stm[k-2] == 3'b100 )
      $display ("-----  TEST FOR A OR B  -----");
  
      if ( Stm[k-2] == 3'b101 )
      $display ("-----  TEST FOR A NOR B  -----");

      if ( Stm[k-2] == 3'b110 )
      $display ("-----  TEST FOR A AND B  -----");


      $display ("Time=%t \n S=%b \n Cin=%b \n a=%b \n b=%b \n d=%b \n ref=%b \n",$realtime, Stm[k-2], Cinstm[k-2], stma[k-2], stmb[k-2], d, ref[k-2]);
    
    
      // THIS CONTROL BLOCK CHECKS FOR ERRORS  BY COMPARING YOUR OUTPUT WITH THE EXPECTED OUTPUTS AND INCREMENTS "error" IN CASE OF ERROR //
    
      if (( (ref[k-2] !== d) && (ref[k-2] !== dontcare)  ) )
        begin
        $display ("-------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end

    end
    #12.5 ;
 end

    if ( error == 0)
        $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");
    
    if ( error != 0)
        $display("---------------ERRORS. Mismatches Have Occured------------------");

end
         
        
endmodule
         


