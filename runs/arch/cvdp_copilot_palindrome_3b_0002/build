//! ---
//! tags: [palindrome, stream, detector]
//! ---
//!
//! Three-bit streaming palindrome detector. After synchronous active-high reset, the detector samples one bit per rising clock edge and raises the output when the current sample matches the sample from two cycles earlier.
/// Top-level three-bit palindrome detector for a serial input stream.
///
/// The output is driven from a registered detection result and is suppressed until three post-reset samples have been observed.
module palindrome_detect #(
  parameter int N = 3
) (
  input logic clk,
  input logic reset,
  input logic bit_stream,
  output logic palindrome_detected
);

  logic prev_bit_1;
  logic prev_bit_2;
  logic [1:0] sample_count;
  logic detected_reg;
  assign palindrome_detected = detected_reg;
  always_ff @(posedge clk) begin
    if (reset) begin
      prev_bit_1 <= 1'b0;
      prev_bit_2 <= 1'b0;
      sample_count <= 0;
      detected_reg <= 1'b0;
    end else begin
      prev_bit_2 <= prev_bit_1;
      prev_bit_1 <= bit_stream;
      if (sample_count == 2) begin
        sample_count <= sample_count;
        detected_reg <= bit_stream == prev_bit_2;
      end else begin
        sample_count <= (2 > 1 ? 2 : 1)'(sample_count + 1);
        detected_reg <= 1'b0;
      end
    end
  end

endmodule

