//! ---
//! tags: [decoder, onehot, sequential]
//! ---
//!
//! Parameterized sequential binary-to-one-hot decoder. The binary input is sampled on the rising edge of i_clk, and the registered one-hot output asynchronously clears to zero when i_rstb is low.
/// Top-level sequential binary-to-one-hot decoder for the CVDP task.
///
/// The output register updates on each rising clock edge with the one-hot bit selected by i_binary_in and resets asynchronously to zero through active-low i_rstb.
module binary_to_one_hot_decoder_sequential #(
  parameter int BINARY_WIDTH = 5,
  parameter int OUTPUT_WIDTH = 32
) (
  input logic i_clk,
  input logic i_rstb,
  input logic [BINARY_WIDTH-1:0] i_binary_in,
  output logic [OUTPUT_WIDTH-1:0] o_one_hot_out
);

  always_ff @(posedge i_clk or negedge i_rstb) begin
    if ((!i_rstb)) begin
      o_one_hot_out <= 0;
    end else begin
      o_one_hot_out <= (1 << i_binary_in);
    end
  end

endmodule

