//! ---
//! tags: [axi_stream, upsizer, ready_valid, sign_extension]
//! ---
//!
//! AXI Stream 24-bit to 32-bit combinational upsizer.
//! Ready propagates from the downstream interface, valid propagates from the upstream interface, and payload formatting is applied without adding storage.
/// AXI Stream 24-to-32-bit combinational upsizer.
///
/// Port timing: clk and resetn are present for interface compatibility; s_axis_ready, m_axis_valid, and m_axis_data are combinational pass-through/formatting outputs.
///
/// Data formatting: when dfmt_enable is low, the upper byte is zero and the 24-bit source payload is preserved. When enabled, dfmt_type selects either the source MSB or its inverse for output bit 23, and dfmt_se selects whether the upper byte is zero or sign-filled from that selected bit.
module axis_upscale (
  input logic clk,
  input logic resetn,
  input logic dfmt_enable,
  input logic dfmt_type,
  input logic dfmt_se,
  input logic s_axis_valid,
  input logic [23:0] s_axis_data,
  input logic m_axis_ready,
  output logic s_axis_ready,
  output logic m_axis_valid,
  output logic [31:0] m_axis_data
);

  logic src_msb;
  logic selected_msb;
  logic payload_msb;
  logic extend_bit;
  logic [7:0] extend_byte;
  logic [23:0] formatted_payload;
  logic [31:0] formatted_data;
  assign src_msb = s_axis_data[23];
  assign selected_msb = dfmt_type ? !src_msb : src_msb;
  assign payload_msb = dfmt_enable ? selected_msb : src_msb;
  assign extend_bit = dfmt_enable && dfmt_se && payload_msb;
  assign extend_byte = extend_bit ? 8'd255 : 8'd0;
  assign formatted_payload = {payload_msb, s_axis_data[22:0]};
  assign formatted_data = {extend_byte, formatted_payload};
  assign s_axis_ready = m_axis_ready;
  assign m_axis_valid = s_axis_valid;
  assign m_axis_data = formatted_data;

endmodule

