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
    output [31:0] dbus,
    output [31:0] abusout,
    output [31:0] bbusout
    
    );
    
    wire [31:0] AtoALU, BtoMUX, ALUtoD, IMMtoMUX, MUXtoALU;
    
    reg32 A(.d(abus), 
            .clk(clk), 
            .q(abusout));
    reg32 B(.d(bbus), 
            .clk(clk), 
            .q(BtoMUX)); 
    
    mux2to1 IMMorBselect(
        .a(ImmVal),
        .b(BtoMUX),
        .out(bbusout),
        .select(Imm)
    );
    
    
    alu32 alu(.d(ALUtoD), 
              .Cout(), 
              .V(), 
              .a(abusout),
              .b(bbusout),
              .Cin(Cin), 
              .S(S));
              
    reg32 D(.d(ALUtoD), 
            .clk(clk), 
            .q(dbus));
endmodule
