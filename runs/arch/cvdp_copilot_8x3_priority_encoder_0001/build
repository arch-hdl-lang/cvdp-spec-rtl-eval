//! ---
//! tags: [priority-encoder, combinational, cvdp]
//! ---
//!
//! Implements the CVDP 8x3 priority encoder specification. The output is a same-cycle binary index for the highest asserted input bit, defaulting to zero when no input bit is active.
/// 8-bit to 3-bit combinational priority encoder.
///
/// Input bit 7 has the highest priority and input bit 0 has the lowest priority.
module priority_encoder_8x3 (
  input logic [7:0] in,
  output logic [2:0] out
);

  assign out = in[7] ? 3'd7 : in[6] ? 3'd6 : in[5] ? 3'd5 : in[4] ? 3'd4 : in[3] ? 3'd3 : in[2] ? 3'd2 : in[1] ? 3'd1 : 3'd0;

endmodule

