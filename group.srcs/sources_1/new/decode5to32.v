`timescale 1ns / 1ps

module decode5to32(
    input [4:0] code,
    output reg [31:0] out
    );
    
    always @(code, out) begin
        out = 32'b1 << code;
        end
endmodule
