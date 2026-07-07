//! ---
//! tags: [data-width, aggregation, valid-pulse]
//! ---
//!
//! 32-to-128 bit data width converter that collects four valid 32-bit samples
//! and emits one registered 128-bit word with a one-cycle valid pulse.
/// Aggregates consecutive valid 32-bit input samples into a 128-bit output word.
///
/// Reset clears the partial buffer and suppresses output valid until four new
/// valid samples have been accepted on rising clock edges.
module data_width_converter (
  input logic clk,
  input logic reset,
  input logic [31:0] data_in,
  input logic data_valid,
  output logic [127:0] o_data_out,
  output logic o_data_out_valid
);

  logic [31:0] word0;
  logic [31:0] word1;
  logic [31:0] word2;
  logic [1:0] sample_count;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      o_data_out <= 0;
      o_data_out_valid <= 0;
      sample_count <= 0;
      word0 <= 0;
      word1 <= 0;
      word2 <= 0;
    end else begin
      o_data_out_valid <= 0;
      if (data_valid) begin
        if (sample_count == 0) begin
          word0 <= data_in;
          sample_count <= 1;
        end else if (sample_count == 1) begin
          word1 <= data_in;
          sample_count <= 2;
        end else if (sample_count == 2) begin
          word2 <= data_in;
          sample_count <= 3;
        end else begin
          o_data_out <= {word0, word1, word2, data_in};
          o_data_out_valid <= 1;
          sample_count <= 0;
          word0 <= 0;
          word1 <= 0;
          word2 <= 0;
        end
      end
    end
  end

endmodule

