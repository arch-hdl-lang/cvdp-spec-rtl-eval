//! ---
//! tags: [qam16, demapper, interpolation, combinational]
//! refs: []
//! ---
//!
//! Combinational QAM16 demapper for packed I/Q sample streams. The design decodes mapped samples into four-bit symbols and raises a global flag when an interpolated sample differs from the average of its adjacent mapped samples by more than the threshold.
/// Convert one signed 3-bit QAM16 amplitude lane into its two-bit symbol code.
///
/// The four constellation levels use their two's-complement 3-bit encodings: -3=101, -1=111, 1=001, and 3=011.
/// Return the absolute signed deviation between an interpolated 3-bit lane and the average of its two mapped neighbors.
///
/// All arithmetic is widened before signed addition, division, subtraction, and absolute-value calculation.
/// Top-level combinational QAM16 demapper with interpolated-value error detection.
///
/// Inputs are packed as repeated pairs of mapped samples with one interpolated sample between them. Outputs are same-cycle combinational: `bits` contains one 4-bit demapped symbol for each mapped sample, and `error_flag` is the OR of all I and Q interpolation checks.
module qam16_demapper_interpolated #(
  parameter int N = 4,
  parameter int OUT_WIDTH = 4,
  parameter int IN_WIDTH = 3,
  parameter int ERROR_THRESHOLD = 1
) (
  input logic [(N + N / 2) * IN_WIDTH-1:0] I,
  input logic [(N + N / 2) * IN_WIDTH-1:0] Q,
  output logic [N * OUT_WIDTH-1:0] bits,
  output logic error_flag
);

  function automatic logic [1:0] qam16_level_bits(input logic [2:0] v);
    return v == 3'd5 ? 2'd0 : v == 3'd7 ? 2'd1 : v == 3'd1 ? 2'd2 : v == 3'd3 ? 2'd3 : 2'd0;
  endfunction
  
  function automatic logic signed [5:0] interp_lane_abs_diff(input logic [2:0] a_raw, input logic [2:0] mid_raw, input logic [2:0] b_raw);
    logic signed [2:0] a_s3 = $signed(a_raw);
    logic signed [2:0] mid_s3 = $signed(mid_raw);
    logic signed [2:0] b_s3 = $signed(b_raw);
    logic signed [3:0] a_s4 = {{(4-$bits(a_s3)){a_s3[$bits(a_s3)-1]}}, a_s3};
    logic signed [3:0] mid_s4 = {{(4-$bits(mid_s3)){mid_s3[$bits(mid_s3)-1]}}, mid_s3};
    logic signed [3:0] b_s4 = {{(4-$bits(b_s3)){b_s3[$bits(b_s3)-1]}}, b_s3};
    logic signed [4:0] sum_s5 = a_s4 + b_s4;
    logic signed [4:0] avg_s5 = sum_s5 / 2;
    logic signed [4:0] mid_s5 = {{(5-$bits(mid_s4)){mid_s4[$bits(mid_s4)-1]}}, mid_s4};
    logic signed [5:0] diff_s6 = mid_s5 - avg_s5;
    logic signed [5:0] neg_diff_s6 = 0 - diff_s6;
    logic signed [5:0] abs_diff_s6 = diff_s6 < 0 ? neg_diff_s6 : diff_s6;
    return abs_diff_s6;
  endfunction
  
  always_comb begin
    bits = 0;
    error_flag = 1'b0;
    for (int pair_idx = 0; pair_idx <= N / 2; pair_idx++) begin
      bits[pair_idx * 2 * OUT_WIDTH +: 4] = {qam16_level_bits(I[pair_idx * 3 * IN_WIDTH +: 3]), qam16_level_bits(Q[pair_idx * 3 * IN_WIDTH +: 3])};
      bits[(pair_idx * 2 + 1) * OUT_WIDTH +: 4] = {qam16_level_bits(I[(pair_idx * 3 + 2) * IN_WIDTH +: 3]), qam16_level_bits(Q[(pair_idx * 3 + 2) * IN_WIDTH +: 3])};
      if (interp_lane_abs_diff(I[pair_idx * 3 * IN_WIDTH +: 3], I[(pair_idx * 3 + 1) * IN_WIDTH +: 3], I[(pair_idx * 3 + 2) * IN_WIDTH +: 3]) > ERROR_THRESHOLD || interp_lane_abs_diff(Q[pair_idx * 3 * IN_WIDTH +: 3], Q[(pair_idx * 3 + 1) * IN_WIDTH +: 3], Q[(pair_idx * 3 + 2) * IN_WIDTH +: 3]) > ERROR_THRESHOLD) begin
        error_flag = 1'b1;
      end
    end
  end

endmodule

