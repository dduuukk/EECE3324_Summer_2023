//Christian Bender and Joe Perkins
`timescale 1ns / 1ps

module alupipe(
    input [2:0] S,
    input [31:0] abus,
    input [31:0] bbus,
    input clk,
    input Cin,
    output [31:0] dbus
    );
    
    wire [31:0] AtoALU, BtoALU, ALUtoD;
    
    reg32 A(.d(abus), 
            .clk(clk), 
            .q(AtoALU));
    reg32 B(.d(bbus), 
            .clk(clk), 
            .q(BtoALU));
    
    alu32 alu(.d(ALUtoD), 
              .Cout(), 
              .V(), 
              .a(AtoALU), 
              .b(BtoALU), 
              .Cin(Cin), 
              .S(S));
              
    reg32 D(.d(ALUtoD), 
            .clk(clk), 
            .q(dbus));
endmodule

module alu32 (d, Cout, V, a, b, Cin, S);
   output[31:0] d;
   output Cout, V;
   input [31:0] a, b;
   input Cin;
   input [2:0] S;
   
   wire [31:0] c, g, p;
   wire gout, pout;
   
   //alu cells for each bit
   alu_cell alucell[31:0] (
      .d(d),
      .g(g),
      .p(p),
      .a(a),
      .b(b),
      .c(c),
      .S(S)
   );
   
   //LAC tree
   lac5 laclevel5(
      .c(c),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(g),
      .p(p)
   );

   //overflow calculation 
   assign Cout = gout | (pout & Cin);
   assign V = Cout ^ c[31];
  
endmodule


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
    always@(d,p,cint,a,b,S) 
        case (S)
            3'b000, 3'b001, 3'b010, 3'b011:
                d = p ^ cint;
                
            3'b100:
                d = a|b;
                
            3'b101:
                d = ~(a | b);
            3'b110:
                d = a & b;
            3'b111:
                d = 1'b0;
    endcase
endmodule

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

module reg32(
    input [31:0] d,
    output reg [31:0] q,
    input clk      
    );
    always@(posedge clk)
        q = d;
endmodule