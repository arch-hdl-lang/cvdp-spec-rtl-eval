//! ---
//! tags: [qam16, mapper, interpolation, combinational]
//! ---
//!
//! Pure combinational QAM16 mapper with one interpolated sample inserted
//! between each adjacent two-symbol group. Packed output lanes carry signed
//! 3-bit two's-complement I and Q amplitudes.
/// Map a two-bit QAM16 quadrant selector to a signed 3-bit amplitude.
///
/// The mapping is 00 -> -3, 01 -> -1, 10 -> 1, and 11 -> 3.
/// Compute the arithmetic mean of two signed QAM16 amplitudes.
///
/// The temporary sum is widened by one bit before division by two.
/// Packed combinational QAM16 mapper and interpolator.
///
/// Each pair of 4-bit symbols produces output lanes ordered as first mapped
/// symbol, interpolated mean, and second mapped symbol for both I and Q.
module qam16_mapper_interpolated #(
  parameter int N = 4,
  parameter int IN_WIDTH = 4,
  parameter int OUT_WIDTH = 3,
  localparam int PAIRS = N / 2,
  localparam int OUT_COUNT = N + PAIRS
) (
  input logic [N * IN_WIDTH-1:0] bits,
  output logic [OUT_COUNT * OUT_WIDTH-1:0] I,
  output logic [OUT_COUNT * OUT_WIDTH-1:0] Q
);

  function automatic logic signed [2:0] MapQam16Amp(input logic [1:0] sel);
    return sel == 2'd0 ? $signed(3'd5) : sel == 2'd1 ? $signed(3'd7) : sel == 2'd2 ? $signed(3'd1) : $signed(3'd3);
  endfunction
  
  function automatic logic signed [2:0] AvgQam16Amp(input logic signed [2:0] a, input logic signed [2:0] b);
    logic signed [3:0] a_ext = {{(4-$bits(a)){a[$bits(a)-1]}}, a};
    logic signed [3:0] b_ext = {{(4-$bits(b)){b[$bits(b)-1]}}, b};
    logic signed [3:0] sum_ext = ($bits(a_ext) > $bits(b_ext) ? $bits(a_ext) : $bits(b_ext))'(a_ext + b_ext);
    logic signed [3:0] avg_ext = sum_ext / 2;
    logic [3:0] avg_bits4 = $unsigned(avg_ext);
    logic [2:0] avg_bits3 = avg_bits4[2:0];
    return $signed(avg_bits3);
  endfunction
  
  logic [3:0] sym0;
  logic [3:0] sym1;
  logic signed [2:0] i0_amp;
  logic signed [2:0] q0_amp;
  logic signed [2:0] i1_amp;
  logic signed [2:0] q1_amp;
  logic signed [2:0] i_mid_amp;
  logic signed [2:0] q_mid_amp;
  logic [2:0] i0_bits;
  logic [2:0] q0_bits;
  logic [2:0] i1_bits;
  logic [2:0] q1_bits;
  logic [2:0] i_mid_bits;
  logic [2:0] q_mid_bits;
  always_comb begin
    I = 0;
    Q = 0;
    for (int pair_idx = 0; pair_idx <= PAIRS - 1; pair_idx++) begin
      for (int bit_idx = 0; bit_idx <= IN_WIDTH - 1; bit_idx++) begin
        sym0[bit_idx] = bits[pair_idx * 2 * IN_WIDTH + bit_idx];
        sym1[bit_idx] = bits[(pair_idx * 2 + 1) * IN_WIDTH + bit_idx];
      end
      i0_amp = MapQam16Amp(sym0[3:2]);
      q0_amp = MapQam16Amp(sym0[1:0]);
      i1_amp = MapQam16Amp(sym1[3:2]);
      q1_amp = MapQam16Amp(sym1[1:0]);
      i_mid_amp = AvgQam16Amp(i0_amp, i1_amp);
      q_mid_amp = AvgQam16Amp(q0_amp, q1_amp);
      i0_bits = $unsigned(i0_amp);
      q0_bits = $unsigned(q0_amp);
      i_mid_bits = $unsigned(i_mid_amp);
      q_mid_bits = $unsigned(q_mid_amp);
      i1_bits = $unsigned(i1_amp);
      q1_bits = $unsigned(q1_amp);
      for (int lane_bit = 0; lane_bit <= OUT_WIDTH - 1; lane_bit++) begin
        I[pair_idx * 3 * OUT_WIDTH + lane_bit] = i0_bits[lane_bit];
        Q[pair_idx * 3 * OUT_WIDTH + lane_bit] = q0_bits[lane_bit];
        I[(pair_idx * 3 + 1) * OUT_WIDTH + lane_bit] = i_mid_bits[lane_bit];
        Q[(pair_idx * 3 + 1) * OUT_WIDTH + lane_bit] = q_mid_bits[lane_bit];
        I[(pair_idx * 3 + 2) * OUT_WIDTH + lane_bit] = i1_bits[lane_bit];
        Q[(pair_idx * 3 + 2) * OUT_WIDTH + lane_bit] = q1_bits[lane_bit];
      end
    end
  end

endmodule

