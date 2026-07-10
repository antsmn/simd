module cpa #(
    parameter W
) (
    input  logic [W-1:0] k_i,
    input  logic [W-1:0] a_i,
    input  logic [W-1:0] b_i,
    output logic [W-1:0] s_o
);
  localparam n_l = $clog2(W);
  localparam n = 1 << n_l;

  logic [n-1:0] n_0;
  logic [n-1:0] p_0;
  logic [n-1:0] g_0;
  logic [n-1:0] n_1;
  logic [n-1:0] g_1;

  always @(*) begin
    int i;
    int k;

    p_0 = a_i ^ b_i;
    g_0 = a_i & b_i;
    n_0 = a_i | b_i;
    g_1 = g_0;
    n_1 = n_0 & k_i;  // mask

    for (i = 0; i < n_l; i += 1) begin
      for (k = n - 1; k > 2 ** i - 1; k -= 2) begin
        if (k < W) begin
          g_1[k] = g_1[k] | n_1[k] & g_1[k-2**i];
          n_1[k] = n_1[k] & n_1[k-2**i];
        end
      end
    end
    for (k = 2; k < W; k += 2) begin
      g_1[k] = g_1[k] | n_1[k] & g_1[k-1];
      n_1[k] = n_1[k] & n_1[k-1];
    end
  end
  assign s_o = p_0 ^ ((g_1 << 1) & k_i);  // mask

endmodule
