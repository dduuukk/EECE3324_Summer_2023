//Christian Bender and Joe Perkins
`timescale 1ns / 1ps

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
    input Cin
    );

    regfile32x32 regfile(
        .dselect(Dselect),
        .aselect(Aselect),
        .bselect(Bselect),
        .dbus(dbus),
        .clk(clk),
        .abus(REGtoALUa),
        .bbus(REGtoALUb)
    );
    
    wire [31:0] REGtoALUa, REGtoALUb;
    
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
        .bbusout(bbus));
endmodule
