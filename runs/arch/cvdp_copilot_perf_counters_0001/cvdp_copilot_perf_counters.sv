//! ---
//! tags: [performance-counter, software-read, async-reset]
//! ---
//!
//! Eight-bit performance counter for CPU-triggered events with a software request that restarts the visible count at one. The counter wraps naturally and continuously exposes the current count.
/// Counts trigger events and exposes the live wrapping count.
///
/// The problem default counter width is 8 bits; CNT_W is kept as a parameter for harness compatibility, while the implementation avoids parameterized casts that Icarus can mis-handle.
module cvdp_copilot_perf_counters #(
  parameter int CNT_W = 8
) (
  input logic clk,
  input logic reset,
  input logic sw_req_i,
  input logic cpu_trig_i,
  output logic [7:0] p_count_o
);

  logic [7:0] next_count;
  logic [7:0] count_q;
  assign next_count = 8'(count_q + 8'd1);
  assign p_count_o = sw_req_i ? 8'd1 : count_q;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      count_q <= 0;
    end else begin
      if (sw_req_i) begin
        count_q <= 8'd1;
      end else if (cpu_trig_i) begin
        count_q <= next_count;
      end
    end
  end

endmodule

