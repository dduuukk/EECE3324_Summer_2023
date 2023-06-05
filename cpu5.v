`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 01:06:36 PM
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu5(
    input [31:0] ibus,
    input clk,
    output [31:0] abus,
    output [31:0] bbus,
    output [31:0] dbus,
    inout [31:0] databus,
    output [31:0] daddrbus
    );
    
    wire [31:0] REGAselect, REGBselect, REGDselect, IMMVALtoMUX;
    wire [2:0] SELtoALU;
    wire CINtoALU, IMMtoMUX, LWF, SWF, SLT, SLE;
    
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
        .SLTFlag(SLT),
        .SLEFlag(SLE) 
    );
    
    regalu Regalu(
        .Aselect(REGAselect),
        .Bselect(REGBselect),
        .Dselect(REGDselect),
        .ImmVal(IMMVALtoMUX),
        .Imm(IMMtoMUX),
        .clk(clk),
        .abus(abus),
        .bbus(bbus),
        .dbus(dbus),
        .S(SELtoALU),
        .Cin(CINtoALU),
        .LWFlag(LWF),
        .SWFlag(SWF),
        .SLTFlag(SLT),
        .SLEFlag(SLE),
        .databus(databus),
        .daddrbus(daddrbus)
    );

endmodule

module controller(
    input [31:0] ibus,
    input clk,
    output [31:0] Aselect,
    output [31:0] Bselect,
    output [31:0] Dselect,
    output [31:0] immValue,
    output Cin,
    output [2:0] S,
    output Imm,
    output LWFlag, SWFlag,
    output SLTFlag, SLEFlag 
    );
    
    wire [31:0] iregtodecoders, rdtomux, MUXtoIDEX, IDEXtoEXMEM,IMMtoIDEX, DSELtoMEMWB, MUXtoDWB;
    wire decodeImm, decodeCin;
    wire [2:0] decodeS;
    
    reg32 IFID(.d(ibus), .q(iregtodecoders), .clk(clk));
    
    decode5to32 rsDecode(
        .code(iregtodecoders[25:21]),
        .out(Aselect)    
    );
    decode5to32 rtDecode(
        .code(iregtodecoders[20:16]),
        .out(Bselect)    
    );
    decode5to32 rdDecode(
        .code(iregtodecoders[15:11]),
        .out(rdtomux)    
    );
    decodeopcode opdecode(
        .code(iregtodecoders[31:26]),
        .funct(iregtodecoders[5:0]),
        .Imm(decodeImm),
        .S(decodeS),
        .Cin(decodeCin),
        .LWFlag(LWFlag),
        .SWFlag(SWFlag),
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
        .a(32'h000000001),
        .b(MUXtoDWB),
        .out(MUXtoIDEX),
        .select(SWFlag)
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

module decode5to32(
    input [4:0] code,
    output reg [31:0] out
    );
    
    always @(code, out) begin
        out = 32'b1 << code;
        end
endmodule

module decodeopcode(
    input [5:0] code,
    input [5:0] funct,
    output reg Imm,
    output reg [2:0] S,
    output reg Cin,
    output reg SWFlag, LWFlag,
    output reg SLTFlag, SLEFlag 
    );
    always @(code, funct, S, Imm, Cin) begin
        case(code)
            6'b000011:
            begin
                S = 3'b010;
                Imm = 1'b1;
                Cin = 1'b0;
                SWFlag = 1'b0;
                LWFlag = 1'b0;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
            end
            6'b000010:
            begin
                S = 3'b011;
                Imm = 1'b1;
                Cin = 1'b1;
                SWFlag = 1'b0;
                LWFlag = 1'b0;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
            end
            6'b000001:
            begin
                S = 3'b000;
                Imm = 1'b1;
                Cin = 1'b0;
                SWFlag = 1'b0;
                LWFlag = 1'b0;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
            end
            6'b001111:
            begin
                S = 3'b110;
                Imm = 1'b1;
                Cin = 1'b0;
                SWFlag = 1'b0;
                LWFlag = 1'b0;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
            end
            6'b001100:
            begin
                S = 3'b100;
                Imm = 1'b1;
                Cin = 1'b0;
                SWFlag = 1'b0;
                LWFlag = 1'b0;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
            end
            6'b011110:
            begin
                S = 3'b010;
                Imm = 1'b1;
                Cin = 1'b0;
                SWFlag = 1'b0;
                LWFlag = 1'b1;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
            end
            6'b011111:
            begin
                S = 3'b010;
                Imm = 1'b1;
                Cin = 1'b0;
                SWFlag = 1'b1;
                LWFlag = 1'b0;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
            end
            6'b00000:
            begin
                SWFlag = 1'b0;
                LWFlag = 1'b0;
                case(funct)
                    6'b000011:
                    begin
                        S = 3'b010;
                        Imm = 1'b0;
                        Cin = 1'b0;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b0;
                    end
                    6'b000010:
                    begin
                        S = 3'b011;
                        Imm = 1'b0;
                        Cin = 1'b1;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b0;
                    end
                    6'b000001:
                    begin
                        S = 3'b000;
                        Imm = 1'b0;
                        Cin = 1'b0;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b0;
                    end
                    6'b000111:
                    begin
                        S = 3'b110;
                        Imm = 1'b0;
                        Cin = 1'b0;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b0;
                    end
                    6'b000100:
                    begin
                        S = 3'b100;
                        Imm = 1'b0;
                        Cin = 1'b0;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b0;
                    end
                    6'b110110:
                    begin
                        S = 3'b100;
                        Imm = 1'b0;
                        Cin = 1'b0;
                        SLTFlag = 1'b1;
                        SLEFlag = 1'b0;
                    end
                    6'b110111:
                    begin
                        S = 3'b100;
                        Imm = 1'b0;
                        Cin = 1'b0;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b1;
                    end
                    default:
                    begin
                        S = 3'b000;
                        Imm = 1'b0;
                        Cin = 1'b0;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b0;
                    end
                 endcase
            end
            default:
                begin
                S = 3'b000;
                Imm = 1'b0;
                Cin = 1'b0;
                SWFlag = 1'b0;
                LWFlag = 1'b0;
                SLTFlag = 1'b0;
                SLEFlag = 1'b0;
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
    input SLTFlag, SLEFlag,
    inout [31:0] databus,
    output [31:0] daddrbus
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
    always @(SLTFlag, SLEFlag, C, Z, out) begin
    if(SLTFlag)
        begin
        out = (!C & !Z) ? 32'h00000001 : 32'h00000000;
        end
     else if(SLEFlag)
        begin
        out = (!C | Z) ? 32'h00000001 : 32'h00000000;
        end
        else
            out = in;
    end
    
endmodule

module alupipe(
    input [2:0] S,
    input [31:0] abus,
    input [31:0] bbus,
    input [31:0] ImmVal,
    input Imm,
    input clk,
    input Cin,
    output [31:0] dbus,
    output [31:0] abusout,
    output [31:0] bbusout,
    input LWFlag, SWFlag,
    input SLEFlag, SLTFlag,
    inout [31:0] databus,
    output [31:0] daddrbus
    );
       
    wire [31:0] AtoALU, BtoMUX, SettoD, ALUtoSET, IMMtoMUX, MUXtoALU, databustoMUX, DADDRtoMUX, databusOUTtoMUX, databusAssign;

    wire LWALU, SWALU, LWdb, SWdb, LWout, SWout, Cout;
    
    reg32 A(
        .d(abus), 
        .clk(clk), 
        .q(abusout)
    );
    reg32 B(
        .d(bbus), 
        .clk(clk), 
        .q(BtoMUX)
    );
    reg32 LWin(
        .d(LWFlag), 
        .clk(clk), 
        .q(LWALU)
    ); 
    reg32 SWin(
        .d(SWFlag), 
        .clk(clk), 
        .q(SWALU)
    );
    mux2to1 IMMorBselect(
        .a(ImmVal),
        .b(BtoMUX),
        .out(bbusout),
        .select(Imm)
    );
    
    alu32 alu(
        .d(ALUtoD), 
        .Cout(Cout), 
        .V(), 
        .Z(Z),
        .a(abusout),
        .b(bbusout),
        .Cin(Cin), 
        .S(S)
     );
    
    setlogic thing(
        .in(ALUtoSet),
        .C(Cout),
        .Z(Z),
        .SLEFlag(SLEFlag),
        .SLTFlag(SLTFlag),
        .out(SettoD)
    );
    
        
    reg32 DADDRin(
        .d(ALUtoD), 
        .clk(clk), 
        .q(daddrbus)
    );
    reg32 databusin(
        .d(BtoMUX), 
        .clk(clk), 
        .q(databustoMUX)
    );
    reg32 SWoutALU(
        .d(SWALU), 
        .clk(clk), 
        .q(SWdb)
    );
    reg32 LWoutALU(
        .d(LWALU), 
        .clk(clk), 
        .q(LWdb)
    );
//    mux2to1 databusSelect(
//        .a(databustoMUX),
//        .b(32'hzzzzzzzz),
//        .out(databus),
//        .select(SWflag)
//    );
//    tristate tristateFloating(
//        .enable(SWdb),
//        .data(databustoMUX),
//        .inoutPort(databus)
//    );
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

    reg32 LWoutReg(
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

module alu32 (d, Cout, V, a, b, Cin, S, Z);
   output[31:0] d;
   output Cout, V, Z;
   input [31:0] a, b;
   input Cin;
   input [2:0] S;
   
   wire [31:0] c, g, p;
   wire gout, pout;
   
   //alu cells for each bit
   alu_cell alucell[31:0] (
      .d(d),
      .g(g),
      .p(p),
      .a(a),
      .b(b),
      .c(c),
      .S(S)
   );
   
   //LAC tree
   lac5 laclevel5(
      .c(c),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(g),
      .p(p)
   );

   //overflow calculation 
   assign Cout = gout | (pout & Cin);
   assign V = Cout ^ c[31];
   assign Z = !(|d);
  
endmodule


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
    always@(d,p,cint,a,b,S) 
        case (S)
            3'b000, 3'b001, 3'b010, 3'b011:
                d = p ^ cint;
                
            3'b100:
                d = a|b;
                
            3'b101:
                d = ~(a | b);
            3'b110:
                d = a & b;
            3'b111:
                d = 1'b0;
    endcase
endmodule

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