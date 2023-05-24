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


module cpu3(
    input [31:0] ibus,
    input clk,
    output [31:0] abus,
    output [31:0] bbus,
    output [31:0] dbus 
    );
    
    wire [31:0] REGAselect, REGBselect, REGDselect, IMMVALtoMUX;
    wire [2:0] SELtoALU;
    wire CINtoALU, IMMtoMUX;
    
    controller Controller(
        .ibus(ibus),
        .clk(clk),
        .Aselect(REGAselect),
        .Bselect(REGBselect),
        .Dselect(REGDselect),
        .immValue(IMMVALtoMUX),
        .Cin(CINtoALU),
        .S(SELtoALU),
        .Imm(IMMtoMUX)   
    );
    
    regalu Regalu(
        .Aselect(REGAselect),
        .Bselect(REGBselect),
        .Dselect(REGDselect),
        .ImmVal(IMMVALtoMUX),
        .Imm(IMMtoMUX),
        .clk(clk),
        .abus(abus),
        .bbus(bbus),
        .dbus(dbus),
        .S(SELtoALU),
        .Cin(CINtoALU)
    );

endmodule
