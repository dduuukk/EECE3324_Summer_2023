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
    output [31:0] immValue,
    output Cin,
    output [2:0] S,
    output Imm,
    output LWflag, SWflag
    );
    
    wire [31:0] iregtodecoders, rdtomux, MUXtoIDEX, IDEXtoEXMEM,IMMtoIDEX, MUXtoMUX;
    wire decodeImm, decodeCin, decodeLW, LWtoEXMEM, SWtoEXMEM, LWtoMEMWB, decodeSW;
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
        .Cin(decodeCin),
        .isLW(decodeLW),
        .isSW(decodeSW)
    );
    signextend SignExtend(
        .in(iregtodecoders[15:0]),
        .extend(IMMtoIDEX)
    );
    
    mux2to1 decodeMux(
        .a(Bselect),
        .b(rdtomux),
        .out(MUXtoMUX),
        .select(decodeImm)
    );
    
        mux2to1 DselectMux(
        .a(32'h00000001),
        .b(MUXtoMUX),
        .out(MUXtoIDEX),
        .select(decodeSW)
    );
    
    reg32 IDEXD(.d(MUXtoIDEX), .q(IDEXtoEXMEM), .clk(clk));
    reg32 IDEXDImm(.d(IMMtoIDEX), .q(immValue), .clk(clk));
    reg1 IDEXImm(.d(decodeImm), .q(Imm), .clk(clk));
    reg3 IDEXS(.d(decodeS), .q(S), .clk(clk));
    reg1 IDEXCin(.d(decodeCin), .q(Cin), .clk(clk));
    
    reg1 IDEXLWflag(.d(decodeLW), .q(LWtoEXMEM), .clk(clk));
    reg1 IDEXSWflag(.d(decodeSW), .q(SWtoEXMEM), .clk(clk));
    
    reg1 EXMEMLWflag(.d(LWtoEXMEM), .q(LWtoMEMWB), .clk(clk));
    reg1 EXMEMSWflag(.d(SWtoEXMEM), .q(SWflag), .clk(clk));
    
    reg32 EXMEMD(.d(IDEXtoEXMEM), .q(Dselect), .clk(clk));
    
    reg1 MEMWBLWflag(.d(LWtoMEMWB), .q(LWflag), .clk(clk));

endmodule
