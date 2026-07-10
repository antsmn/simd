module fa (
    input  logic a_i,
    input  logic b_i,
    input  logic c_i,
    output logic s_o,
    output logic c_o
);
  wire A;
  wire B;
  wire C;
  wire X;
  wire Y;
  \$fa #(.WIDTH(1)) U (.A, .B, .C, .X, .Y);
  assign A = a_i;
  assign B = b_i;
  assign C = c_i;
  assign c_o = X;
  assign s_o = Y;
endmodule
(*blackbox*)
module \$fa #(parameter WIDTH = 1)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [WIDTH-1:0] C,
    output [WIDTH-1:0] X,
    output [WIDTH-1:0] Y
);
    assign X = (A & B) | (B & C) | (A & C);
    assign Y = A ^ B ^ C;

endmodule
