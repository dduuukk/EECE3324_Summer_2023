//Christian Bender and Joe Perkins
`timescale 1ns / 1ps

module alupipe(
    input [2:0] S,
    input [31:0] abus,
    input [31:0] bbus,
    input [31:0] ImmVal,
    input Imm,
    input clk,
    input Cin,
    input SWflag,
    input LWflag,
    output [31:0] dbus,
    inout [31:0] databus,
    output [31:0] daddrbus
    );
    
    wire [31:0] AtoALU, BtoMUX, ALUtoD, IMMtoMUX, MUXtoALU;
    
    reg32 A(.d(abus), 
            .clk(clk), 
            .q(AtoALU));
    reg32 B(.d(bbus), 
            .clk(clk), 
            .q(BtoMUX)); 
    
    mux2to1 IMMorBselect(
        .a(ImmVal),
        .b(BtoMUX),
        .out(BtoALU),
        .select(Imm)
    );
    
    
    alu32 alu(.d(ALUtoD), 
              .Cout(), 
              .V(), 
              .a(AtoALU),
              .b(BtoALU),
              .Cin(Cin), 
              .S(S));
              
    reg32 EXMEMD(.d(ALUtoD), 
            .clk(clk), 
            .q(daddrbus));
            
    reg32 EXMEMB(.d(BtoMUX), 
            .clk(clk), 
            .q(databustoMUX));
     
     wire [31:0] daddrMEMWBin;
     assign daddrMEMWBin = daddrbus;
     reg32 daddrbusMEMWB(
        .d(daddrMEMWBin), 
        .clk(clk), 
        .q(DADDRtoMUX)
    );
    
    mux2to1 databusSelect(
        .a(databustoMUX),
        .b(32'hzzzzzzzz),
        .out(databus),
        .select(SWflag)
    );
    
    reg32 dbusMEMWB(
        .d(databus), 
        .clk(clk), 
        .q(DATAtoMUX)
    );
    
    mux2to1 dbusOUT(
        .a(DATAtoMUX),
        .b(DADDRtoMUX),
        .out(dbus),
        .select(LWflag)
    );
            
    

endmodule
