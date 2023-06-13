`timescale 1ns / 1ps


module cpu5arm(
    input [31:0] ibus,
    input clk,
    input reset,
    output [63:0] iaddrbus,
    inout [63:0] databus,
    output [63:0] daddrbus
    );
    
    wire [31:0] REGAselect, REGBselect, REGDselect, IMMVALtoMUX, nextInst, multResult;
    wire [2:0] SELtoALU;
    wire CINtoALU, IMMtoMUX, LWF, SWF, SLT, SLE;
    wire [31:0] nextInstStep, nextInstJump;
    wire branchTrue;
    wire[31:0] instJumpStart;
    
    
    
    mux2to1 instMux(
        .a(nextInstJump),
        .b(nextInstStep),
        .out(nextInst),
        .select(branchTrue)
    );
    
    reg32reset PC(
        .d(nextInst),
        .q(iaddrbus),
        .reset(reset),
        .clk(clk)    
    );
    
    adder plusFour(
        .A(iaddrbus),
        .B(32'h00000004),
        .out(nextInstStep)
    );  
    
    reg32 IFIDInstruction(
        .d(nextInstStep),
        .q(instJumpStart),
        .clk(clk)    
    );
    
    adder branchAdd(
        .A(multResult),
        .B(instJumpStart),
        .out(nextInstJump)
    );
    
    controller Controller(
        .ibus(ibus),
        .clk(clk),
        .Aselect(REGAselect),
        .Bselect(REGBselect),
        .Dselect(REGDselect),
        .immValue(IMMVALtoMUX),
        .Cin(CINtoALU),
        .S(SELtoALU),
        .Imm(IMMtoMUX),
        .LWFlag(LWF),
        .SWFlag(SWF),
        .BEQFlag(BEQFlag),
        .BNEFlag(BNEFlag),
        .SLTFlag(SLT),
        .SLEFlag(SLE),
        .multResult(multResult)
    );
    
    regalu Regalu(
        .Aselect(REGAselect),
        .Bselect(REGBselect),
        .Dselect(REGDselect),
        .ImmVal(IMMVALtoMUX),
        .Imm(IMMtoMUX),
        .clk(clk),
        .abus(),
        .bbus(),
        .dbus(),
        .S(SELtoALU),
        .Cin(CINtoALU),
        .LWFlag(LWF),
        .SWFlag(SWF),
        .BEQFlag(BEQFlag),
        .BNEFlag(BNEFlag),
        .branchTrue(branchTrue),
        .SLTFlag(SLT),
        .SLEFlag(SLE),
        .databus(databus),
        .daddrbus(daddrbus)
    );

endmodule

module adder (
    input [31:0] A, 
    input [31:0] B,
    output reg [31:0] out
    );
    always @(A, B, out)
        out = A + B;
endmodule

module multiplier (
    input [31:0] A, 
    input [31:0] B,
    output reg [31:0] out
    );
    always @(A, B, out)
        out = A * B;
endmodule

module controller(
    input [31:0] ibus,
    input clk,
    output [31:0] Aselect,
    output [31:0] Bselect,
    output [31:0] Dselect,
    output [31:0] immValue, multResult,
    output Cin,
    output [2:0] S,
    output Imm,
    output LWFlag, SWFlag,
    output BEQFlag, BNEFlag,
    output SLTFlag, SLEFlag 
    );
    
    wire [31:0] iregtodecoders, rdtomux, MUXtoIDEX, IDEXtoEXMEM,IMMtoIDEX, DSELtoMEMWB, MUXtoDWB;
    wire decodeImm, decodeCin;
    wire [2:0] decodeS;
    
    
    reg32 IFID(.d(ibus), .q(iregtodecoders), .clk(clk));
    
    
    multiplier multfour(
        .A(IMMtoIDEX),
        .B(32'h00000004),
        .out(multResult)
    );
    
    
    
    decode5to32 rnDecode(
        .code(iregtodecoders[9:5]),
        .out(Aselect)    
    );
    decode5to32 rmDecode(
        .code(iregtodecoders[19:16]),
        .out(Bselect)    
    );
    decode5to32 rdDecode(
        .code(iregtodecoders[4:0]),
        .out(rdtomux)    
    );
    decodeopcode opdecode(
        .code(iregtodecoders[31:21]),
        .funct(iregtodecoders[5:0]),
        .Imm(decodeImm),
        .S(decodeS),
        .Cin(decodeCin),
        .LWFlag(LWFlag),
        .SWFlag(SWFlag),
        .BEQFlag(BEQFlag),
        .BNEFlag(BNEFlag),
        .SLTFlag(SLTFlag),
        .SLEFlag(SLEFlag)
        
    );
    signextend SignExtend(
        .in(iregtodecoders[15:0]),
        .extend(IMMtoIDEX)
    );
    
    mux2to1 decodeMux(
        .a(Bselect),
        .b(rdtomux),
        .out(MUXtoDWB),
        .select(decodeImm)
    );
    mux2to1 SWdisableWrite(
        .a(32'h00000001),
        .b(MUXtoDWB),
        .out(MUXtoIDEX),
        .select(SWFlag | BNEFlag | BEQFlag)
    );
    
    reg32 IDEXD(.d(MUXtoIDEX), .q(IDEXtoEXMEM), .clk(clk));
    reg32 IDEXDImm(.d(IMMtoIDEX), .q(immValue), .clk(clk));
    reg1 IDEXImm(.d(decodeImm), .q(Imm), .clk(clk));
    reg3 IDEXS(.d(decodeS), .q(S), .clk(clk));
    reg1 IDEXCin(.d(decodeCin), .q(Cin), .clk(clk));
    
    reg32 EXMEMD(.d(IDEXtoEXMEM), .q(DSELtoMEMWB), .clk(clk));
    reg32 MEMWBD(.d(DSELtoMEMWB), .q(Dselect), .clk(clk));

endmodule

module reg32(
    input [31:0] d,
    output reg [31:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule

module reg32reset(
    input [31:0] d,
    input reset,
    output reg [31:0] q,
    input clk      
    );
    always@(posedge clk)
        if(reset)
            q = 32'h00000000;
        else
            q = d;
endmodule

module decode5to32(
    input [4:0] code,
    output reg [31:0] out
    );
    
    always @(code, out) begin
        out = 32'b1 << code;
        end
endmodule

module decodeopcode(
    input [10:0] code,
    input [5:0] funct,
    output reg Imm,
    output reg [2:0] S,
    output reg Cin,
    output reg SWFlag, LWFlag,
    output reg BEQFlag, BNEFlag,
    output reg SLTFlag, SLEFlag 
    );
    always @(code, funct, S, Imm, Cin) begin
        Cin = 1'b0;
        Imm = 1'b1;
        SWFlag = 1'b0;
        LWFlag = 1'b0;
        BEQFlag = 1'b0;
        BNEFlag = 1'b0;
        SLTFlag = 1'b0;
        SLEFlag = 1'b0;
        case(code[10:5]) 
            6'b001010:
            //R-Format
            begin
                case(code[4:0]) 
                    5'b00000:
                    //ADD
                    begin
                        S = 3'b010;                
                    end 
                    5'b00001:
                    //ADDS
                    begin
                        S = 3'b010;                
                    end 
                    5'b00010:
                    //AND
                    begin
                        S = 3'b010;                
                    end   
                    5'b00011:
                    //ANDS
                    begin
                        S = 3'b010;                
                    end 
                    5'b00100:
                    //EOR
                    begin
                        S = 3'b010;                
                    end 
                    5'b00101:
                    //ENOR
                    begin
                        S = 3'b010;                
                    end 
                    5'b00110:
                    //LSL
                    begin
                        S = 3'b010;                
                    end 
                    5'b00111:
                    //LSR
                    begin
                        S = 3'b010;                
                    end 
                    5'b01000:
                    //ORR
                    begin
                        S = 3'b010;                
                    end 
                    5'b01001:
                    //SUB
                    begin
                        S = 3'b010;                
                    end 
                    5'b01010:
                    //SUBS
                    begin
                        S = 3'b010;                
                    end 
                endcase            
            end
            
            6'b100010:
            //I-Format
            begin
                case(code[4:1]) 
                    4'b0000:
                    //ADDI
                    begin
                        S = 3'b010;                
                    end 
                    4'b0001:
                    //ADDIS
                    begin
                        S = 3'b010;                
                    end 
                    4'b0010:
                    //ANDI
                    begin
                        S = 3'b010;                
                    end   
                    4'b0011:
                    //ANDIS
                    begin
                        S = 3'b010;                
                    end 
                    4'b0100:
                    //EORI
                    begin
                        S = 3'b010;                
                    end 
                    4'b0101:
                    //ENORI
                    begin
                        S = 3'b010;                
                    end 
                    4'b0110:
                    //ORRI
                    begin
                        S = 3'b010;                
                    end 
                    4'b0111:
                    //SUBI
                    begin
                        S = 3'b010;                
                    end 
                    4'b1000:
                    //SUBIS
                    begin
                        S = 3'b010;                
                    end
                endcase
            end

            6'b110100:
            //D-Format
            begin
                case(code[4:0]) 
                    5'b00000:
                    //LDUR
                    begin
                        S = 3'b010;                
                    end 
                    5'b00001:
                    //STUR
                    begin
                        S = 3'b010;                
                    end 
                endcase
            end

            6'b110010:
            //IM-Format
            begin
                case(code[4:2]) 
                    3'b101:
                    //LDUR
                    begin
                        S = 3'b010;                
                    end 
                    3'b:
                endcase
            end

            6'b000011:
            //B-Format
            begin
                S = 3'b100;
            end
            
            6'b111101, 6'b011101:
            //CB-Format pt.1
            begin
                case(code[10:3]) 
                    8'b11110100:
                    //CBZ
                    begin
                        S = 3'b010;                
                    end 
                    8'b11110101:
                    //CBNZ
                    begin
                        S = 3'b010;                
                    end 
                    8'b01110100:
                    //BEQ
                    begin
                        S = 3'b010;                
                    end 
                    8'b01110101:
                    //BNE
                    begin
                        S = 3'b010;                
                    end 
                    8'b01110110:
                    //BLT
                    begin
                        S = 3'b010;                
                    end 
                    8'b01110111:
                    //BGE
                    begin
                        S = 3'b010;                
                    end 
                    
                endcase
            end
            
            default:
                begin
                S = 3'b000;
                end
        endcase    
    end
endmodule

module signextend(
    input [15:0] in,
    output [31:0] extend
    );
    
    assign extend = {{16{in[15]}}, in};
    
endmodule

module mux2to1(
    input [31:0] a,
    input [31:0] b,
    output [31:0] out,
    input select
    );
    
    assign out = select ? a : b;
endmodule

module reg1(
    input d,
    output reg q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule

module reg3(
    input [2:0] d,
    output reg [2:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule
module branchEQ (
    input [31:0] A, 
    input [31:0] B,
    input BEQInstr, 
    input BNEInstr,
    output branchTrue
    );
    assign branchTrue = (BEQInstr===1'b1 && A===B) || (BNEInstr===1'b1 && A!==B);
    
endmodule

module regalu(
    input [31:0] Aselect,
    input [31:0] Bselect,
    input [31:0] Dselect,
    input [31:0] ImmVal,
    input Imm,
    input clk,
    output [31:0] abus,
    output [31:0] bbus,
    output [31:0] dbus,
    input [2:0] S,
    input Cin,
    input LWFlag, SWFlag,
    input BEQFlag, BNEFlag,
    input SLTFlag, SLEFlag,
    inout [31:0] databus,
    output [31:0] daddrbus,
    output branchTrue
    );
    wire [31:0] REGtoALUa, REGtoALUb;
    regfile32x32 regfile(
        .dselect(Dselect),
        .aselect(Aselect),
        .bselect(Bselect),
        .dbus(dbus),
        .clk(clk),
        .abus(REGtoALUa),
        .bbus(REGtoALUb)
    );
    
    branchEQ branchLogic(
        .A(REGtoALUa), 
        .B(REGtoALUb),
        .BEQInstr(BEQFlag), 
        .BNEInstr(BNEFlag),
        .branchTrue(branchTrue)
    );
    
    
    
alupipe alu(
        .S(S),
        .abus(REGtoALUa),
        .bbus(REGtoALUb),
        .ImmVal(ImmVal),
        .Imm(Imm),
        .clk(clk),
        .Cin(Cin),
        .dbus(dbus),
        .abusout(abus),
        .bbusout(bbus),
        .LWFlag(LWFlag),
        .SWFlag(SWFlag),
        .SLTFlag(SLTFlag),
        .SLEFlag(SLEFlag),
        .databus(databus),
        .daddrbus(daddrbus)
        );
endmodule

module regfile32x32(
    input [31:0] dselect,
    input [31:0] aselect,
    input [31:0] bselect,
    input [31:0] dbus,
    input clk,
    output [31:0] abus,
    output [31:0] bbus
    );
    
    
    
    reg32negative registers[31:1](
    .d(dbus),
    .abus(abus),
    .bbus(bbus),
    .clk(clk),
    .dselect(dselect[31:1]),
    .aselect(aselect[31:1]),
    .bselect(bselect[31:1])
    );
    
    assign abus = aselect[0]==1'b1 ? 32'b0 : 32'bz;
    assign bbus = bselect[0]==1'b1 ? 32'b0 : 32'bz;
endmodule

module reg32negative(
    input [31:0] d,
    output [31:0] abus,
    output [31:0] bbus,
    input aselect,
    input bselect,
    input clk,
    input dselect   
    );
    reg [31:0] q;
    wire newclk;
    always@(negedge clk)
        if (dselect==1'b1) q = d;
    
    assign abus = aselect ? q : 32'bz;
    assign bbus = bselect ? q : 32'bz;
endmodule

module setlogic(
    input [31:0] in,
    input C,
    input Z,
    input SLEFlag, SLTFlag,
    output reg [31:0] out
    );
    always @(SLTFlag, SLEFlag, C, Z, out, in) begin
    out = in;
    if(SLTFlag===1'b1)
        begin
        out = (!C && !Z) ? 32'h00000001 : 32'h00000000;
        end
    
    if(SLEFlag===1'b1)
        begin
        out = (!C || Z) ? 32'h00000001 : 32'h00000000;
    end
        
    
    end
    
endmodule

module alupipe(
    input [2:0] S,
    input [63:0] abus,
    input [63:0] bbus,
    input [63:0] ImmVal,
    input Imm,
    input clk,
    input Cin,
    input LWFlag, SWFlag,
    input SLEFlag, SLTFlag,
    output [63:0] dbus,
    output [63:0] abusout,
    output [63:0] bbusout,
    inout [63:0] databus,
    output [63:0] daddrbus,
    output C, N, Z, V
    );
       
    wire [31:0] AtoALU, BtoMUX, SettoD, IMMtoMUX, MUXtoALU, databustoMUX, DADDRtoMUX, databusOUTtoMUX, databusAssign;
    wire [31:0] ALUtoSET;

    wire LWALU, SWALU, LWdb, SWdb, LWout, SWout;
    
    //---- IDEX -----------------------
    //abus into IDEX out to abusout -> alu
    reg32 A(
        .d(abus), 
        .clk(clk), 
        .q(abusout)
    );

    //bbus into IDEX out to BtoMUX -> mux
    reg32 B(
        .d(bbus), 
        .clk(clk), 
        .q(BtoMUX)
    );

    //LWFlag into IDEX and out to LWALU
    reg1 LWin(
        .d(LWFlag), 
        .clk(clk), 
        .q(LWALU)
    ); 

    //SWFlag into IDEX and out to SWALU
    reg1 SWin(
        .d(SWFlag), 
        .clk(clk), 
        .q(SWALU)
    );

    //---- Execute Stage Interior -----
    //Immediate value and B into MUX, selected by imm (IMMFlag), out to bbusout -> alu
    mux2to1 IMMorBselect(
        .a(ImmVal),
        .b(BtoMUX),
        .out(bbusout),
        .select(Imm)
    );
    
    //
    alu64 alu(
        .d(ALUtoSET), 
        .C(C), 
        .V(V), 
        .Z(Z),
        .N(N),
        .a(abusout),
        .b(bbusout),
        .Cin(Cin), 
        .S(S)
     );
     wire SLEout, SLTout;
    reg1 SLEin(
        .d(SLEFlag), 
        .clk(clk), 
        .q(SLEout)
    ); 
    reg1 SLTin(
        .d(SLTFlag), 
        .clk(clk), 
        .q(SLTout)
    );
    setlogic thing(
        .in(ALUtoSET),
        .C(C),
        .Z(Z),
        .SLEFlag(SLEout),
        .SLTFlag(SLTout),
        .out(SettoD)
    );
    
        
    reg32 DADDRin(
        .d(SettoD), 
        .clk(clk), 
        .q(daddrbus)
    );
    reg32 databusin(
        .d(BtoMUX), 
        .clk(clk), 
        .q(databustoMUX)
    );
    reg1 SWoutALU(
        .d(SWALU), 
        .clk(clk), 
        .q(SWdb)
    );
    reg1 LWoutALU(
        .d(LWALU), 
        .clk(clk), 
        .q(LWdb)
    );
    
    assign databus = SWdb ? databustoMUX : 32'bz;
    
    reg32 DADDROUT(
        .d(daddrbus), 
        .clk(clk), 
        .q(DADDRtoMUX)
    );
    reg32 databusOUT(
        .d(databus), 
        .clk(clk), 
        .q(databusOUTtoMUX)
    );

    reg1 LWoutReg(
        .d(LWdb), 
        .clk(clk), 
        .q(LWout)
    );  
    mux2to1 dbusOUT(
        .a(databusOUTtoMUX),
        .b(DADDRtoMUX),
        .out(dbus),
        .select(LWout)
    );
endmodule


//==== 64-BIT ALU =========================================
module alu64 (d, Cout, V, a, b, Cin, S, Z);
   output [63:0] d;
   output C, V, Z, N;
   input [63:0] a, b;
   input Cin;
   input [2:0] S;
   
   wire [31:0] c, g, p;
   wire gout, pout;
   
   //Alu cells for each bit
   alu_cell alucell[63:0] (
      .d(d),
      .g(g),
      .p(p),
      .a(a),
      .b(b),
      .c(c),
      .S(S)
   );
   
   //LAC Tree
   lac6 laclevel6(
      .c(c),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(g),
      .p(p)
   );

   //Flag Calculations
   assign C = gout | (pout & Cin); //Carry-out flag
   assign V = Cout ^ c[63]; //Overflow flag
   assign Z = !(|d); // Zero flag
   assign N = (d < 64'h0000000000000000) ? 1'b1 : 1'b0; //Negative flag
endmodule

//==== ALU CELL =======================
module alu_cell (d, g, p, a, b, c, S);
    output reg d;
    output g, p;
    input a, b, c;
    input [2:0] S;
    
    wire cint, bint;

    assign bint = (~S[2] & S[0]) ^ b;
    assign g=a&bint;
    assign p=a^bint;
    assign cint = (~S[2] & S[1]) & c;
    
    //case statements for functions, according to the assignment doc
    always @ (d, p, cint, a, b, S) 
        case(S)
            3'b000, 3'b001, 3'b010, 3'b011:
                d = p ^ cint;    
            3'b100: //OR
                d = a|b;
            3'b101: //Logical Shift Left
                d = a << b;
            3'b110: //AND
                d = a & b;
            3'b111: //Logical Shift Right
                d = a >> b;
        endcase
    end
endmodule

//==== LAC TREES ======================
module lac(c, gout, pout, Cin, g, p);
    // base LAC, given in class slides
    output [1:0] c;
    output gout, pout;
    input Cin;
    input [1:0] g, p;
    
    assign c[0] = Cin;
    assign c[1] = g[0] | (p[0]&Cin);
    assign gout = g[1]|(p[1]&g[0]);
    assign pout = p[1]&p[0];
endmodule

module lac2(c, gout, pout, Cin, g, p);
    output [3:0] c;
    output gout, pout;
    input Cin;
    input [3:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac leaf0(
        .c(c[1:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[1:0]),
        .p(p[1:0])
    );
    
    lac leaf1(
        .c(c[3:2]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[3:2]),
        .p(p[3:2])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule   

module lac3(c, gout, pout, Cin, g, p);
    output [7:0] c;
    output gout, pout;
    input Cin;
    input [7:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac2 leaf0(
        .c(c[3:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[3:0]),
        .p(p[3:0])
    );
    
    lac2 leaf1(
        .c(c[7:4]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[7:4]),
        .p(p[7:4])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac4(c, gout, pout, Cin, g, p);
    output [15:0] c;
    output gout, pout;
    input Cin;
    input [15:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac3 leaf0(
        .c(c[7:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[7:0]),
        .p(p[7:0])
    );
    
    lac3 leaf1(
        .c(c[15:8]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[15:8]),
        .p(p[15:8])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac5(c, gout, pout, Cin, g, p);
    //top-level LAC tree
    output [31:0] c;
    output gout, pout;
    input Cin;
    input [31:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac4 leaf0(
        .c(c[15:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[15:0]),
        .p(p[15:0])
    );
    
    lac4 leaf1(
        .c(c[31:16]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[31:16]),
        .p(p[31:16])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac6(c, gout, pout, Cin, g, p);
    //top-level LAC tree
    output [63:0] c;
    output gout, pout;
    input Cin;
    input [63:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac5 leaf0(
        .c(c[31:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[31:0]),
        .p(p[31:0])
    );
    
    lac5 leaf1(
        .c(c[63:32]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[63:32]),
        .p(p[63:32])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule