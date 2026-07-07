//! ---
//! tags: [edge-detect, synchronous, async-reset]
//! refs: []
//! ---
//!
//! Synchronous positive and negative edge detector for a glitch-free debounced input. The design samples the input on i_clk, clears state with active-low asynchronous reset, and emits one-cycle registered pulses for rising and falling transitions.
/// Detects rising and falling transitions on i_detection_signal.
///
/// The previous sampled input value is retained so each transition produces a one-clock pulse on the matching output.
module sync_pos_neg_edge_detector (
  input logic i_clk,
  input logic i_rstb,
  input logic i_detection_signal,
  output logic o_positive_edge_detected,
  output logic o_negative_edge_detected
);

  logic previous_detection_signal;
  always_ff @(posedge i_clk or negedge i_rstb) begin
    if ((!i_rstb)) begin
      o_negative_edge_detected <= 0;
      o_positive_edge_detected <= 0;
      previous_detection_signal <= 0;
    end else begin
      o_positive_edge_detected <= i_detection_signal && !previous_detection_signal;
      o_negative_edge_detected <= !i_detection_signal && previous_detection_signal;
      previous_detection_signal <= i_detection_signal;
    end
  end

endmodule

