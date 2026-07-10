module ha (
    input  logic a_i,
    input  logic b_i,
    output logic s_o,
    output logic c_o
);
  fa i_fa (.*, .c_i(1'b 0));

endmodule
