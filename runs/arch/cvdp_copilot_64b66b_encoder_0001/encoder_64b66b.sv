//! ---
//! tags: [encoder, 64b66b, datapath, registered-output]
//! ---
//!
//! Implements the requested first-pass 64b/66b encoder behavior for pure data words.
//! The output is registered with one clock cycle of latency and resets to zero on active-high asynchronous reset.
/// 64b/66b encoder with one-cycle registered output.
///
/// When all control bits are zero, prefixes the 64-bit data with sync header 2'b01.
/// Unsupported control-character cases emit sync header 2'b10 with a zero payload.
module encoder_64b66b (
  input logic clk_in,
  input logic rst_in,
  input logic [63:0] encoder_data_in,
  input logic [7:0] encoder_control_in,
  output logic [65:0] encoder_data_out
);

  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
      encoder_data_out <= 0;
    end else begin
      if (encoder_control_in == 8'd0) begin
        encoder_data_out <= {2'd1, encoder_data_in};
      end else begin
        encoder_data_out <= {2'd2, 64'd0};
      end
    end
  end

endmodule

