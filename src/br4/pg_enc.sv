module pg_enc (
    input  logic [ 2:0]       m_i,
    input  logic              a_signed_i,
    input  logic              b_signed_i,
    input  logic [32:0]       b_src_0,
    input  logic [32:0]       b_src_1,
    input  logic [32:0]       b_src_2,
    input  logic [32:0]       b_src_3,
    input  logic [32:0]       a_mask_0,
    input  logic [32:0]       a_mask_1,
    input  logic [32:0]       a_mask_2,
    input  logic [32:0]       a_mask_3,
    input  logic [32:0]       a1_i_0,
    input  logic [32:0]       a1_i_1,
    input  logic [32:0]       a1_i_2,
    input  logic [32:0]       a1_i_3,
    input  logic [32:0]       a2_i_0,
    input  logic [32:0]       a2_i_1,
    input  logic [32:0]       a2_i_2,
    input  logic [32:0]       a2_i_3,
    output logic [15:0]       e,
    output logic [15:0]       n,
    output logic [15:0][32:0] p
);
  // logic [47:0]      x;
  logic [15:0][2:0] x;
  logic [15:0]      s;

  genvar i;

  // sel booth enc src for each partition (each partition is masked according to mode)

  for (i = 0; i < 4; i += 1) begin
    assign x[i] = b_src_0[2*i+:3];
  end
  for (i = 4; i < 8; i += 1) begin
    assign x[i] = b_src_1[2*i+:3];
  end
  for (i = 8; i < 12; i += 1) begin
    assign x[i] = b_src_2[2*i+:3];
  end
  for (i = 12; i < 16; i += 1) begin
    assign x[i] = b_src_3[2*i+:3];
  end

  for (i = 0; i < 4; i += 1) begin
    be #(.W(33)) i_be (.mask_i(a_mask_0), .a1_i(a1_i_0), .a2_i(a2_i_0), .x_i(x[i]), .p_o(p[i]), .n_o(n[i]));
  end
  for (i = 4; i < 8; i += 1) begin
    be #(.W(33)) i_be (.mask_i(a_mask_1), .a1_i(a1_i_1), .a2_i(a2_i_1), .x_i(x[i]), .p_o(p[i]), .n_o(n[i]));
  end
  for (i = 8; i < 12; i += 1) begin
    be #(.W(33)) i_be (.mask_i(a_mask_2), .a1_i(a1_i_2), .a2_i(a2_i_2), .x_i(x[i]), .p_o(p[i]), .n_o(n[i]));
  end
  for (i = 12; i < 16; i += 1) begin
    be #(.W(33)) i_be (.mask_i(a_mask_3), .a1_i(a1_i_3), .a2_i(a2_i_3), .x_i(x[i]), .p_o(p[i]), .n_o(n[i]));
  end

  // sel msb for each mode, for each partition

  for (i = 0; i < 4; i += 1) begin
    assign s[i] = (m_i[0] & p[i][ 8]) | (m_i[1] & p[i][16]) | (m_i[2] & p[i][32]);
  end
  for (i = 4; i < 8; i += 1) begin
    assign s[i] = (m_i[0] & p[i][16]) | (m_i[1] & p[i][16]) | (m_i[2] & p[i][32]);
  end
  for (i = 8; i < 12; i += 1) begin
    assign s[i] = (m_i[0] & p[i][24]) | (m_i[1] & p[i][32]) | (m_i[2] & p[i][32]);
  end
  for (i = 12; i < 16; i += 1) begin
    assign s[i] = (p[i][32]);
  end

  // signed or unsigned op se

  for (i = 0; i < 16; i += 1) begin
    assign e[i] = a_signed_i ? s[i] : n[i];
  end

endmodule
