module pg import pg_pkg::*;
(
    input  logic                    a_signed_i,
    input  logic                    b_signed_i,
    input  logic [  K-1:0]          m_i,
    input  logic [  W-1:0]          a_i,
    input  logic [  W-1:0]          b_i,
    output logic [2+W-1:0][2*W-1:0] p_o
);

  logic [L-1:0][L-1:0] n_v[0:K-1];
  logic [L-1:0][L-1:0] n;

  always @(*) begin
    n = '0;
    for (int i = 0; i < L; i += 1) begin
      for (int k = 0; k < K; k += 1) begin

        n[i] = n[i] | n_v[k][i>>k];
      end
    end
  end
  // for each plane generate subtree and for each subtree set onehot vector (leaf node bit set)
  // bit set for each valid sign byte in src
  for (genvar k = 0; k < K; k += 1) begin
    localparam F = 1 << k;

    for (genvar i = 0; i < L; i += 1) begin

      assign n_v[k][i] = (L'(m_i[k])) << ((i * F) + F - 1);
    end
  end
  // n_v planes
  // mode 0
  //   a
  // b 0 1 2 3
  // 0 1
  // 1   1
  // 2     1
  // 3       1
  // mode 1
  //   a
  // b 0 1 2 3
  // 0   1
  // 1
  // 2       1
  // 3
  // mode 2
  //   a
  // b 0 1 2 3
  // 0       1
  // 1
  // 2
  // 3
  // n = | n_v planes and broadcast leaves
  // mode 0
  //   a
  // b 0 1 2 3
  // 0 1
  // 1   1
  // 2     1
  // 3       1
  // mode 1
  //   a
  // b 0 1 2 3
  // 0   1
  // 1   1
  // 2       1
  // 3       1
  // mode 2
  //   a
  // b 0 1 2 3
  // 0       1
  // 1       1
  // 2       1
  // 3       1

  // n_b = n_a transpose is same n array indexed column first
  // mode 0
  //   a
  // b 0 1 2 3
  // 0 1
  // 1   1
  // 2     1
  // 3       1
  // mode 1
  //   a
  // b 0 1 2 3
  // 0
  // 1 1 1
  // 2
  // 3     1 1
  // mode 2
  //   a
  // b 0 1 2 3
  // 0
  // 1
  // 2
  // 3 1 1 1 1

  logic [L-1:0][L-1:0] n_a;
  logic [L-1:0][L-1:0] n_b;

  assign n_a = n & {(1 << L) {a_signed_i}};
  assign n_b = n & {(1 << L) {b_signed_i}};

  // mask src
  logic [L-1:0][W-1:0] a_mask_v[0:K-1];
  logic [L-1:0][W-1:0] a_mask;

  always @(*) begin
    a_mask = '0;
    for (int i = 0; i < L; i += 1) begin
      for (int k = 0; k < K; k += 1) begin

        a_mask[i] = a_mask[i] | a_mask_v[k][i>>k];
      end
    end
  end
  for (genvar k = 0; k < K; k += 1) begin
    localparam F = E << k;

    for (genvar i = 0; i < L; i += 1) begin

      assign a_mask_v[k][i] = W'({F{m_i[k]}}) << (i * F);
    end
  end
  logic [L-1:0][W-1:0] a;

  for (genvar i = 0; i < L; i += 1) begin

    assign a[i] = a_i & a_mask[i];

  end

  logic [2+W-1:0][2*W-1:0] p_1;
  logic [2+W-1:0][2*W-1:0] p_2;

  logic [K-1:0] a_signed_mode;
  logic [K-1:0] b_signed_mode;
  logic [K-1:0] p_signed_mode;

  assign a_signed_mode = a_signed_i & m_i;
  assign b_signed_mode = b_signed_i & m_i;
  assign p_signed_mode = a_signed_mode | b_signed_mode;

  always @(*) begin
    // align partial products
    p_1 = 0;
    for (int i = 0; i < W; i += E) begin
      for (int k = 0; k < E; k += 1) begin

        p_1[i+k] = (a[i/E] & {W{b_i[i+k]}}) << (i + k);
      end
    end
    // mask neg sign bit a
    p_2 = p_1;
    for (int i = 0; i < W; i += E) begin
      for (int j = 0; j < W; j += E) begin
        for (int k = 0; k < E; k += 1) begin

          p_2[i+k][i+j+(E-1)+k] ^= n_a[i/E][j/E];

        end
      end
    end
    // mask neg sign bit b
    for (int i = 0; i < W; i += E) begin
      for (int j = 0; j < W; j += E) begin
        for (int k = 0; k < E; k += 1) begin

          p_2[i+(E-1)][i+j+(E-1)+k] ^= n_b[j/E][i/E];

        end
      end
    end
    for (int k = 0; k < K; k += 1) begin
      // localparam F = E << k;
      for (int i = (E << k) - 1; i < 2 * W; i += ((E << k) << 1)) begin

        p_2[1+W-1][i] |= a_signed_mode[k];
        p_2[2+W-1][i] |= b_signed_mode[k];

      end
      for (int i = ((E << k) << 1) - 1; i < 2 * W; i += ((E << k) << 1)) begin

        p_2[2+W-1][i] |= p_signed_mode[k];
      end
    end
  end
  assign p_o = p_2;

  // assert for each i a_mask_v[i] [F-1] == n_v[i] [F/E], F = E << k for a_mask, F = 1 << k for n

endmodule
