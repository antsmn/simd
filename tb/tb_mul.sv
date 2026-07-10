`timescale 1ns / 1ns
module tb_mul;
  parameter                W = 32;
  parameter                E = 8;
  parameter                NUM_TESTS = 1 << 10;

  // setup parameters

  // localparam               n = 3;
  // localparam               n = 2;
  // localparam               n = 1;
  localparam               n = 0;

  localparam               K = $clog2(W / E) + 1;
  localparam logic [K-1:0] z = K'(1 << n);
  logic [K-1:0]            m_i;  // mode
  assign m_i = z;

  // src size
  localparam F = E << n;
  localparam L = W / F;

  logic              error;

  logic              a_signed_i;
  logic              b_signed_i;
  logic [     W-1:0] a_i;
  logic [     W-1:0] b_i;
  logic [(W<<1)-1:0] p_o;

  logic [       F:0] v_a[L-1:0];
  logic [       F:0] v_b[L-1:0];
  logic [(F<<1)-1:0] v_d[L-1:0];
  logic [(F<<1)-1:0] v_r[L-1:0];
  logic [(F<<1)-1:0] v_p[L-1:0];

  initial begin
    $dumpfile("tb_mul");
    $dumpvars(0, tb_mul);

    a_signed_i = 1'b1;
    b_signed_i = 1'b1;

    repeat (NUM_TESTS) begin
      a_i = {(W / 32) {$random()}};
      b_i = {(W / 32) {$random()}};
      #1
      assert (!error) else begin
        for (int i = 0; i < L; i += 1) $display("%h %h %h", v_a[i][F-1:0], v_b[i][F-1:0], v_d[i]);
        $fatal(1);
      end
    end
  end
  mul DUT (.*);

  for (genvar i = 0; i < L; i += 1) begin
    logic [F-1:0] a;
    logic [F-1:0] b;
    logic n_a;
    logic n_b;
    assign n_a = a_signed_i & a_i[(i+1)*F-1];
    assign n_b = b_signed_i & b_i[(i+1)*F-1];
    assign a = a_i[i*F+:F];
    assign b = b_i[i*F+:F];

    assign v_a[i] = {n_a, a};
    assign v_b[i] = {n_b, b};

  end
  for (genvar i = 0; i < L; i += 1) begin
    assign v_r[i] = $signed(v_a[i]) * $signed(v_b[i]);
  end
  for (genvar i = 0; i < L; i += 1) begin
    assign v_d[i] = $signed(v_r[i]) - $signed(v_p[i]);
  end
  always @(*) begin
    error = 0;
    for (int i = 0; i < L; i += 1) begin
      error |= v_p[i] != v_r[i];
    end
  end
  for (genvar i = 0; i < L; i += 1) begin
    assign v_p[i] = p_o[i*(F<<1)+:(F<<1)];
  end

endmodule
