//Christian Bender and Joe Perkins
`timescale 1ns / 1ps

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
