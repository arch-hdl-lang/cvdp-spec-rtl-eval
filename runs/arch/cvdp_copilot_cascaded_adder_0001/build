//! ---
//! tags: [adder, reduction, registered, async_reset]
//! ---
//!
//! Cascaded adder for flattened input elements. Valid input data is captured on
//! the rising clock edge, reduced through a combinational cascaded sum, and then
//! published through registered valid/data outputs with active-low async reset.
/// Parameterized cascaded adder with registered input and registered output.
///
/// `clk` samples `i_valid` and `i_data` on rising edges, `rst_n` asynchronously
/// clears all state low, and `o_valid`/`o_data` are registered output signals.
module cascaded_adder #(
  parameter int IN_DATA_WIDTH = 16,
  parameter int IN_DATA_NS = 4,
  localparam int IN_TOTAL_WIDTH = IN_DATA_WIDTH * IN_DATA_NS,
  localparam int OUT_DATA_WIDTH = IN_DATA_WIDTH + $clog2(IN_DATA_NS)
) (
  input logic clk,
  input logic rst_n,
  input logic i_valid,
  input logic [IN_TOTAL_WIDTH-1:0] i_data,
  output logic o_valid,
  output logic [OUT_DATA_WIDTH-1:0] o_data
);

  logic [IN_TOTAL_WIDTH-1:0] data_r;
  logic valid_r;
  logic [IN_DATA_WIDTH-1:0] elem_slice;
  logic [OUT_DATA_WIDTH-1:0] elem_wide;
  logic [OUT_DATA_WIDTH-1:0] sum_comb;
  always_comb begin
    sum_comb = 0;
    elem_slice = 0;
    elem_wide = 0;
    for (int idx = 0; idx <= IN_DATA_NS - 1; idx++) begin
      elem_slice = 0;
      for (int bit_idx = 0; bit_idx <= IN_DATA_WIDTH - 1; bit_idx++) begin
        elem_slice[bit_idx] = data_r[idx * IN_DATA_WIDTH + bit_idx];
      end
      elem_wide = OUT_DATA_WIDTH'(elem_slice);
      sum_comb = ($bits(sum_comb) > $bits(elem_wide) ? $bits(sum_comb) : $bits(elem_wide))'(sum_comb + elem_wide);
    end
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if ((!rst_n)) begin
      data_r <= 0;
      o_data <= 0;
      o_valid <= 1'b0;
      valid_r <= 1'b0;
    end else begin
      if (i_valid) begin
        data_r <= i_data;
      end
      valid_r <= i_valid;
      o_valid <= valid_r;
      if (valid_r) begin
        o_data <= sum_comb;
      end else begin
        o_data <= 0;
      end
    end
  end

endmodule

