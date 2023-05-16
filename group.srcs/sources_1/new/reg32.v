//Christian Bender and Joe Perkins
`timescale 1ns / 1ps

module reg32(
    input [31:0] d,
    output reg [31:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule
