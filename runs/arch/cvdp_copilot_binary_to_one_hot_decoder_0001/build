//! ---
//! tags: [decoder, one_hot, combinational]
//! ---
//!
//! Parameterized binary to one-hot decoder. The output is purely combinational and selects the output bit named by the binary input.
/// Converts a BINARY_WIDTH-bit binary input into an OUTPUT_WIDTH-bit one-hot output.
///
/// Selections beyond the configured output width produce no asserted output bit.
module binary_to_one_hot_decoder #(
  parameter int BINARY_WIDTH = 5,
  parameter int OUTPUT_WIDTH = 32
) (
  input logic [BINARY_WIDTH-1:0] binary_in,
  output logic [OUTPUT_WIDTH-1:0] one_hot_out
);

  assign one_hot_out = (1 << binary_in);

endmodule

