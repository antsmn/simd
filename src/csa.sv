module csa #(
    parameter K = 32,
    parameter W = 64
) (
    input  logic [W-1:0]        k_i,
    input  logic [K-1:0][W-1:0] p_i,
    output logic [  1:0][W-1:0] p_o
);
  logic [W:0][K-4:0] c;

  assign c[0] = '0;

  for (genvar i = 0; i < W; i += 1) begin  // : column
    if (K == 3) begin
      fa i_fa (.a_i(p_i[0][i]), .b_i(p_i[1][i]), .c_i(p_i[2][i]), .c_o(p_o[1][i]), .s_o(p_o[0][i]));
    end else begin
      logic [K-4:0] c_k;

      logic [K-1:0] a;
      logic [  1:0] p;

      assign c_k = c[i] & {(K - 3) {k_i[i]}};

      for (genvar k = 0; k < K; k += 1) begin

        assign a[k] = p_i[k][i];

      end

      compressor #(K) i_compressor (
          .a_i(a),
          .c_i(c_k),
          .c_o(c[i+1]),
          .s_o(p)
      );
      assign p_o[0][i] = p[0];
      assign p_o[1][i] = p[1];
    end
  end

endmodule
