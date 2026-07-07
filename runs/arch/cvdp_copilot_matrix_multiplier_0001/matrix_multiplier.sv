//! ---
//! tags: [matrix, multiplier, combinational, parameterized]
//! ---
//!
//! Parameterized combinational unsigned matrix multiplier for compatible
//! row-major flattened matrices. Matrix A is ROW_A by COL_A, matrix B is
//! ROW_B by COL_B, and matrix C is ROW_A by COL_B.
/// Combinational unsigned matrix multiplier with packed row-major matrix ports.
///
/// Each output element is the sum over COL_A products and is written into the
/// corresponding row-major lane of matrix_c with no registered latency.
module matrix_multiplier #(
  parameter int ROW_A = 4,
  parameter int COL_A = 4,
  parameter int ROW_B = 4,
  parameter int COL_B = 4,
  parameter int INPUT_DATA_WIDTH = 8,
  parameter int OUTPUT_DATA_WIDTH = 2 * INPUT_DATA_WIDTH + $clog2(COL_A)
) (
  input logic [ROW_A * COL_A * INPUT_DATA_WIDTH-1:0] matrix_a,
  input logic [ROW_B * COL_B * INPUT_DATA_WIDTH-1:0] matrix_b,
  output logic [ROW_A * COL_B * OUTPUT_DATA_WIDTH-1:0] matrix_c
);

  logic [ROW_A * COL_B * OUTPUT_DATA_WIDTH-1:0] result;
  logic [INPUT_DATA_WIDTH-1:0] a_elem;
  logic [INPUT_DATA_WIDTH-1:0] b_elem;
  logic [2 * INPUT_DATA_WIDTH-1:0] prod_full;
  logic [OUTPUT_DATA_WIDTH-1:0] prod_wide;
  logic [ROW_A * COL_B * (COL_A + 1)-1:0] [OUTPUT_DATA_WIDTH-1:0] partial;
  assign matrix_c = result;
  always_comb begin
    result = 0;
    for (int row_idx = 0; row_idx <= ROW_A - 1; row_idx++) begin
      for (int col_idx = 0; col_idx <= COL_B - 1; col_idx++) begin
        partial[(row_idx * COL_B + col_idx) * (COL_A + 1)] = 0;
        for (int sum_idx = 0; sum_idx <= COL_A - 1; sum_idx++) begin
          a_elem = matrix_a[(row_idx * COL_A + sum_idx) * INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH];
          b_elem = matrix_b[(sum_idx * COL_B + col_idx) * INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH];
          prod_full = a_elem * b_elem;
          prod_wide = OUTPUT_DATA_WIDTH'(prod_full);
          partial[(row_idx * COL_B + col_idx) * (COL_A + 1) + sum_idx + 1] = (($bits(partial[(row_idx * COL_B + col_idx) * (COL_A + 1) + sum_idx]) > $bits(prod_wide) ? $bits(partial[(row_idx * COL_B + col_idx) * (COL_A + 1) + sum_idx]) : $bits(prod_wide)))'(partial[(row_idx * COL_B + col_idx) * (COL_A + 1) + sum_idx] + prod_wide);
        end
        result[(row_idx * COL_B + col_idx) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = partial[(row_idx * COL_B + col_idx) * (COL_A + 1) + COL_A];
      end
    end
  end

endmodule

