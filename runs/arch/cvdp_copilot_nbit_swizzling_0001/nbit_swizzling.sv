//! ---
//! tags: [bit-swizzle, bit-reversal, combinational]
//! ---
//!
//! Parameterized combinational selective bit-reversal for a DATA_WIDTH-bit input. The 2-bit selection chooses whole-vector reversal or independent reversal within 2, 4, or 8 equal sections.
/// Combinational selective bit-reversal block.
///
/// `sel` controls whether the full input, each half, each quarter, or each eighth of `data_in` is reversed into `data_out` without adding storage or latency.
module nbit_swizzling #(
  parameter int DATA_WIDTH = 64,
  localparam int HALF_WIDTH = DATA_WIDTH / 2,
  localparam int QUARTER_WIDTH = DATA_WIDTH / 4,
  localparam int EIGHTH_WIDTH = DATA_WIDTH / 8
) (
  input logic [DATA_WIDTH-1:0] data_in,
  input logic [1:0] sel,
  output logic [DATA_WIDTH-1:0] data_out
);

  always_comb begin
    data_out = data_in;
    if (sel == 2'd0) begin
      for (int bit_idx = 0; bit_idx <= DATA_WIDTH - 1; bit_idx++) begin
        data_out[bit_idx] = data_in[(DATA_WIDTH - 1) - bit_idx];
      end
    end else if (sel == 2'd1) begin
      for (int group_idx = 0; group_idx <= 1; group_idx++) begin
        for (int bit_idx = 0; bit_idx <= HALF_WIDTH - 1; bit_idx++) begin
          data_out[group_idx * HALF_WIDTH + bit_idx] = data_in[((group_idx * HALF_WIDTH + HALF_WIDTH) - 1) - bit_idx];
        end
      end
    end else if (sel == 2'd2) begin
      for (int group_idx = 0; group_idx <= 3; group_idx++) begin
        for (int bit_idx = 0; bit_idx <= QUARTER_WIDTH - 1; bit_idx++) begin
          data_out[group_idx * QUARTER_WIDTH + bit_idx] = data_in[((group_idx * QUARTER_WIDTH + QUARTER_WIDTH) - 1) - bit_idx];
        end
      end
    end else if (sel == 2'd3) begin
      for (int group_idx = 0; group_idx <= 7; group_idx++) begin
        for (int bit_idx = 0; bit_idx <= EIGHTH_WIDTH - 1; bit_idx++) begin
          data_out[group_idx * EIGHTH_WIDTH + bit_idx] = data_in[((group_idx * EIGHTH_WIDTH + EIGHTH_WIDTH) - 1) - bit_idx];
        end
      end
    end
  end

endmodule

