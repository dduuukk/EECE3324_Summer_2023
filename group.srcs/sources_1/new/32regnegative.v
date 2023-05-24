//Christian Bender and Joe Perkins
`timescale 1ns / 1ps


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
    assign newclk = dselect & clk;
    always@(negedge clk)
        if (dselect==1'b1) q = d;
    
    assign abus = aselect ? q : 32'bz;
    assign bbus = bselect ? q : 32'bz;
endmodule
