//! ---
//! tags: [arbiter, fsm, bus, priority]
//! ---
//!
//! Two-master shared-bus arbiter with active-high asynchronous reset. Master 2 has priority whenever both requests are asserted, and a CLEAR state deasserts both grants after requests are released.
/// Two-requester bus arbiter implemented as a first-class FSM.
///
/// Timing: `req1` and `req2` are sampled for the next-state decision on the rising edge of `clk`; `reset` is active high and asynchronous. `grant1` and `grant2` are state-derived outputs, visible as soon as the FSM state updates or reset returns the FSM to IDLE.
///
/// Transition table:
/// Current state | Input condition | Next state | Externally visible outputs for resulting state
/// IDLE          | req2             | GRANT_2    | grant1=0, grant2=1
/// IDLE          | !req2 && req1    | GRANT_1    | grant1=1, grant2=0
/// IDLE          | !req1 && !req2   | IDLE       | grant1=0, grant2=0
/// GRANT_1       | req2             | GRANT_2    | grant1=0, grant2=1
/// GRANT_1       | !req2 && req1    | GRANT_1    | grant1=1, grant2=0
/// GRANT_1       | !req1 && !req2   | CLEAR      | grant1=0, grant2=0
/// GRANT_2       | req2             | GRANT_2    | grant1=0, grant2=1
/// GRANT_2       | !req2 && req1    | GRANT_1    | grant1=1, grant2=0
/// GRANT_2       | !req1 && !req2   | CLEAR      | grant1=0, grant2=0
/// CLEAR         | req2             | GRANT_2    | grant1=0, grant2=1
/// CLEAR         | !req2 && req1    | GRANT_1    | grant1=1, grant2=0
/// CLEAR         | !req1 && !req2   | IDLE       | grant1=0, grant2=0
module cvdp_copilot_bus_arbiter (
  input logic clk,
  input logic reset,
  input logic req1,
  input logic req2,
  output logic grant1,
  output logic grant2
);

  typedef enum logic [1:0] {
    IDLE = 2'd0,
    GRANT_1 = 2'd1,
    GRANT_2 = 2'd2,
    CLEAR = 2'd3
  } cvdp_copilot_bus_arbiter_state_t;
  
  cvdp_copilot_bus_arbiter_state_t state_r, state_next;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state_r <= IDLE;
    end else begin
      state_r <= state_next;
    end
  end
  
  always_comb begin
    state_next = state_r; // hold by default
    unique case (state_r)
      IDLE: begin
        if (req2) state_next = GRANT_2;
        else if (!req2 && req1) state_next = GRANT_1;
      end
      GRANT_1: begin
        if (req2) state_next = GRANT_2;
        else if (!req1 && !req2) state_next = CLEAR;
      end
      GRANT_2: begin
        if (req2) state_next = GRANT_2;
        else if (!req2 && req1) state_next = GRANT_1;
        else if (!req1 && !req2) state_next = CLEAR;
      end
      CLEAR: begin
        if (req2) state_next = GRANT_2;
        else if (!req2 && req1) state_next = GRANT_1;
        else if (!req1 && !req2) state_next = IDLE;
      end
      default: state_next = state_r;
    endcase
  end
  
  always_comb begin
    grant1 = 1'b0;
    grant2 = 1'b0;
    unique case (state_r)
      IDLE: begin
      end
      GRANT_1: begin
        grant1 = 1'b1;
      end
      GRANT_2: begin
        grant2 = 1'b1;
      end
      CLEAR: begin
      end
      default: ;
    endcase
  end
  
  // synopsys translate_off
  _auto_reach_IDLE: cover property (@(posedge clk) state_r == IDLE);
  _auto_reach_GRANT_1: cover property (@(posedge clk) state_r == GRANT_1);
  _auto_reach_GRANT_2: cover property (@(posedge clk) state_r == GRANT_2);
  _auto_reach_CLEAR: cover property (@(posedge clk) state_r == CLEAR);
  _auto_tr_IDLE_to_GRANT_2: cover property (@(posedge clk) state_r == IDLE && state_next == GRANT_2);
  _auto_tr_IDLE_to_GRANT_1: cover property (@(posedge clk) state_r == IDLE && state_next == GRANT_1);
  _auto_tr_GRANT_1_to_GRANT_2: cover property (@(posedge clk) state_r == GRANT_1 && state_next == GRANT_2);
  _auto_tr_GRANT_1_to_CLEAR: cover property (@(posedge clk) state_r == GRANT_1 && state_next == CLEAR);
  _auto_tr_GRANT_2_to_GRANT_2: cover property (@(posedge clk) state_r == GRANT_2 && state_next == GRANT_2);
  _auto_tr_GRANT_2_to_GRANT_1: cover property (@(posedge clk) state_r == GRANT_2 && state_next == GRANT_1);
  _auto_tr_GRANT_2_to_CLEAR: cover property (@(posedge clk) state_r == GRANT_2 && state_next == CLEAR);
  _auto_tr_CLEAR_to_GRANT_2: cover property (@(posedge clk) state_r == CLEAR && state_next == GRANT_2);
  _auto_tr_CLEAR_to_GRANT_1: cover property (@(posedge clk) state_r == CLEAR && state_next == GRANT_1);
  _auto_tr_CLEAR_to_IDLE: cover property (@(posedge clk) state_r == CLEAR && state_next == IDLE);
  // synopsys translate_on

endmodule

