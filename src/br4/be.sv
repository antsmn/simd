module be #(
    parameter W = 8
) (
    input  logic [W-1:0] mask_i,
    input  logic [W-1:0] a1_i,
    input  logic [W-1:0] a2_i,
    input  logic [  2:0] x_i,
    output logic [W-1:0] p_o,
    output logic         n_o
);
  logic         x1;
  logic         x2;
  logic         xn;
  logic [W-1:0] a1;
  logic [W-1:0] a2;

  wire [1:0]    x2_1 = x_i[2:1];
  wire [1:0]    x1_0 = x_i[1:0];

  assign x1  =  (^x1_0);
  assign x2  = ~(^x1_0 | ~(^x2_1));
  assign xn  = ~(&x1_0) & x_i[2];

  assign a1  = a1_i ^ (mask_i & ({W{xn}}));
  assign a2  = a2_i ^ (mask_i & ({W{xn}}));

  assign p_o = (a1 & ({W{x1}})) | (a2 & ({W{x2}})) ;
  assign n_o = xn;

endmodule
