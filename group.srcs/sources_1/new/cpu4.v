`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2023 12:12:05 PM
// Design Name: 
// Module Name: cpu4
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


module my_cpu4(
    input [31:0] ibus,
    input clk,
    output [31:0] daddrbus,
    inout [31:0] databus
    );
    
    wire [31:0] DADDRtoMUX, DATAtoMUX, databustoMUX;
    
    cpu3 CPU3(
        .ibus(ibus),
        .clk(clk),
        .daddrbus(daddrbus),
        .databus(databus)
    );
    
endmodule
