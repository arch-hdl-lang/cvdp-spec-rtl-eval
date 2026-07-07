//! ---
//! tags: [clock_mux, glitch_free, clock_switch]
//! refs: []
//! ---
//!
//! Glitch-free switching between two synchronous input clocks. The selected
//! source is changed by first disabling the currently active source on its own
//! rising edge, then enabling the requested source after the other enable is low.
/// Glitch-free two-input clock mux with asynchronous active-low reset.
///
/// `clkout` is low during reset and otherwise is the OR of the two input clocks
/// gated by interlocked enable flops in the respective clock domains.
module glitch_free_mux (
  input logic clk1,
  input logic clk2,
  input logic rst_n,
  input logic sel,
  output logic clkout
);

  logic clk1_en;
  logic clk2_en;
  assign clkout = (clk1 & clk1_en) | (clk2 & clk2_en);
  always_ff @(posedge clk1 or negedge rst_n) begin
    if ((!rst_n)) begin
      clk1_en <= 0;
    end else begin
      clk1_en <= !sel && !clk2_en;
    end
  end
  always_ff @(posedge clk2 or negedge rst_n) begin
    if ((!rst_n)) begin
      clk2_en <= 0;
    end else begin
      clk2_en <= sel && !clk1_en;
    end
  end

endmodule

