module compressor #(
    parameter W = 8
) (
    input  logic [W-1:0] a_i,
    input  logic [W-4:0] c_i,
    output logic [W-4:0] c_o,
    output logic [  1:0] s_o
);
  localparam NUM_FA = W - 2;

  logic [3*NUM_FA-1:0] p_1;

  assign p_1[W-1:0] = a_i;

  for (genvar i = 0; i < NUM_FA - 1; i += 1) begin

    logic a;
    logic b;
    logic c;

    assign a = p_1[i*3];
    assign b = p_1[i*3+1];
    assign c = p_1[i*3+2];

    logic co;
    logic so;

    fa i_fa
    (
        .a_i(a),
        .b_i(b),
        .c_i(c),
        .c_o(co),
        .s_o(so)
    );

    assign p_1[W+i*2] = c_i[i];
    assign p_1[W+i*2+1] = so;
    assign c_o[i] = co;

  end

  logic a;
  logic b;
  logic c;

  assign a = p_1[(NUM_FA-1)*3];
  assign b = p_1[(NUM_FA-1)*3+1];
  assign c = p_1[(NUM_FA-1)*3+2];

  logic so;
  logic co;

  fa i_fa
  (
      .a_i(a),
      .b_i(b),
      .c_i(c),
      .c_o(co),
      .s_o(so)
  );
  assign s_o[0] = so;
  assign s_o[1] = co;

endmodule
