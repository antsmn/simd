module pg_src (
    input  logic [ 2:0] m_i,
    input  logic        a_signed_i,
    input  logic        b_signed_i,  // unused: signed booth encode FIXME side csa for unsigned booth
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    output logic [32:0] a_src_0,
    output logic [32:0] a_src_1,
    output logic [32:0] a_src_2,
    output logic [32:0] a_src_3,
    output logic [32:0] b_src_0,
    output logic [32:0] b_src_1,
    output logic [32:0] b_src_2,
    output logic [32:0] b_src_3,
    output logic [32:0] a_mask_0,
    output logic [32:0] a_mask_1,
    output logic [32:0] a_mask_2,
    output logic [32:0] a_mask_3,
    output logic [32:0] b_mask_0,
    output logic [32:0] b_mask_1,
    output logic [32:0] b_mask_2,
    output logic [32:0] b_mask_3,
    output logic [32:0] a1_i_0,
    output logic [32:0] a1_i_1,
    output logic [32:0] a1_i_2,
    output logic [32:0] a1_i_3,
    output logic [32:0] a2_i_0,
    output logic [32:0] a2_i_1,
    output logic [32:0] a2_i_2,
    output logic [32:0] a2_i_3
);

  assign a_src_0 = ({33{m_i[0]}} & {24'b000000000000000000000000, (a_signed_i & a_i[7]), a_i[ 7:0]}) |
                   ({33{m_i[1]}} & {16'b000000000000000, (a_signed_i & a_i[15]), a_i[15:0]}) |
                   ({33{m_i[2]}} & {(a_signed_i & a_i[31]), a_i}) ;
  assign a_src_1 = ({33{m_i[0]}} & {16'b000000000000000, (a_signed_i & a_i[15]), a_i[15: 8], 8'b00000000}) |
                   ({33{m_i[1]}} & {16'b000000000000000, (a_signed_i & a_i[15]), a_i[15: 0]}) |
                   ({33{m_i[2]}} & {(a_signed_i & a_i[31]), a_i}) ;
  assign a_src_2 = ({33{m_i[0]}} & {8'b00000000, (a_signed_i & a_i[23]), a_i[23:16], 16'b000000000000000}) |
                   ({33{m_i[1]}} & {(a_signed_i & a_i[31]), a_i[31:16], 16'b000000000000000}) |
                   ({33{m_i[2]}} & {(a_signed_i & a_i[31]), a_i}) ;
  assign a_src_3 = ({33{m_i[0]}} & {(a_signed_i & a_i[31]), a_i[31:24], 24'b000000000000000000000000}) |
                   ({33{m_i[1]}} & {(a_signed_i & a_i[31]), a_i[31:16], 16'b000000000000000}) |
                   ({33{m_i[2]}} & {(a_signed_i & a_i[31]), a_i}) ;

  assign a_mask_0 = ({33 {m_i[0]}} & {24'b000000000000000000000000, 9'b111111111}) |
                    ({33 {m_i[1]}} & {16'b000000000000000, 17'b11111111111111111}) |
                    ({33 {m_i[2]}} & {33'b111111111111111111111111111111111});
  assign a_mask_1 = ({33 {m_i[0]}} & {16'b0000000000000000, 9'b111111111, 8'b00000000}) |
                    ({33 {m_i[1]}} & {16'b000000000000000, 17'b11111111111111111}) |
                    ({33 {m_i[2]}} & {33'b111111111111111111111111111111111});
  assign a_mask_2 = ({33 {m_i[0]}} & {8'b00000000, 9'b111111111, 16'b0000000000000000}) |
                    ({33 {m_i[1]}} & {17'b11111111111111111, 16'b000000000000000}) |
                    ({33 {m_i[2]}} & {33'b111111111111111111111111111111111});
  assign a_mask_3 = ({33 {m_i[0]}} & {9'b111111111, 24'b000000000000000000000000}) |
                    ({33 {m_i[1]}} & {17'b11111111111111111, 16'b000000000000000}) |
                    ({33 {m_i[2]}} & {33'b111111111111111111111111111111111});

  assign a1_i_0 = a_src_0;
  assign a1_i_1 = a_src_1;
  assign a1_i_2 = a_src_2;
  assign a1_i_3 = a_src_3;

  assign a2_i_0 = (a_src_0 << 1) & a_mask_0;
  assign a2_i_1 = (a_src_1 << 1) & a_mask_1;
  assign a2_i_2 = (a_src_2 << 1) & a_mask_2;
  assign a2_i_3 = (a_src_3 << 1);

  logic [32:0] b;

  assign b = {b_i, 1'b0};

  // << 1 mask lsb encoding
  assign b_mask_0 = a_mask_0 << 1;
  assign b_mask_1 = a_mask_1 << 1;
  assign b_mask_2 = a_mask_2 << 1;
  assign b_mask_3 = a_mask_3 << 1;

  assign b_src_0  = b & b_mask_0;
  assign b_src_1  = b & b_mask_1;
  assign b_src_2  = b & b_mask_2;
  assign b_src_3  = b & b_mask_3;

endmodule
