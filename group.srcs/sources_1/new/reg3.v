//Christian Bender and Joe Perkins
`timescale 1ns / 1ps

module reg3(
    input [2:0] d,
    output reg [2:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule