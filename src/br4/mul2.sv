module mul2 (
    input  logic         a_signed_i,
    input  logic         b_signed_i,
    input  logic [  3:0] m_i,
    input  logic [ 63:0] a_i,
    input  logic [ 63:0] b_i,
    output logic [127:0] p_o
);
  // 32 b mul
  logic [31:0]  a_0;
  logic [31:0]  a_1;
  logic [31:0]  a_2;
  logic [31:0]  a_3;
  logic [31:0]  b_0;
  logic [31:0]  b_1;
  logic [31:0]  b_2;
  logic [31:0]  b_3;
  logic [63:0]  p_0;
  logic [63:0]  p_1;
  logic [63:0]  p_2;
  logic [63:0]  p_3;
  // csa
  logic [127:0] x_0;
  logic [127:0] x_1;
  logic [127:0] x_2;
  logic [127:0] x_3;
  // mask
  logic [127:0] m;

  always @(*) begin
    m = -1;
    for (int k = 1; k < 4; k += 1) for (int i = 8 << k; i < 128; i += (8 << k)) m[i] &= ~m_i[k-1];
  end

  // mode
  logic [2:0] m_l;
  logic       m_h;

  assign m_h = m_i[3];
  assign m_l = {m_i[3] | m_i[2], m_i[1], m_i[0]};

  // sign
  logic       n_a;
  logic       n_a_0 ;
  logic       n_a_1 ;
  logic       n_a_2 ;
  logic       n_a_3 ;

  logic       n_b;
  logic       n_b_0 ;
  logic       n_b_1 ;
  logic       n_b_2 ;
  logic       n_b_3 ;

  assign n_a = a_signed_i;
  assign n_b = b_signed_i;

  assign a_0 = a_i[31:0];
  assign b_0 = b_i[31:0];
  assign a_1 = {32{m_h}} & a_i[63:32];
  assign b_1 = {32{m_h}} & b_i[31:0];
  assign a_2 = {32{m_h}} & a_i[31:0];
  assign b_2 = {32{m_h}} & b_i[63:32];
  assign a_3 = a_i[63:32];
  assign b_3 = b_i[63:32];

  assign n_a_0 = n_a & |m_i[2:0] ;
  assign n_a_1 = n_a;
  assign n_a_2 = n_a & |m_i[2:0] ;
  assign n_a_3 = n_a;

  assign n_b_0 = n_b & |m_i[2:0] ;
  assign n_b_1 = n_b & |m_i[2:0] ;
  assign n_b_2 = n_b;
  assign n_b_3 = n_b;

  // mul i_mul_32_0 (.a_signed_i(n_a_0), .b_signed_i(n_b_0), .m_i(m_l), .a_i(a_0), .b_i(b_0), .p_o(p_0));
  // mul i_mul_32_1 (.a_signed_i(n_a_1), .b_signed_i(n_b_1), .m_i(m_l), .a_i(a_1), .b_i(b_1), .p_o(p_1));
  // mul i_mul_32_2 (.a_signed_i(n_a_2), .b_signed_i(n_b_2), .m_i(m_l), .a_i(a_2), .b_i(b_2), .p_o(p_2));
  // mul i_mul_32_3 (.a_signed_i(n_a_3), .b_signed_i(n_b_3), .m_i(m_l), .a_i(a_3), .b_i(b_3), .p_o(p_3));

  // 64 b mode

  // TODO unsigned booth

  assign p_0 = $signed({n_a_0 & a_0[31], a_0}) * $signed({n_b_0 & b_0[31], b_0});
  assign p_1 = $signed({n_a_1 & a_1[31], a_1}) * $signed({n_b_1 & b_1[31], b_1});
  assign p_2 = $signed({n_a_2 & a_2[31], a_2}) * $signed({n_b_2 & b_2[31], b_2});
  assign p_3 = $signed({n_a_3 & a_3[31], a_3}) * $signed({n_b_3 & b_3[31], b_3});

  logic s_1;
  logic s_2;

  // NOTE guard for switching activity?

  // assign s_1 = p_1[63];
  // assign s_2 = p_2[63];

  assign s_1 = m_h & n_a & p_1[63];
  assign s_2 = m_h & n_b & p_2[63];

  assign x_0 = {{64{1'b0}}, p_0};
  assign x_1 = {{32{s_1}}, p_1, {32{1'b0}}};
  assign x_2 = {{32{s_2}}, p_2, {32{1'b0}}};
  assign x_3 = {p_3, {64{1'b0}}};

  logic [3:0][127:0] x;
  logic [1:0][127:0] y;

  logic [127:0] s;
  logic [127:0] c;

  assign x[0] = x_0;
  assign x[1] = x_1;
  assign x[2] = x_2;
  assign x[3] = x_3;

  csa #(.K(4), .W(128)) i_csa (.k_i(m), .p_i(x), .p_o(y));

  assign s  = y[0];
  assign c  = (y[1] << 1) & m;

  cpa #(.W(128)) i_cpa (.k_i(m), .a_i(s), .b_i(c), .s_o(p_o));

endmodule
