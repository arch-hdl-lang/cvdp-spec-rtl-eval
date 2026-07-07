//! ---
//! tags: [dice, fsm, counter, button, reset]
//! refs: []
//! ---
//!
//! Digital dice roller generated from the CVDP natural-language specification.
//! The design cycles a 1-to-DICE_MAX display value while the button is pressed, then holds the last value after release.
/// Two-state digital dice roller FSM.
///
/// Timing: `button` is sampled on the rising edge of `clk`; `reset` is asynchronous active-low.
/// `dice_value` is a registered, externally visible display value that is reset to `001`, advances while rolling,
/// and holds the last rolled value after release.
///
/// Transition table:
/// current state | input condition | next state | externally visible output/action
/// IDLE          | button == 0     | IDLE       | dice_value holds its displayed register
/// IDLE          | button == 1     | ROLLING    | dice_value advances modulo 1..DICE_MAX on this edge
/// ROLLING       | button == 1     | ROLLING    | dice_value advances modulo 1..DICE_MAX on this edge
/// ROLLING       | button == 0     | IDLE       | dice_value holds the last rolled value
module digital_dice_roller #(
  parameter int DICE_MAX = 6
) (
  input logic clk,
  input logic reset,
  input logic button,
  output logic [2:0] dice_value
);

  typedef enum logic [0:0] {
    IDLE = 1'd0,
    ROLLING = 1'd1
  } digital_dice_roller_state_t;
  
  digital_dice_roller_state_t state_r, state_next;
  
  logic [2:0] shown_value;
  
  logic [2:0] dice_max_value;
  assign dice_max_value = DICE_MAX;
  logic roll_wrap;
  assign roll_wrap = shown_value == 3'd0 || shown_value == dice_max_value;
  logic [2:0] roll_next;
  assign roll_next = roll_wrap ? 3'd1 : 3'(shown_value + 3'd1);
  assign dice_value = shown_value;
  
  always_ff @(posedge clk or negedge reset) begin
    if ((!reset)) begin
      state_r <= IDLE;
      shown_value <= 3'd1;
    end else begin
      state_r <= state_next;
      unique case (state_r)
        IDLE: begin
          if (button) begin
            shown_value <= roll_next;
          end
        end
        ROLLING: begin
          if (button) begin
            shown_value <= roll_next;
          end
        end
        default: ;
      endcase
    end
  end
  
  always_comb begin
    state_next = state_r; // hold by default
    unique case (state_r)
      IDLE: begin
        if (button) state_next = ROLLING;
      end
      ROLLING: begin
        if (!button) state_next = IDLE;
      end
      default: state_next = state_r;
    endcase
  end
  
  always_comb begin
    unique case (state_r)
      IDLE: begin
      end
      ROLLING: begin
      end
      default: ;
    endcase
  end
  
  // synopsys translate_off
  _auto_reach_IDLE: cover property (@(posedge clk) state_r == IDLE);
  _auto_reach_ROLLING: cover property (@(posedge clk) state_r == ROLLING);
  _auto_tr_IDLE_to_ROLLING: cover property (@(posedge clk) state_r == IDLE && state_next == ROLLING);
  _auto_tr_ROLLING_to_IDLE: cover property (@(posedge clk) state_r == ROLLING && state_next == IDLE);
  // synopsys translate_on

endmodule

