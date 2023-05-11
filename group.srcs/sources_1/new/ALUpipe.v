`timescale 1ns / 1ps

module alupipe(
    input [2:0] S,
    input [31:0] abus,
    input [31:0] bbus,
    input clk,
    input Cin,
    output [31:0] dbus
    );
    
    wire [31:0] AtoALU, BtoALU, ALUtoD;
    
    reg32 A(.d(abus), 
            .clk(clk), 
            .q(AtoALU));
    reg32 B(.d(bbus), 
            .clk(clk), 
            .q(BtoALU));
    
    alu32 alu(.d(ALUtoD), 
              .Cout(), 
              .V(), 
              .a(AtoALU), 
              .b(BtoALU), 
              .Cin(Cin), 
              .S(S));
              
    reg32 D(.d(ALUtoD), 
            .clk(clk), 
            .q(dbus));
endmodule
