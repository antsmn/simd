module mul
  import pg_pkg::*;
(
    input  logic           a_signed_i,
    input  logic           b_signed_i,
    input  logic [  K-1:0] m_i,
    input  logic [  W-1:0] a_i,
    input  logic [  W-1:0] b_i,
    output logic [2*W-1:0] p_o
);
  localparam LK = 2 + W;
  localparam LW = 2 * W;

  logic [LK-1:0][LW-1:0] p_1;
  logic [   1:0][LW-1:0] p_2;
  logic [LW-1:0]         p_3;
  logic [LW-1:0]         p_4;
  logic [LW-1:0]         k;

  pg i_pg (.*, .p_o(p_1));

  always @(*) begin
    m = -1;
    for (int k = 1; k < K; k += 1) for (int i = E << k; i < LW; i += (E << k)) m[i] &= ~m_i[k-1];
  end

  csa #(.K(LK), .W(LW)) i_csa (.k_i(k), .p_i(p_1), .p_o(p_2));
  cpa #(.W(LW)) i_cpa (.k_i(k), .a_i(p_3), .b_i(p_4), .s_o(p_o));

  assign p_3 = p_2[0];
  assign p_4 = (p_2[1] << 1) & k;

endmodule
