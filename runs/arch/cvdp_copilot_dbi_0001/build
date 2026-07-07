//! ---
//! tags: [dbi, encoding, bus_inversion]
//! ---
//!
//! Data Bus Inversion encoder for a 40-bit bus split into two 20-bit lanes.
//! Each cycle compares incoming data against the previously emitted encoded data
//! and registers the encoded data plus one DBI control bit per lane.
/// Registered two-lane 40-bit Data Bus Inversion encoder.
///
/// The active-low asynchronous reset clears the encoded output and control bits.
module dbi_enc (
  input logic clk,
  input logic rst_n,
  input logic [39:0] data_in,
  output logic [39:0] data_out,
  output logic [1:0] dbi_cntrl
);

  logic [19:0] cur_g1;
  logic [19:0] cur_g0;
  logic [19:0] prev_g1;
  logic [19:0] prev_g0;
  logic [19:0] diff_g1;
  logic [19:0] diff_g0;
  logic [4:0] g1_b00;
  logic [4:0] g1_b01;
  logic [4:0] g1_b02;
  logic [4:0] g1_b03;
  logic [4:0] g1_b04;
  logic [4:0] g1_b05;
  logic [4:0] g1_b06;
  logic [4:0] g1_b07;
  logic [4:0] g1_b08;
  logic [4:0] g1_b09;
  logic [4:0] g1_b10;
  logic [4:0] g1_b11;
  logic [4:0] g1_b12;
  logic [4:0] g1_b13;
  logic [4:0] g1_b14;
  logic [4:0] g1_b15;
  logic [4:0] g1_b16;
  logic [4:0] g1_b17;
  logic [4:0] g1_b18;
  logic [4:0] g1_b19;
  logic [4:0] g1_s00;
  logic [4:0] g1_s01;
  logic [4:0] g1_s02;
  logic [4:0] g1_s03;
  logic [4:0] g1_s04;
  logic [4:0] g1_s05;
  logic [4:0] g1_s06;
  logic [4:0] g1_s07;
  logic [4:0] g1_s08;
  logic [4:0] g1_s09;
  logic [4:0] g1_t00;
  logic [4:0] g1_t01;
  logic [4:0] g1_t02;
  logic [4:0] g1_t03;
  logic [4:0] g1_t04;
  logic [4:0] g1_u00;
  logic [4:0] g1_u01;
  logic [4:0] g1_v00;
  logic [4:0] diff_count_g1;
  logic [4:0] g0_b00;
  logic [4:0] g0_b01;
  logic [4:0] g0_b02;
  logic [4:0] g0_b03;
  logic [4:0] g0_b04;
  logic [4:0] g0_b05;
  logic [4:0] g0_b06;
  logic [4:0] g0_b07;
  logic [4:0] g0_b08;
  logic [4:0] g0_b09;
  logic [4:0] g0_b10;
  logic [4:0] g0_b11;
  logic [4:0] g0_b12;
  logic [4:0] g0_b13;
  logic [4:0] g0_b14;
  logic [4:0] g0_b15;
  logic [4:0] g0_b16;
  logic [4:0] g0_b17;
  logic [4:0] g0_b18;
  logic [4:0] g0_b19;
  logic [4:0] g0_s00;
  logic [4:0] g0_s01;
  logic [4:0] g0_s02;
  logic [4:0] g0_s03;
  logic [4:0] g0_s04;
  logic [4:0] g0_s05;
  logic [4:0] g0_s06;
  logic [4:0] g0_s07;
  logic [4:0] g0_s08;
  logic [4:0] g0_s09;
  logic [4:0] g0_t00;
  logic [4:0] g0_t01;
  logic [4:0] g0_t02;
  logic [4:0] g0_t03;
  logic [4:0] g0_t04;
  logic [4:0] g0_u00;
  logic [4:0] g0_u01;
  logic [4:0] g0_v00;
  logic [4:0] diff_count_g0;
  logic invert_g1;
  logic invert_g0;
  logic [19:0] enc_g1;
  logic [19:0] enc_g0;
  logic [39:0] next_data;
  logic [1:0] next_ctrl;
  assign cur_g1 = data_in[39:20];
  assign cur_g0 = data_in[19:0];
  assign prev_g1 = data_out[39:20];
  assign prev_g0 = data_out[19:0];
  assign diff_g1 = cur_g1 ^ prev_g1;
  assign diff_g0 = cur_g0 ^ prev_g0;
  assign g1_b00 = diff_g1[0] ? 5'd1 : 5'd0;
  assign g1_b01 = diff_g1[1] ? 5'd1 : 5'd0;
  assign g1_b02 = diff_g1[2] ? 5'd1 : 5'd0;
  assign g1_b03 = diff_g1[3] ? 5'd1 : 5'd0;
  assign g1_b04 = diff_g1[4] ? 5'd1 : 5'd0;
  assign g1_b05 = diff_g1[5] ? 5'd1 : 5'd0;
  assign g1_b06 = diff_g1[6] ? 5'd1 : 5'd0;
  assign g1_b07 = diff_g1[7] ? 5'd1 : 5'd0;
  assign g1_b08 = diff_g1[8] ? 5'd1 : 5'd0;
  assign g1_b09 = diff_g1[9] ? 5'd1 : 5'd0;
  assign g1_b10 = diff_g1[10] ? 5'd1 : 5'd0;
  assign g1_b11 = diff_g1[11] ? 5'd1 : 5'd0;
  assign g1_b12 = diff_g1[12] ? 5'd1 : 5'd0;
  assign g1_b13 = diff_g1[13] ? 5'd1 : 5'd0;
  assign g1_b14 = diff_g1[14] ? 5'd1 : 5'd0;
  assign g1_b15 = diff_g1[15] ? 5'd1 : 5'd0;
  assign g1_b16 = diff_g1[16] ? 5'd1 : 5'd0;
  assign g1_b17 = diff_g1[17] ? 5'd1 : 5'd0;
  assign g1_b18 = diff_g1[18] ? 5'd1 : 5'd0;
  assign g1_b19 = diff_g1[19] ? 5'd1 : 5'd0;
  assign g1_s00 = 5'(g1_b00 + g1_b01);
  assign g1_s01 = 5'(g1_b02 + g1_b03);
  assign g1_s02 = 5'(g1_b04 + g1_b05);
  assign g1_s03 = 5'(g1_b06 + g1_b07);
  assign g1_s04 = 5'(g1_b08 + g1_b09);
  assign g1_s05 = 5'(g1_b10 + g1_b11);
  assign g1_s06 = 5'(g1_b12 + g1_b13);
  assign g1_s07 = 5'(g1_b14 + g1_b15);
  assign g1_s08 = 5'(g1_b16 + g1_b17);
  assign g1_s09 = 5'(g1_b18 + g1_b19);
  assign g1_t00 = 5'(g1_s00 + g1_s01);
  assign g1_t01 = 5'(g1_s02 + g1_s03);
  assign g1_t02 = 5'(g1_s04 + g1_s05);
  assign g1_t03 = 5'(g1_s06 + g1_s07);
  assign g1_t04 = 5'(g1_s08 + g1_s09);
  assign g1_u00 = 5'(g1_t00 + g1_t01);
  assign g1_u01 = 5'(g1_t02 + g1_t03);
  assign g1_v00 = 5'(g1_u00 + g1_u01);
  assign diff_count_g1 = 5'(g1_v00 + g1_t04);
  assign g0_b00 = diff_g0[0] ? 5'd1 : 5'd0;
  assign g0_b01 = diff_g0[1] ? 5'd1 : 5'd0;
  assign g0_b02 = diff_g0[2] ? 5'd1 : 5'd0;
  assign g0_b03 = diff_g0[3] ? 5'd1 : 5'd0;
  assign g0_b04 = diff_g0[4] ? 5'd1 : 5'd0;
  assign g0_b05 = diff_g0[5] ? 5'd1 : 5'd0;
  assign g0_b06 = diff_g0[6] ? 5'd1 : 5'd0;
  assign g0_b07 = diff_g0[7] ? 5'd1 : 5'd0;
  assign g0_b08 = diff_g0[8] ? 5'd1 : 5'd0;
  assign g0_b09 = diff_g0[9] ? 5'd1 : 5'd0;
  assign g0_b10 = diff_g0[10] ? 5'd1 : 5'd0;
  assign g0_b11 = diff_g0[11] ? 5'd1 : 5'd0;
  assign g0_b12 = diff_g0[12] ? 5'd1 : 5'd0;
  assign g0_b13 = diff_g0[13] ? 5'd1 : 5'd0;
  assign g0_b14 = diff_g0[14] ? 5'd1 : 5'd0;
  assign g0_b15 = diff_g0[15] ? 5'd1 : 5'd0;
  assign g0_b16 = diff_g0[16] ? 5'd1 : 5'd0;
  assign g0_b17 = diff_g0[17] ? 5'd1 : 5'd0;
  assign g0_b18 = diff_g0[18] ? 5'd1 : 5'd0;
  assign g0_b19 = diff_g0[19] ? 5'd1 : 5'd0;
  assign g0_s00 = 5'(g0_b00 + g0_b01);
  assign g0_s01 = 5'(g0_b02 + g0_b03);
  assign g0_s02 = 5'(g0_b04 + g0_b05);
  assign g0_s03 = 5'(g0_b06 + g0_b07);
  assign g0_s04 = 5'(g0_b08 + g0_b09);
  assign g0_s05 = 5'(g0_b10 + g0_b11);
  assign g0_s06 = 5'(g0_b12 + g0_b13);
  assign g0_s07 = 5'(g0_b14 + g0_b15);
  assign g0_s08 = 5'(g0_b16 + g0_b17);
  assign g0_s09 = 5'(g0_b18 + g0_b19);
  assign g0_t00 = 5'(g0_s00 + g0_s01);
  assign g0_t01 = 5'(g0_s02 + g0_s03);
  assign g0_t02 = 5'(g0_s04 + g0_s05);
  assign g0_t03 = 5'(g0_s06 + g0_s07);
  assign g0_t04 = 5'(g0_s08 + g0_s09);
  assign g0_u00 = 5'(g0_t00 + g0_t01);
  assign g0_u01 = 5'(g0_t02 + g0_t03);
  assign g0_v00 = 5'(g0_u00 + g0_u01);
  assign diff_count_g0 = 5'(g0_v00 + g0_t04);
  assign invert_g1 = diff_count_g1 > 5'd10;
  assign invert_g0 = diff_count_g0 > 5'd10;
  assign enc_g1 = invert_g1 ? ~cur_g1 : cur_g1;
  assign enc_g0 = invert_g0 ? ~cur_g0 : cur_g0;
  assign next_data = {enc_g1, enc_g0};
  assign next_ctrl = {invert_g1, invert_g0};
  always_ff @(posedge clk or negedge rst_n) begin
    if ((!rst_n)) begin
      data_out <= 40'd0;
      dbi_cntrl <= 2'd0;
    end else begin
      data_out <= next_data;
      dbi_cntrl <= next_ctrl;
    end
  end

endmodule

