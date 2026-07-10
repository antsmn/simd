module mul (
    input  logic        a_signed_i,
    input  logic        b_signed_i,
    input  logic [ 2:0] m_i,
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    output logic [63:0] p_o
);
  logic [18:0][63:0] p_1;
  logic [ 1:0][63:0] p_2;
  logic [63:0]       p_3;
  logic [63:0]       p_4;
  logic [63:0]       m;

  pg i_pg (.*, .p_o(p_1));

  always @(*) begin
    m = -1;
    for (int k = 1; k < 3; k += 1) for (int i = 8 << k; i < 64; i += (8 << k)) m[i] &= ~m_i[k-1];
  end

  csa #(.K(19), .W(64)) i_csa (.k_i(m), .p_i(p_1), .p_o(p_2));
  cpa #(.W(64)) i_cpa (.k_i(m), .a_i(p_3), .b_i(p_4), .s_o(p_o));

  assign p_3 = p_2[0];
  assign p_4 = (p_2[1] << 1) & m;

endmodule
