//Christian Bender and Joe Perkins
`timescale 1ns / 1ps

module reg1(
    input d,
    output reg q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule