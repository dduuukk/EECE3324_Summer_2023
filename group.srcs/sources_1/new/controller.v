`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 01:06:36 PM
// Design Name: 
// Module Name: controller
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


module controller(
    input [31:0] ibus,
    input clk,
    output [31:0] Aselect,
    output [31:0] Bselect,
    output [31:0] Dselect,
    output Cin,
    output [2:0] S,
    output Imm    
    );
    
    wire [31:0] iregtodecoders, rdtomux, MUXtoIDEX, IDEXtoEXMEM;
    wire decodeImm, decodeCin;
    wire [2:0] decodeS;
    
    reg32 IFID(.d(ibus), .q(iregtodecoders), .clk(clk));
    
    decode5to32 rsDecode(
        .code(iregtodecoders[25:21]),
        .out(Aselect)    
    );
    decode5to32 rtDecode(
        .code(iregtodecoders[20:16]),
        .out(Bselect)    
    );
    decode5to32 rdDecode(
        .code(iregtodecoders[15:11]),
        .out(rdtomux)    
    );
    
    decodeopcode opdecode(
        .code(iregtodecoders[31:26]),
        .funct(iregtodecoders[5:0]),
        .Imm(decodeImm),
        .S(decodeS),
        .Cin(decodeCin)
    );
    
    mux2to1 decodeMux(
        .a(Bselect),
        .b(rdtomux),
        .out(MUXtoIDEX),
        .select(decodeImm)
    );
    
    reg32 IDEXD(.d(MUXtoIDEX), .q(IDEXtoEXMEM), .clk(clk));
    reg32 IDEXImm(.d(decodeImm), .q(Imm), .clk(clk));
    reg32 IDEXS(.d(decodeS), .q(S), .clk(clk));
    reg32 IDEXCin(.d(decodeCin), .q(Cin), .clk(clk));
    
    reg32 EXMEMD(.d(IDEXtoEXMEM), .q(Dselect), .clk(clk));

endmodule
