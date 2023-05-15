`timescale 1ns / 1ps

module regalu(
    input [31:0] Aselect,
    input [31:0] Bselect,
    input [31:0] Dselect,
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
        .abus(abus),
        .bbus(bbus)
    );
    
    alupipe alu(
        .S(S),
        .abus(abus),
        .bbus(bbus),
        .clk(clk),
        .Cin(Cin),
        .dbus(dbus));
endmodule
