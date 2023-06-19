`timescale 1ns / 1ps


module cpu5arm(
    input [31:0] ibus,
    input clk,
    input reset,
    output [63:0] iaddrbus,
    inout [63:0] databus,
    output [63:0] daddrbus
    );
    
    wire [31:0] REGAselect, REGBselect, REGDselect;
    wire [2:0] SELtoALU;
    wire CINtoALU, IMMtoMUX, LWF, SWF, SLT, SLE;
    wire [63:0] nextInstStep, nextInstJump, nextInst, instJumpStartdelay;
    wire branchTrue;
    wire[63:0] instJumpStart;
    wire ALUOutFlag, ShiftFlag, BFlag, IMFlag;
    wire [5:0] CBFlags;
    wire [63:0] MOVImm, IMMVALtoMUX, multResult;
    
    reg64reset PC(
        .d(nextInst),
        .q(iaddrbus),
        .reset(reset),
        .clk(clk)    
    );
    reg64 IFIDInstruction(
        .d(nextInstStep),
        .q(instJumpStartdelay),
        .clk(clk)    
    );
    reg64 IFIDInstruction2(
        .d(instJumpStartdelay),
        .q(instJumpStart),
        .clk(clk)    
    );
    adder branchAdd(
        .A(multResult), 
        .B(instJumpStart),  
        .out(nextInstJump)
    );
    mux2to64 instMux(
        .a(nextInstJump),
        .b(nextInstStep),
        .out(nextInst),
        .select((branchTrue||takeCondBranch || BFlag) === 1'b1)
    );
    adder plusFour(
        .A(iaddrbus),
        .B(64'h0000000000000004),
        .out(nextInstStep)
    );  
    

    

    
    
    //---- Pipeline W/O Branching -------------------------
    controller Controller(
        .ibus(ibus),
        .clk(clk),
        .Aselect(REGAselect),
        .Bselect(REGBselect),
        .Dselect(REGDselect),
        .immValue(IMMVALtoMUX),
        .Cin(CINtoALU),
        .S(SELtoALU),
        .Imm(IMMtoMUX),
        .LWFlag(LWF),
        .SWFlag(SWF), 
        .multResult(multResult),
        .ALUOutFlag(ALUOutFlag),  
        .BFlag(BFlag), 
        .IMFlag(IMFlag),
        .CBFlags(CBFlags),
        .MOVImm(MOVImm)
    );
    
    regalu Regalu(
        .Aselect(REGAselect),
        .Bselect(REGBselect),
        .Dselect(REGDselect),
        .ImmVal(IMMVALtoMUX),
        .Imm(IMMtoMUX),
        .clk(clk),
        .abus(),
        .bbus(),
        .dbus(),
        .S(SELtoALU),
        .Cin(CINtoALU),
        .LWFlag(LWF),
        .SWFlag(SWF),
        .branchTrue(branchTrue),
        .takeCondBranch(takeCondBranch),
        .databus(databus),
        .daddrbus(daddrbus),
        .ALUOutFlag(ALUOutFlag), 
        .BFlag(BFlag), 
        .IMFlag(IMFlag),
        .CBFlags(CBFlags),
        .MOVImm(MOVImm)
    );

endmodule

module adder (
    input [63:0] A, 
    input [63:0] B,
    output reg [63:0] out
    );
    always @(A, B, out)
        out = A + B;
endmodule

module multiplier (
    input [63:0] A, 
    input [63:0] B,
    output reg [63:0] out
    );
    always @(A, B, out)
        out = A * B;
//        assign out = A * B;
endmodule

//==== CONTROLLER =========================================
module controller(
    input [31:0] ibus,
    input clk,
    output [31:0] Aselect,
    output [31:0] Bselect,
    output [31:0] Dselect,
    output [63:0] immValue, multResult,
    output Cin,
    output [2:0] S,
    output Imm,
    output LWFlag, SWFlag,
    //ARM Flags
    output ALUOutFlag, IMFlag,
    output [5:0] CBFlags,
    output BFlag,
    output [63:0] MOVImm
    );
    
    //Signals to ID/EX
    wire [63:0] IMMtoIDEX;
    //Signals to MUXs
    wire [63:0] ALUImmtoMUX, ShamttoMUX, DTAddrtoMUX, IWshiftAMT, IWshiftAMTtoMUX;
    wire [31:0] iregtodecoders, rntoMUX, rmtoMUX, rdtoMUX, MUXtoIDEX, IDEXtoEXMEM, DSELtoMEMWB;
    //Flags to ID/EX
    wire decodeImm, decodeCin, decodeSWFlag, decodeLWFlag, decodeALUOutFlag, decodeShiftFlag, decodeDFlag, decodeBFlag, decodeIMFlag;
    wire [5:0] decodeCBFlags;
    wire [2:0] decodeS;
    
    //Branch addr before multiplication
    wire [63:0] BRAddr, CondBRAddr, BranchAddr;

    //ibus through IF/ID
    reg32 IFID(.d(ibus), .q(iregtodecoders), .clk(clk));
    
    //---- DECODER Phase ----------------------------------
    decode5to32 rnDecode(
        .code(iregtodecoders[9:5]),
        .out(rntoMUX)    
    );
    decode5to32 rmDecode(
        .code(iregtodecoders[20:16]),
        .out(rmtoMUX)    
    );
    decode5to32 rdrtDecode(
        .code(iregtodecoders[4:0]),
        .out(rdtoMUX)    
    );
    decodeopcode opdecode(
        .code(iregtodecoders[31:21]),
        .Imm(decodeImm),
        .S(decodeS),
        .Cin(decodeCin),
        .LWFlag(decodeLWFlag),
        .SWFlag(decodeSWFlag),
        .ALUOutFlag(decodeALUOutFlag), 
        .ShiftFlag(ShiftFlag), 
        .DFlag(DFlag), 
        .BFlag(BFlag), 
        .IMFlag(IMFlag),
        .CBFlags(CBFlags)
    );
    zeroextend2to64 extendMOVZ(
        .in(iregtodecoders[22:21]),
        .extend(IWshiftAMT)
    );
    zeroextend12to64 SignExtendALUImm(
        .in(iregtodecoders[21:10]),
        .extend(ALUImmtoMUX)
    );
    signextend26to64 SignExtendB(
        .in(iregtodecoders[25:0]),
        .extend(BRAddr)
    );
    signextend19to64 SignExtendCondB(
        .in(iregtodecoders[23:5]),
        .extend(CondBRAddr)
    );
    zeroextend6to64 ZeroExtendShamt(
        .in(iregtodecoders[15:10]),
        .extend(ShamttoMUX)
    );
    signextend9to64 SignExtendDTAddr(
        .in(iregtodecoders[20:12]),
        .extend(DTAddrtoMUX)
    );
    zeroextend16to64 SignExtendMOVImm(
        .in(iregtodecoders[20:5]),
        .extend(MOVImm)
    );

    //Multiply Shift AMT by 16
    assign IWshiftAMTtoMUX = IWshiftAMT << 4;
    
    //---- MUX Stage --------------------------------------
    mux2to32 RNorZeroMux(
        .a(32'h80000000),
        .b(rntoMUX),
        .out(Aselect),
        .select((CBFlags[0] | CBFlags[1]))
    );
    mux2to32 RMorRDRTMux(
        .a(rdtoMUX),
        .b(rmtoMUX),
        .out(Bselect),
        .select((CBFlags[0] | CBFlags[1] | decodeSWFlag))
    );
    // mux2to1 decodeMux(
    //     .a(Bselect),
    //     .b(rdtomux),
    //     .out(MUXtoDWB),
    //     .select(decodeImm)
    // );
    mux2to32 SWdisableWrite(
        .a(32'h80000000),
        .b(rdtoMUX),
        .out(MUXtoIDEX),
        .select(decodeSWFlag | (|CBFlags))
    );
    switch4to1 IMMTypeSelector(
        .a(ALUImmtoMUX),
        .b(ShamttoMUX),
        .c(DTAddrtoMUX),
        .d(IWshiftAMTtoMUX),
        .out(IMMtoIDEX),
        .select1(DFlag), 
        .select2(ShiftFlag),
        .select3(IMFlag)
    );
    
    //---- Branching Stage --------------------------------
    mux2to64 chooseBranchAddr(
        .a(BRAddr),
        .b(CondBRAddr),
        .out(BranchAddr),
        .select(BFlag)
    );
    //Multiplication for branching
    multiplier multfour(
        .A(BranchAddr),
        .B(64'h0000000000000004),
        .out(multResult)
    );
    //---- D FLIP-FLOP ID/EX STAGE ------------------------
    //Dselect through ID/EX
    reg32 IDEXD(.d(MUXtoIDEX), .q(IDEXtoEXMEM), .clk(clk));
    //immValue through ID/EX
    reg64 IDEXDImm(.d(IMMtoIDEX), .q(immValue), .clk(clk));
    //immFlag throug ID/EX
    reg1 IDEXImm(.d(decodeImm), .q(Imm), .clk(clk));
    //select through ID/EX
    reg3 IDEXS(.d(decodeS), .q(S), .clk(clk));
    //Cin through ID/EX
    reg1 IDEXCin(.d(decodeCin), .q(Cin), .clk(clk));
    //LWFlag through ID/EX
    reg1 IDEXLW(.d(decodeLWFlag), .q(LWFlag), .clk(clk));
    //SWFlag through ID/EX
    reg1 IDEXSW(.d(decodeSWFlag), .q(SWFlag), .clk(clk));
    //ALUOutFlag through ID/EX
    reg1 IDEXALUFlagOut(.d(decodeALUOutFlag), .q(ALUOutFlag), .clk(clk));
    // //ShiftFlag through ID/EX
    // reg1 IDEXShift(.d(decodeShiftFlag), .q(ShiftFlag), .clk(clk));
    // //DFlag through ID/EX
    // reg1 IDEXDFlag(.d(decodeDFlag), .q(DFlag), .clk(clk));
    // //BFlag through ID/EX
    // reg1 IDEXBFlag(.d(decodeBFlag), .q(BFlag), .clk(clk));
    // //IMFlag through ID/EX
    // reg1 IDEXIMFlag(.d(decodeIMFlag), .q(IMFlag), .clk(clk));
    // //CBFlags through ID/EX
    // reg6 IDEXCBFlags(.d(decodeCBFlags), .q(CBFlags), .clk(clk));

    //---- Dselect FLIP-FLOP CHAIN ------------------------
    //Dselect through EX/MEM
    reg32 EXMEMD(.d(IDEXtoEXMEM), .q(DSELtoMEMWB), .clk(clk));
    //Dselect through MEM/WB
    reg32 MEMWBD(.d(DSELtoMEMWB), .q(Dselect), .clk(clk));
endmodule

//==== D FLIP-FLOPS =======================================
module reg32(
    input [31:0] d,
    output reg [31:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule

module reg64(
    input [63:0] d,
    output reg [63:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule

module reg64reset(
    input [63:0] d,
    input reset,
    output reg [63:0] q,
    input clk      
    );
    always@(posedge clk)
        if(reset)
            q = 64'h0000000000000000;
        else
            q = d;
endmodule

module reg1(
    input d,
    output reg q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule

module reg3(
    input [2:0] d,
    output reg [2:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule

//module reg6(
//    input [5:0] d,
//    output reg [5:0] q,
//    input clk      
//    );
//    always@(posedge clk)
//        q = d;
//endmodule

//==== DECODERS ===========================================
module decode5to32(
    input [4:0] code,
    output reg [31:0] out
    );
    
    always @(code, out) begin
        out = 32'b1 << code;
        end
endmodule

module decodeopcode(
    input [10:0] code,
    output reg Imm,
    output reg [2:0] S,
    //ARM Flags
    output reg ALUOutFlag, ShiftFlag, DFlag, BFlag, IMFlag,
    output reg [5:0] CBFlags,
    //MIPS Flags
    output reg Cin,
    output reg SWFlag, LWFlag
    );
    always @(code, S, Imm, Cin) begin
        //MIPS Flags
        Cin = 1'b0;
        Imm = 1'b0;
        SWFlag = 1'b0;
        LWFlag = 1'b0;
        //ARM Flags
        ALUOutFlag = 1'b0;
        ShiftFlag = 1'b0;
        DFlag = 1'b0;
        BFlag = 1'b0;
        IMFlag = 1'b0;
        CBFlags = 6'b000000;

        case(code[10:5]) 
            6'b001010:
            //R-Format
            begin
                case(code[4:0]) 
                    5'b00000:
                    //ADD
                    begin
                        S = 3'b010;               
                    end 
                    5'b00001:
                    //ADDS
                    begin
                        S = 3'b010; 
                        ALUOutFlag = 1'b1;             
                    end 
                    5'b00010:
                    //AND
                    begin
                        S = 3'b110;                
                    end   
                    5'b00011:
                    //ANDS
                    begin
                        S = 3'b110; 
                        ALUOutFlag = 1'b1;               
                    end 
                    5'b00100:
                    //EOR
                    begin
                        S = 3'b000;                
                    end 
                    5'b00101:
                    //ENOR
                    begin
                        S = 3'b001;                
                    end 
                    5'b00110:
                    //LSL
                    begin
                        S = 3'b101;
                        ShiftFlag = 1'b1;
                        Imm = 1'b1;
                    end 
                    5'b00111:
                    //LSR
                    begin
                        S = 3'b111; 
                        ShiftFlag = 1'b1;
                        Imm = 1'b1;              
                    end 
                    5'b01000:
                    //ORR
                    begin
                        S = 3'b100;                
                    end 
                    5'b01001:
                    //SUB
                    begin
                        S = 3'b011;
                        Cin = 1'b1;           
                    end 
                    5'b01010:
                    //SUBS
                    begin
                        S = 3'b011;
                        Cin = 1'b1;
                        ALUOutFlag = 1'b1;                
                    end 
                endcase            
            end
            
            6'b100010:
            //I-Format
            begin
                Imm = 1'b1;
                case(code[4:1]) 
                    4'b0000:
                    //ADDI
                    begin
                        S = 3'b010;                
                    end 
                    4'b0001:
                    //ADDIS
                    begin
                        S = 3'b010;
                        ALUOutFlag = 1'b1;                
                    end 
                    4'b0010:
                    //ANDI
                    begin
                        S = 3'b110;                
                    end   
                    4'b0011:
                    //ANDIS
                    begin
                        S = 3'b110;
                        ALUOutFlag = 1'b1;                 
                    end 
                    4'b0100:
                    //EORI
                    begin
                        S = 3'b000;                
                    end 
                    4'b0101:
                    //ENORI
                    begin
                        S = 3'b001;                
                    end 
                    4'b0110:
                    //ORRI
                    begin
                        S = 3'b100;                
                    end 
                    4'b0111:
                    //SUBI
                    begin
                        S = 3'b011;   
                        Cin = 1'b1;              
                    end 
                    4'b1000:
                    //SUBIS
                    begin
                        S = 3'b011;
                        Cin = 1'b1; 
                        ALUOutFlag = 1'b1;                 
                    end
                endcase
            end

            6'b110100:
            //D-Format
            begin
                DFlag = 1'b1;
                Imm = 1'b1;
                case(code[4:0]) 
                    5'b00000:
                    //LDUR
                    begin
                        S = 3'b010;
                        LWFlag = 1'b1;                
                    end 
                    5'b00001:
                    //STUR
                    begin
                        S = 3'b010;
                        SWFlag = 1'b1;                
                    end 
                endcase
            end

            6'b110010:
            //IM-Format
            begin
                case(code[4:2]) 
                    3'b101:
                    //LDUR
                    begin
                        S = 3'b101; 
                        IMFlag = 1'b1;  
                        Imm = 1'b1;             
                    end 
                endcase
            end

            6'b000011:
            //B-Format
            begin
                S = 3'b100;
                BFlag = 1'b1;
            end
            
            6'b111101, 6'b011101:
            //CB-Format pt.1
            begin
                case(code[10:3]) 
                    8'b11110100:
                    //CBZ
                    begin
                        S = 3'b011; 
                        CBFlags = 6'b000001;               
                    end 
                    8'b11110101:
                    //CBNZ
                    begin
                        S = 3'b011; 
                        CBFlags = 6'b000010;               
                    end 
                    8'b01110100:
                    //BEQ
                    begin
                        S = 3'b011; 
                        CBFlags = 6'b000100;               
                    end 
                    8'b01110101:
                    //BNE
                    begin
                        S = 3'b011; 
                        CBFlags = 6'b001000;               
                    end 
                    8'b01110110:
                    //BLT
                    begin
                        S = 3'b011; 
                        CBFlags = 6'b010000;               
                    end 
                    8'b01110111:
                    //BGE
                    begin
                        S = 3'b011;
                        CBFlags = 6'b100000;                
                    end 
                    
                endcase
            end
            
            default:
                begin
                S = 3'b000;
                end
        endcase    
    end
endmodule

//==== EXTENDS ============================================
module zeroextend12to64(
    input [11:0] in,
    output [63:0] extend
    );
    
    assign extend = {{32'd52{1'b0}}, in};  
endmodule

module zeroextend6to64(
    input [5:0] in,
    output [63:0] extend
    );
    
    assign extend = {{32'd58{1'b0}}, in};  
endmodule

module zeroextend2to64(
    input [1:0] in,
    output [63:0] extend
    );

    assign extend = {{32'd62{1'b0}}, in}; 
endmodule

module signextend9to64(
    input [8:0] in,
    output [63:0] extend
    );
    
    assign extend = {{32'd55{in[8]}}, in};  
endmodule

module zeroextend16to64(
    input [15:0] in,
    output [63:0] extend
    );
    
    assign extend = {{32'd48{1'b0}}, in};  
endmodule

module signextend26to64(
    input [25:0] in,
    output [63:0] extend
    );
    
    assign extend = {{32'd38{in[25]}}, in};  
endmodule

module signextend19to64(
    input [18:0] in,
    output [63:0] extend
    );
    
    assign extend = {{32'd45{in[18]}}, in};  
endmodule

//==== MUX MODULES ========================================
module mux2to32(
    input [31:0] a,
    input [31:0] b,
    output [31:0] out,
    input select
    );
    
    assign out = select ? a : b;
endmodule

module mux2to64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] out,
    input select
    );
    
    assign out = select ? a : b;
endmodule

module switch4to1(
    input [63:0] a,
    input [63:0] b,
    input [63:0] c,
    input [63:0] d,
    output reg [63:0] out,
    input select1, select2, select3
    );
    
    always @ (a, b, c, d, out, select1, select2, select3) begin
        case({select1, select2, select3}) 
            3'b001:
            begin
                out = d;
            end
            3'b010:
            begin
                out = b;
            end
            3'b100:
            begin
                out = c;
            end
            default:
            begin
                out = a;
            end
        endcase
    end
endmodule

module branchEQ (
    input [63:0] A, 
    input [63:0] B,
    input BEQInstr, 
    input BNEInstr,
    output branchTrue
    );
    assign branchTrue = (BEQInstr===1'b1 && A===B) || (BNEInstr===1'b1 && A!==B);
    
endmodule

module regalu(
    input [31:0] Aselect,
    input [31:0] Bselect,
    input [31:0] Dselect,
    input [63:0] ImmVal,
    input Imm,
    input clk,
    output [63:0] abus,
    output [63:0] bbus,
    output [63:0] dbus,
    input [2:0] S,
    input Cin,
    input LWFlag, SWFlag,
    input [63:0] MOVImm,
    // input BEQFlag, BNEFlag,
    // input SLTFlag, SLEFlag,
    inout [63:0] databus,
    output [63:0] daddrbus,
    output branchTrue,
    output takeCondBranch,
    input ALUOutFlag, BFlag, IMFlag,
    input [5:0] CBFlags
    );
    wire [63:0] REGatoMUX, REGbtoMUX, REGatoIDEX, RegbtoIDEX;
    regfile32x32 regfile(
        .dselect(Dselect),
        .aselect(Aselect),
        .bselect(Bselect),
        .dbus(dbus),
        .clk(clk),
        .abus(REGatoMUX),
        .bbus(RegbtoIDEX)
    );
    
    branchEQ branchLogic(
        .A(REGatoMUX), 
        .B(RegbtoIDEX),
        .BEQInstr(CBFlags[0]), 
        .BNEInstr(CBFlags[1]),
        .branchTrue(branchTrue)
    );

    mux2to64 AoutorMOVImm(
        .a(MOVImm),
        .b(REGatoMUX),
        .out(REGatoIDEX),
        .select(IMFlag)
    );
/*    mux2to1 AoutorMOVImm( //talk about where we want to do this!
        .a(instruction[22:21]*16?),
        .b(REGbtoMUX),
        .out(REGbtoIDEX),
        .select(IMMFlag)
    );*/
    
    
    alupipe alu(
        .S(S),
        .abus(REGatoIDEX),
        .bbus(RegbtoIDEX),
        .ImmVal(ImmVal),
        .Imm(Imm),
        .clk(clk),
        .Cin(Cin),
        .dbus(dbus),
        .abusout(abus),
        .bbusout(bbus),
        .LWFlag(LWFlag),
        .SWFlag(SWFlag),
//        .SLTFlag(SLTFlag),
//        .SLEFlag(SLEFlag),
        .CBFlags(CBFlags),
        .databus(databus),
        .daddrbus(daddrbus),
        .takeCondBranch(takeCondBranch),
        .ALUOutFlag(ALUOutFlag)  
        );
endmodule

module regfile32x32(
    input [31:0] dselect,
    input [31:0] aselect,
    input [31:0] bselect,
    input [63:0] dbus,
    input clk,
    output [63:0] abus,
    output [63:0] bbus
    );
    
    reg64negative registers[30:0](
    .d(dbus),
    .abus(abus),
    .bbus(bbus),
    .clk(clk),
    .dselect(dselect[30:0]),
    .aselect(aselect[30:0]),
    .bselect(bselect[30:0])
    );
    
    assign abus = aselect[31]==1'b1 ? 64'b0 : 64'bz;
    assign bbus = bselect[31]==1'b1 ? 64'b0 : 64'bz;
endmodule

module reg64negative(
    input [63:0] d,
    output [63:0] abus,
    output [63:0] bbus,
    input aselect,
    input bselect,
    input clk,
    input dselect   
    );
    reg [63:0] q;
    wire newclk;
    always@(negedge clk)
        if (dselect==1'b1) q = d;
    
    assign abus = aselect ? q : 64'bz;
    assign bbus = bselect ? q : 64'bz;
endmodule

module condBranchLogic(
    input [5:0] CBFlags,
    input C, V, Z, N,
    input clk, 
    input enable,
    output reg branch
    );
    always @(CBFlags, C, V, Z, N, branch, enable) begin
        case(enable)
            1'b1:
            begin
                case(CBFlags)
                    6'b000100:
                    //EQ
                        begin
                            branch = Z ? 1'b1 : 1'b0;
                        end
                    6'b001000:
                    //NEQ
                        begin
                            branch = ~Z ? 1'b1 : 1'b0;
                        end
                    6'b010000:
                    //LT
                        begin
                            branch = (N !== V) ? 1'b1: 1'b0;
                        end
                    6'b100000:
                    //GE
                        begin
                            branch = (N === V) === 1'b1 ? 1'b1 : 1'b0;
                        end
                        
                    default:
                    begin
                        branch = 1'b0;
                    end
                endcase
            end
            1'b0:
            begin
                branch = 1'b0;
            end
            default:
            begin
                branch = 1'b0;
            end
        endcase
    end

endmodule

module alupipe(
    input [2:0] S,
    input [63:0] abus,
    input [63:0] bbus,
    input [63:0] ImmVal,
    input Imm,
    input clk,
    input Cin,
    input LWFlag, SWFlag,
//    input SLEFlag, SLTFlag,
    input [5:0] CBFlags,
    output [63:0] dbus,
    output [63:0] abusout,
    output [63:0] bbusout,
    inout [63:0] databus,
    output [63:0] daddrbus,
    output takeCondBranch,
    input ALUOutFlag
    );

    wire [63:0] AtoALU, BtoMUX, SettoD, IMMtoMUX, MUXtoALU, databustoMUX, DADDRtoMUX, databusOUTtoMUX, databusAssign;
    wire [63:0] ALUtoD;

    wire LWALU, SWALU, LWdb, SWdb, LWout, SWout;
    wire Cw, Vw, Zw, Nw;
    // wire SLEout, SLTout;
    
    //---- IDEX FOR REG FILE OUTPUTS-----------------------
    //abus into IDEX out to abusout -> alu
    reg64 A(.d(abus), .clk(clk), .q(abusout));
    //bbus into IDEX out to BtoMUX -> mux
    reg64 B(.d(bbus), .clk(clk), .q(BtoMUX));

    // //LWFlag into IDEX and out to LWALU
    // reg1 LWin(.d(LWFlag), .clk(clk), .q(LWALU)); 
    // //SWFlag into IDEX and out to SWALU
    // reg1 SWin(.d(SWFlag), .clk(clk), .q(SWALU));

    //---- Execute Stage Interior -------------------------
    //Immediate value and B into MUX, selected by imm (IMMFlag), out to bbusout -> alu
    mux2to64 IMMorBselect(
        .a(ImmVal),
        .b(BtoMUX),
        .out(bbusout),
        .select(Imm)
    );
    
    //
    alu64 alu(
        .d(ALUtoD), 
        .C(C), 
        .V(V), 
        .Z(Z),
        .N(N),
        .a(abusout),
        .b(bbusout),
        .Cin(Cin), 
        .S(S)
     );

    // FoursignalEnable ALUFlagsEnable(
    //     .a(Cw),
    //     .b(Vw),
    //     .c(Zw),
    //     .d(Nw),
    //     .enable(ALUOutFlag),
    //     .aout(C),
    //     .bout(V),
    //     .cout(Z),
    //     .dout(N)
    // );

    condBranchLogic condBranchLogicmodule(
        .CBFlags(CBFlags),
        .C(C),
        .V(V),
        .Z(Z),
        .N(N),
        .branch(takeCondBranch),
        .enable(ALUOutFlag)
    );
    
    // reg1 SLEin(.d(SLEFlag), .clk(clk), .q(SLEout)); 
    // reg1 SLTin(.d(SLTFlag), .clk(clk), .q(SLTout));    
        
    reg64 DADDRin(
        .d(ALUtoD), 
        .clk(clk), 
        .q(daddrbus)
    );
    reg64 databusin(
        .d(BtoMUX), 
        .clk(clk), 
        .q(databustoMUX)
    );
    reg1 SWoutALU(
        .d(SWFlag), 
        .clk(clk), 
        .q(SWdb)
    );
    reg1 LWoutALU(
        .d(LWFlag), 
        .clk(clk), 
        .q(LWdb)
    );
    
    assign databus = SWdb ? databustoMUX : 64'bz;
    //assign databus = databustoMUX;
    
    reg64 DADDROUT(
        .d(daddrbus), 
        .clk(clk), 
        .q(DADDRtoMUX)
    );
    reg64 databusOUT(
        .d(databus), 
        .clk(clk), 
        .q(databusOUTtoMUX)
    );

    reg1 LWoutReg(
        .d(LWdb), 
        .clk(clk), 
        .q(LWout)
    );  
    mux2to64 dbusOUT(
        .a(databusOUTtoMUX),
        .b(DADDRtoMUX),
        .out(dbus),
        .select(LWout)
    );
endmodule

module FoursignalEnable (
    input a, b, c, d,
    input enable,
    output reg aout, bout, cout, dout
    );

    always @ (a, b, c, d, enable, aout, bout, cout, dout)
    begin
        case(enable)
            1'b0:
            begin
                aout = 1'b0;
                bout = 1'b0;
                cout = 1'b0;
                dout = 1'b0;
            end
            1'b1:
            begin
                aout = a;
                bout = b;
                cout = c;
                dout = d;
            end
            default:
            begin
                aout = 1'b0;
                bout = 1'b0;
                cout = 1'b0;
                dout = 1'b0;
            end
        endcase
    end
endmodule

module shiftModule(
    input [2:0] S,
    input [63:0] a, shamt, d,
    output reg [63:0] out
    );
    
    always @(S, a, shamt, d, out) begin
        case(S)
            3'b101:
                out = a << shamt;
            3'b111:
                out = a >> shamt;
            default:
                out = d;
        endcase
    end
endmodule

//==== 64-BIT ALU =========================================
module alu64 (d, C, V, N, a, b, Cin, S, Z);
   output [63:0] d;
   output C, V, Z, N;
   input [63:0] a, b;
   input Cin;
   input [2:0] S;
   
   wire [63:0] c, g, p;
   wire gout, pout;
   wire [63:0] ALUd;
   
   //Alu cells for each bit
   alu_cell alucell[63:0] (
      .d(ALUd),
      .g(g),
      .p(p),
      .a(a),
      .b(b),
      .c(c),
      .S(S)
   );
   
   //LAC Tree
   lac6 laclevel6(
      .c(c),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(g),
      .p(p)
   );
   
    shiftModule shiftLogic(
        .S(S),
        .a(a),
        .shamt(b),
        .d(ALUd),
        .out(d)
    );

   //Flag Calculations
   assign C = gout | (pout & Cin); //Carry-out flag
   assign V = C ^ c[63]; //Overflow flag
   assign Z = !(|d); // Zero flag
   assign N = d[63] ; //Negative flag
endmodule

//==== ALU CELL =======================
module alu_cell (d, g, p, a, b, c, S);
    output reg d;
    output g, p;
    input a, b, c;
    input [2:0] S;
    
    wire cint, bint;

    assign bint = (~S[2] & S[0]) ^ b;
    assign g=a&bint;
    assign p=a^bint;
    assign cint = (~S[2] & S[1]) & c;
    
    //case statements for functions, according to the assignment doc
    always @ (d, p, cint, a, b, S) 
        case(S)
            3'b000, 3'b001, 3'b010, 3'b011:
                d = p ^ cint;    
            3'b100: //OR
                d = a|b;
            3'b101: //Logical Shift Left
                d = a << b;
            3'b110: //AND
                d = a & b;
            3'b111: //Logical Shift Right
                d = a >> b;
        endcase
    
endmodule

//==== LAC TREES ======================
module lac(c, gout, pout, Cin, g, p);
    // base LAC, given in class slides
    output [1:0] c;
    output gout, pout;
    input Cin;
    input [1:0] g, p;
    
    assign c[0] = Cin;
    assign c[1] = g[0] | (p[0]&Cin);
    assign gout = g[1]|(p[1]&g[0]);
    assign pout = p[1]&p[0];
endmodule

module lac2(c, gout, pout, Cin, g, p);
    output [3:0] c;
    output gout, pout;
    input Cin;
    input [3:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac leaf0(
        .c(c[1:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[1:0]),
        .p(p[1:0])
    );
    
    lac leaf1(
        .c(c[3:2]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[3:2]),
        .p(p[3:2])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule   

module lac3(c, gout, pout, Cin, g, p);
    output [7:0] c;
    output gout, pout;
    input Cin;
    input [7:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac2 leaf0(
        .c(c[3:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[3:0]),
        .p(p[3:0])
    );
    
    lac2 leaf1(
        .c(c[7:4]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[7:4]),
        .p(p[7:4])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac4(c, gout, pout, Cin, g, p);
    output [15:0] c;
    output gout, pout;
    input Cin;
    input [15:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac3 leaf0(
        .c(c[7:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[7:0]),
        .p(p[7:0])
    );
    
    lac3 leaf1(
        .c(c[15:8]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[15:8]),
        .p(p[15:8])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac5(c, gout, pout, Cin, g, p);
    //top-level LAC tree
    output [31:0] c;
    output gout, pout;
    input Cin;
    input [31:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac4 leaf0(
        .c(c[15:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[15:0]),
        .p(p[15:0])
    );
    
    lac4 leaf1(
        .c(c[31:16]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[31:16]),
        .p(p[31:16])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac6(c, gout, pout, Cin, g, p);
    //top-level LAC tree
    output [63:0] c;
    output gout, pout;
    input Cin;
    input [63:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac5 leaf0(
        .c(c[31:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[31:0]),
        .p(p[31:0])
    );
    
    lac5 leaf1(
        .c(c[63:32]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[63:32]),
        .p(p[63:32])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule