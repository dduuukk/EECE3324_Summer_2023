`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 12:35:16 PM
// Design Name: 
// Module Name: decode5to32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decode5to32(
    input [4:0] code,
    output reg [31:0] out
    );
    
    always @(code, out) begin
        out = 32'b1 << code;
        end
endmodule
