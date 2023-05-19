`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 12:37:50 PM
// Design Name: 
// Module Name: decodeopcode
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


module decodeopcode(
    input [5:0] code,
    input [5:0] funct,
    output reg Imm,
    output reg [2:0] S,
    output reg Cin
    );
    always @(code, funct, S, Imm, Cin) begin
        case(code)
            6'b000011:
            begin
                S = 3'b010;
                Imm = 1'b1;
                Cin = 1'b0;
            end
            6'b000010:
            begin
                S = 3'b011;
                Imm = 1'b1;
                Cin = 1'b1;
            end
            6'b000001:
            begin
                S = 3'b000;
                Imm = 1'b1;
                Cin = 1'b0;
            end
            6'b001111:
            begin
                S = 3'b110;
                Imm = 1'b1;
                Cin = 1'b0;
            end
            6'b001100:
            begin
                S = 3'b100;
                Imm = 1'b1;
                Cin = 1'b0;
            end
            6'b00000:
            begin
                case(funct)
                    6'b000011:
                    begin
                        S = 3'b010;
                        Imm = 1'b0;
                        Cin = 1'b0;
                    end
                    6'b000010:
                    begin
                        S = 3'b011;
                        Imm = 1'b0;
                        Cin = 1'b1;
                    end
                    6'b000001:
                    begin
                        S = 3'b000;
                        Imm = 1'b0;
                        Cin = 1'b0;
                    end
                    6'b000111:
                    begin
                        S = 3'b110;
                        Imm = 1'b0;
                        Cin = 1'b0;
                    end
                    6'b000100:
                    begin
                        S = 3'b100;
                        Imm = 1'b0;
                        Cin = 1'b0;
                    end
                    default:
                    begin
                        S = 3'b000;
                        Imm = 1'b0;
                        Cin = 1'b0;
                    end
                 endcase
            end
            default:
                begin
                S = 3'b000;
                Imm = 1'b0;
                Cin = 1'b0;
                end
        endcase    
    end
endmodule
