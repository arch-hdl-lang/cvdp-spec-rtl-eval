//! ---
//! tags: [comparator, signed, unsigned, combinational]
//! ---
//!
//! Parameterized combinational comparator with enable gating and selectable signed or unsigned interpretation.
/// Compares two WIDTH-bit operands and reports greater-than, less-than, or equality.
///
/// The comparison is active only when i_enable is high; i_mode selects signed interpretation when high and unsigned magnitude interpretation when low.
module signed_unsigned_comparator #(
  parameter int WIDTH = 5
) (
  input logic [WIDTH-1:0] i_A,
  input logic [WIDTH-1:0] i_B,
  input logic i_enable,
  input logic i_mode,
  output logic o_greater,
  output logic o_less,
  output logic o_equal
);

  logic signed [WIDTH-1:0] signed_a;
  logic signed [WIDTH-1:0] signed_b;
  logic signed_greater;
  logic signed_less;
  logic unsigned_greater;
  logic unsigned_less;
  logic values_equal;
  logic selected_greater;
  logic selected_less;
  assign signed_a = $signed(i_A);
  assign signed_b = $signed(i_B);
  assign signed_greater = signed_a > signed_b;
  assign signed_less = signed_a < signed_b;
  assign unsigned_greater = i_A > i_B;
  assign unsigned_less = i_A < i_B;
  assign values_equal = i_A == i_B;
  assign selected_greater = i_mode ? signed_greater : unsigned_greater;
  assign selected_less = i_mode ? signed_less : unsigned_less;
  assign o_greater = i_enable && selected_greater;
  assign o_less = i_enable && selected_less;
  assign o_equal = i_enable && values_equal;

endmodule

