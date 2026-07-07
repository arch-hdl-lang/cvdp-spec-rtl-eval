//! ---
//! tags: [hebbian, fsm, training, logic-gates]
//! ---
//!
//! Hebbian-rule trainer for two signed bipolar inputs. The design captures each input pair, selects a bipolar target for AND/OR/NAND/NOR behavior, computes signed Hebbian deltas, and accumulates the trained weights and bias over four input samples.
/// Moore FSM implementing the Hebbian training sequence.
///
/// Timing/type notes: `clk` is sampled on the rising edge, `rst` is an asynchronous active-low reset, input samples are captured in State_1, and `w1`, `w2`, `bias`, `present_state`, and `next_state` are combinational views of FSM registers/state.
/// Transition table:
/// current | input condition | next | externally visible outputs
/// State_0 | start=1 | State_1 | weights/bias hold prior reset or completed training values; next_state=1
/// State_0 | start=0 | State_0 | weights/bias hold; next_state=0
/// State_1 | gate_select=00 | State_2 | captures a,b on this clock; next_state=2
/// State_1 | gate_select=01 | State_3 | captures a,b on this clock; next_state=3
/// State_1 | gate_select=10 | State_4 | captures a,b on this clock; next_state=4
/// State_1 | gate_select=11 | State_5 | captures a,b on this clock; next_state=5
/// State_2 | unconditional | State_6 | AND target is registered on this clock; next_state=6
/// State_3 | unconditional | State_6 | OR target is registered on this clock; next_state=6
/// State_4 | unconditional | State_6 | NAND target is registered on this clock; next_state=6
/// State_5 | unconditional | State_6 | NOR target is registered on this clock; next_state=6
/// State_6 | unconditional | State_7 | target is held for delta computation; next_state=7
/// State_7 | unconditional | State_8 | delta registers receive x1*t, x2*t, and t; next_state=8
/// State_8 | unconditional | State_9 | weights and bias accumulate deltas on this clock; next_state=9
/// State_9 | iteration<3 | State_1 | iteration counter increments; next_state=1
/// State_9 | iteration=3 | State_10 | completed four training samples; next_state=10
/// State_10 | unconditional | State_0 | final trained weights/bias remain visible; next_state=0
module hebb_gates (
  input logic clk,
  input logic rst,
  input logic start,
  input logic signed [3:0] a,
  input logic signed [3:0] b,
  input logic [1:0] gate_select,
  output logic signed [3:0] w1,
  output logic signed [3:0] w2,
  output logic signed [3:0] bias,
  output logic [3:0] present_state,
  output logic [3:0] next_state
);

  typedef enum logic [3:0] {
    STATE_0 = 4'd0,
    STATE_1 = 4'd1,
    STATE_2 = 4'd2,
    STATE_3 = 4'd3,
    STATE_4 = 4'd4,
    STATE_5 = 4'd5,
    STATE_6 = 4'd6,
    STATE_7 = 4'd7,
    STATE_8 = 4'd8,
    STATE_9 = 4'd9,
    STATE_10 = 4'd10
  } hebb_gates_state_t;
  
  hebb_gates_state_t state_r, state_next;
  
  logic signed [3:0] x1_r;
  logic signed [3:0] x2_r;
  logic signed [3:0] target_r;
  logic signed [3:0] delta_w1_r;
  logic signed [3:0] delta_w2_r;
  logic signed [3:0] delta_b_r;
  logic signed [3:0] weight1_r;
  logic signed [3:0] weight2_r;
  logic signed [3:0] bias_r;
  logic [2:0] iter_idx;
  
  logic signed [3:0] pos_val;
  assign pos_val = $signed(4'd1);
  logic signed [3:0] neg_val;
  assign neg_val = $signed(4'd15);
  logic both_pos;
  assign both_pos = x1_r == pos_val && x2_r == pos_val;
  logic any_pos;
  assign any_pos = x1_r == pos_val || x2_r == pos_val;
  logic signed [3:0] target_and;
  assign target_and = both_pos ? pos_val : neg_val;
  logic signed [3:0] target_or;
  assign target_or = any_pos ? pos_val : neg_val;
  logic signed [3:0] target_nand;
  assign target_nand = both_pos ? neg_val : pos_val;
  logic signed [3:0] target_nor;
  assign target_nor = any_pos ? neg_val : pos_val;
  logic done_four;
  assign done_four = iter_idx == 3'd3;
  logic signed [3:0] calc_delta_w1;
  assign calc_delta_w1 = 4'(x1_r * target_r);
  logic signed [3:0] calc_delta_w2;
  assign calc_delta_w2 = 4'(x2_r * target_r);
  
  always_ff @(posedge clk or negedge rst) begin
    if ((!rst)) begin
      state_r <= STATE_0;
      x1_r <= 0;
      x2_r <= 0;
      target_r <= 0;
      delta_w1_r <= 0;
      delta_w2_r <= 0;
      delta_b_r <= 0;
      weight1_r <= 0;
      weight2_r <= 0;
      bias_r <= 0;
      iter_idx <= 0;
    end else begin
      state_r <= state_next;
      unique case (state_r)
        STATE_0: begin
          if (start) begin
            x1_r <= 0;
            x2_r <= 0;
            target_r <= 0;
            delta_w1_r <= 0;
            delta_w2_r <= 0;
            delta_b_r <= 0;
            weight1_r <= 0;
            weight2_r <= 0;
            bias_r <= 0;
            iter_idx <= 0;
          end
        end
        STATE_1: begin
          x1_r <= a;
          x2_r <= b;
        end
        STATE_2: begin
          target_r <= target_and;
        end
        STATE_3: begin
          target_r <= target_or;
        end
        STATE_4: begin
          target_r <= target_nand;
        end
        STATE_5: begin
          target_r <= target_nor;
        end
        STATE_7: begin
          delta_w1_r <= calc_delta_w1;
          delta_w2_r <= calc_delta_w2;
          delta_b_r <= target_r;
        end
        STATE_8: begin
          weight1_r <= 4'(weight1_r + delta_w1_r);
          weight2_r <= 4'(weight2_r + delta_w2_r);
          bias_r <= 4'(bias_r + delta_b_r);
        end
        STATE_9: begin
          if (!done_four) begin
            iter_idx <= 3'(iter_idx + 3'd1);
          end
        end
        default: ;
      endcase
    end
  end
  
  always_comb begin
    state_next = state_r; // hold by default
    unique case (state_r)
      STATE_0: begin
        if (start) state_next = STATE_1;
      end
      STATE_1: begin
        if (gate_select == 2'd0) state_next = STATE_2;
        else if (gate_select == 2'd1) state_next = STATE_3;
        else if (gate_select == 2'd2) state_next = STATE_4;
        else if (gate_select == 2'd3) state_next = STATE_5;
      end
      STATE_2: begin
        state_next = STATE_6;
      end
      STATE_3: begin
        state_next = STATE_6;
      end
      STATE_4: begin
        state_next = STATE_6;
      end
      STATE_5: begin
        state_next = STATE_6;
      end
      STATE_6: begin
        state_next = STATE_7;
      end
      STATE_7: begin
        state_next = STATE_8;
      end
      STATE_8: begin
        state_next = STATE_9;
      end
      STATE_9: begin
        if (done_four) state_next = STATE_10;
        else if (!done_four) state_next = STATE_1;
      end
      STATE_10: begin
        state_next = STATE_0;
      end
      default: state_next = state_r;
    endcase
  end
  
  always_comb begin
    w1 = weight1_r;
    w2 = weight2_r;
    bias = bias_r;
    present_state = 4'd0;
    next_state = 4'd0;
    unique case (state_r)
      STATE_0: begin
        present_state = 4'd0;
        if (start) begin
          next_state = 4'd1;
        end else begin
          next_state = 4'd0;
        end
      end
      STATE_1: begin
        present_state = 4'd1;
        if (gate_select == 2'd0) begin
          next_state = 4'd2;
        end else if (gate_select == 2'd1) begin
          next_state = 4'd3;
        end else if (gate_select == 2'd2) begin
          next_state = 4'd4;
        end else begin
          next_state = 4'd5;
        end
      end
      STATE_2: begin
        present_state = 4'd2;
        next_state = 4'd6;
      end
      STATE_3: begin
        present_state = 4'd3;
        next_state = 4'd6;
      end
      STATE_4: begin
        present_state = 4'd4;
        next_state = 4'd6;
      end
      STATE_5: begin
        present_state = 4'd5;
        next_state = 4'd6;
      end
      STATE_6: begin
        present_state = 4'd6;
        next_state = 4'd7;
      end
      STATE_7: begin
        present_state = 4'd7;
        next_state = 4'd8;
      end
      STATE_8: begin
        present_state = 4'd8;
        next_state = 4'd9;
      end
      STATE_9: begin
        present_state = 4'd9;
        if (done_four) begin
          next_state = 4'd10;
        end else begin
          next_state = 4'd1;
        end
      end
      STATE_10: begin
        present_state = 4'd10;
        next_state = 4'd0;
      end
      default: ;
    endcase
  end
  
  // synopsys translate_off
  _auto_legal_state: assert property (@(posedge clk) rst |-> state_r < 11)
    else $fatal(1, "FSM ILLEGAL STATE: hebb_gates.state_r = %0d", state_r);
  _auto_reach_State_0: cover property (@(posedge clk) state_r == STATE_0);
  _auto_reach_State_1: cover property (@(posedge clk) state_r == STATE_1);
  _auto_reach_State_2: cover property (@(posedge clk) state_r == STATE_2);
  _auto_reach_State_3: cover property (@(posedge clk) state_r == STATE_3);
  _auto_reach_State_4: cover property (@(posedge clk) state_r == STATE_4);
  _auto_reach_State_5: cover property (@(posedge clk) state_r == STATE_5);
  _auto_reach_State_6: cover property (@(posedge clk) state_r == STATE_6);
  _auto_reach_State_7: cover property (@(posedge clk) state_r == STATE_7);
  _auto_reach_State_8: cover property (@(posedge clk) state_r == STATE_8);
  _auto_reach_State_9: cover property (@(posedge clk) state_r == STATE_9);
  _auto_reach_State_10: cover property (@(posedge clk) state_r == STATE_10);
  _auto_tr_STATE_0_to_STATE_1: cover property (@(posedge clk) state_r == STATE_0 && state_next == STATE_1);
  _auto_tr_STATE_1_to_STATE_2: cover property (@(posedge clk) state_r == STATE_1 && state_next == STATE_2);
  _auto_tr_STATE_1_to_STATE_3: cover property (@(posedge clk) state_r == STATE_1 && state_next == STATE_3);
  _auto_tr_STATE_1_to_STATE_4: cover property (@(posedge clk) state_r == STATE_1 && state_next == STATE_4);
  _auto_tr_STATE_1_to_STATE_5: cover property (@(posedge clk) state_r == STATE_1 && state_next == STATE_5);
  _auto_tr_STATE_2_to_STATE_6: cover property (@(posedge clk) state_r == STATE_2 && state_next == STATE_6);
  _auto_tr_STATE_3_to_STATE_6: cover property (@(posedge clk) state_r == STATE_3 && state_next == STATE_6);
  _auto_tr_STATE_4_to_STATE_6: cover property (@(posedge clk) state_r == STATE_4 && state_next == STATE_6);
  _auto_tr_STATE_5_to_STATE_6: cover property (@(posedge clk) state_r == STATE_5 && state_next == STATE_6);
  _auto_tr_STATE_6_to_STATE_7: cover property (@(posedge clk) state_r == STATE_6 && state_next == STATE_7);
  _auto_tr_STATE_7_to_STATE_8: cover property (@(posedge clk) state_r == STATE_7 && state_next == STATE_8);
  _auto_tr_STATE_8_to_STATE_9: cover property (@(posedge clk) state_r == STATE_8 && state_next == STATE_9);
  _auto_tr_STATE_9_to_STATE_10: cover property (@(posedge clk) state_r == STATE_9 && state_next == STATE_10);
  _auto_tr_STATE_9_to_STATE_1: cover property (@(posedge clk) state_r == STATE_9 && state_next == STATE_1);
  _auto_tr_STATE_10_to_STATE_0: cover property (@(posedge clk) state_r == STATE_10 && state_next == STATE_0);
  // synopsys translate_on

endmodule

