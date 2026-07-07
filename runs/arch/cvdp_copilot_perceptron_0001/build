//! ---
//! tags: [perceptron, microcode, training, gates]
//! ---
//!
//! Microcoded perceptron trainer for the CVDP perceptron_gates task. The module sequences initialization, response calculation,
//! target selection, update, convergence check, and iteration advance on the rising clock edge.
/// Sequential microcoded controller for training a small signed perceptron on gate targets.
///
/// The controller exposes registered state for weights, bias, microcode address, selected input index,
/// thresholded response, and convergence status.
module perceptron_gates (
  input logic clk,
  input logic rst_n,
  input logic signed [3:0] x1,
  input logic signed [3:0] x2,
  input logic learning_rate,
  input logic signed [3:0] threshold,
  input logic [1:0] gate_select,
  output logic signed [3:0] percep_w1,
  output logic signed [3:0] percep_w2,
  output logic signed [3:0] percep_bias,
  output logic [3:0] present_addr,
  output logic stop,
  output logic [2:0] input_index,
  output logic signed [3:0] y_in,
  output logic signed [3:0] y,
  output logic signed [3:0] prev_percep_wt_1,
  output logic signed [3:0] prev_percep_wt_2,
  output logic signed [3:0] prev_percep_bias
);

  logic signed [3:0] prod1_now;
  logic signed [3:0] prod2_now;
  logic signed [3:0] sum_products;
  logic signed [3:0] weighted_sum;
  logic need_update;
  logic update_is_nonzero;
  logic epoch_done;
  logic epoch_converged;
  logic signed [3:0] target_hold;
  logic signed [3:0] delta_w1;
  logic signed [3:0] delta_w2;
  logic signed [3:0] delta_bias;
  logic epoch_changed;
  assign prod1_now = 4'(x1 * percep_w1);
  assign prod2_now = 4'(x2 * percep_w2);
  assign sum_products = 4'(prod1_now + prod2_now);
  assign weighted_sum = 4'(percep_bias + sum_products);
  logic signed [3:0] response_now;
  logic signed [3:0] selected_target;
  assign need_update = learning_rate && y != target_hold;
  logic signed [3:0] wt1_update_now;
  logic signed [3:0] wt2_update_now;
  logic signed [3:0] bias_update_now;
  assign update_is_nonzero = delta_w1 != 0 || delta_w2 != 0 || delta_bias != 0;
  assign epoch_done = input_index == 3;
  assign epoch_converged = epoch_done && !epoch_changed && !update_is_nonzero;
  always_comb begin
    if (weighted_sum > threshold) begin
      response_now = 1;
    end else if (weighted_sum == threshold) begin
      response_now = 0;
    end else begin
      response_now = -1;
    end
  end
  always_comb begin
    selected_target = -1;
    if (gate_select == 0) begin
      if (input_index == 0) begin
        selected_target = 1;
      end else begin
        selected_target = -1;
      end
    end else if (gate_select == 1) begin
      if (input_index == 3) begin
        selected_target = -1;
      end else begin
        selected_target = 1;
      end
    end else if (gate_select == 2) begin
      if (input_index == 3) begin
        selected_target = -1;
      end else begin
        selected_target = 1;
      end
    end else if (input_index == 0) begin
      selected_target = 1;
    end else begin
      selected_target = -1;
    end
  end
  always_comb begin
    if (need_update) begin
      wt1_update_now = 4'(x1 * target_hold);
      wt2_update_now = 4'(x2 * target_hold);
      bias_update_now = target_hold;
    end else begin
      wt1_update_now = 0;
      wt2_update_now = 0;
      bias_update_now = 0;
    end
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if ((!rst_n)) begin
      delta_bias <= 0;
      delta_w1 <= 0;
      delta_w2 <= 0;
      epoch_changed <= 0;
      input_index <= 0;
      percep_bias <= 0;
      percep_w1 <= 0;
      percep_w2 <= 0;
      present_addr <= 0;
      prev_percep_bias <= 0;
      prev_percep_wt_1 <= 0;
      prev_percep_wt_2 <= 0;
      stop <= 1'b0;
      target_hold <= 0;
      y <= 0;
      y_in <= 0;
    end else begin
      if (present_addr == 0) begin
        percep_w1 <= 0;
        percep_w2 <= 0;
        percep_bias <= 0;
        y_in <= 0;
        y <= 0;
        stop <= 1'b0;
        input_index <= 0;
        prev_percep_wt_1 <= 0;
        prev_percep_wt_2 <= 0;
        prev_percep_bias <= 0;
        target_hold <= 0;
        delta_w1 <= 0;
        delta_w2 <= 0;
        delta_bias <= 0;
        epoch_changed <= 1'b0;
        present_addr <= 1;
      end else if (present_addr == 1) begin
        y_in <= weighted_sum;
        y <= response_now;
        present_addr <= 2;
      end else if (present_addr == 2) begin
        target_hold <= selected_target;
        present_addr <= 3;
      end else if (present_addr == 3) begin
        delta_w1 <= wt1_update_now;
        delta_w2 <= wt2_update_now;
        delta_bias <= bias_update_now;
        percep_w1 <= (4 > $bits(wt1_update_now) ? 4 : $bits(wt1_update_now))'(percep_w1 + wt1_update_now);
        percep_w2 <= (4 > $bits(wt2_update_now) ? 4 : $bits(wt2_update_now))'(percep_w2 + wt2_update_now);
        percep_bias <= (4 > $bits(bias_update_now) ? 4 : $bits(bias_update_now))'(percep_bias + bias_update_now);
        if (wt1_update_now != 0 || wt2_update_now != 0 || bias_update_now != 0) begin
          epoch_changed <= 1'b1;
        end else begin
          epoch_changed <= epoch_changed;
        end
        present_addr <= 4;
      end else if (present_addr == 4) begin
        if (epoch_converged) begin
          stop <= 1'b1;
        end else begin
          stop <= stop;
        end
        present_addr <= 5;
      end else begin
        prev_percep_wt_1 <= delta_w1;
        prev_percep_wt_2 <= delta_w2;
        prev_percep_bias <= delta_bias;
        if (stop) begin
          present_addr <= 5;
          input_index <= input_index;
          epoch_changed <= epoch_changed;
        end else begin
          present_addr <= 1;
          if (input_index == 3) begin
            input_index <= 0;
            epoch_changed <= 1'b0;
          end else begin
            input_index <= (3 > 1 ? 3 : 1)'(input_index + 1);
          end
        end
      end
    end
  end

endmodule

