package pg_pkg;
`ifndef E
  parameter E = 8;
`else
  parameter E = `E;
`endif
`ifndef W
  parameter W = 32;
`else
  parameter W = `W;
`endif
  localparam L = W / E;
  localparam K = L > 1 ? $clog2(L) + 1 : 1;

endpackage
