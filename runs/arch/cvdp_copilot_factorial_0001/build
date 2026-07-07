//! ---
//! tags: [factorial, fsm, iterative, arithmetic]
//! ---
//!
//! Iterative factorial unit for the CVDP factorial prompt. The unit accepts
//! `start` in IDLE, performs one multiply per BUSY cycle, and presents `done`
//! for one cycle with the 64-bit factorial result.
/// Three-state factorial controller and datapath.
///
/// Timing/type notes: `clk` samples inputs on rising edges, `arst_n` is an
/// asynchronous active-low reset, `busy` and `done` are state-derived
/// combinational outputs, and `fact` is driven from a registered result.
/// Transition table:
/// input condition                  | current state | next state | output
/// reset asserted                   | any           | IDLE       | busy=0, done=0, fact=1
/// start=0                          | IDLE          | IDLE       | busy=0, done=0
/// start=1 and num_in=0             | IDLE          | DONE       | fact assigned 1, visible with done next cycle
/// start=1 and num_in!=0            | IDLE          | BUSY       | load count and accumulator
/// factor_r!=1                      | BUSY          | BUSY       | busy=1, multiply once this cycle
/// factor_r==1                      | BUSY          | DONE       | busy=1, final multiply this cycle; done next cycle
/// unconditional                    | DONE          | IDLE       | done=1 for one cycle with fact
module factorial (
  input logic clk,
  input logic arst_n,
  input logic [4:0] num_in,
  input logic start,
  output logic busy,
  output logic [63:0] fact,
  output logic done
);

  typedef enum logic [1:0] {
    IDLE = 2'd0,
    BUSY = 2'd1,
    DONE = 2'd2
  } factorial_state_t;
  
  factorial_state_t state_r, state_next;
  
  logic [63:0] acc_r;
  logic [63:0] fact_r;
  logic [4:0] factor_r;
  
  logic [63:0] factor_wide;
  assign factor_wide = 64'($unsigned(factor_r));
  logic [63:0] product;
  assign product = (64 > $bits(factor_wide) ? 64 : $bits(factor_wide))'(acc_r * factor_wide);
  logic [4:0] factor_dec;
  assign factor_dec = (5 > 1 ? 5 : 1)'(factor_r - 1);
  assign fact = fact_r;
  
  always_ff @(posedge clk or negedge arst_n) begin
    if ((!arst_n)) begin
      state_r <= IDLE;
      acc_r <= 64'd1;
      fact_r <= 64'd1;
      factor_r <= 0;
    end else begin
      state_r <= state_next;
      unique case (state_r)
        IDLE: begin
          if (start) begin
            acc_r <= 64'd1;
            fact_r <= 64'd1;
            factor_r <= num_in;
          end
        end
        BUSY: begin
          acc_r <= product;
          fact_r <= product;
          factor_r <= factor_dec;
        end
        default: ;
      endcase
    end
  end
  
  always_comb begin
    state_next = state_r; // hold by default
    unique case (state_r)
      IDLE: begin
        if (start && num_in == 0) state_next = DONE;
        else if (start && num_in != 0) state_next = BUSY;
      end
      BUSY: begin
        if (factor_r == 1) state_next = DONE;
      end
      DONE: begin
        state_next = IDLE;
      end
      default: state_next = state_r;
    endcase
  end
  
  always_comb begin
    busy = 1'b0;
    done = 1'b0;
    unique case (state_r)
      IDLE: begin
      end
      BUSY: begin
        busy = 1'b1;
      end
      DONE: begin
        done = 1'b1;
      end
      default: ;
    endcase
  end
  
  // synopsys translate_off
  _auto_legal_state: assert property (@(posedge clk) arst_n |-> state_r < 3)
    else $fatal(1, "FSM ILLEGAL STATE: factorial.state_r = %0d", state_r);
  _auto_reach_IDLE: cover property (@(posedge clk) state_r == IDLE);
  _auto_reach_BUSY: cover property (@(posedge clk) state_r == BUSY);
  _auto_reach_DONE: cover property (@(posedge clk) state_r == DONE);
  _auto_tr_IDLE_to_DONE: cover property (@(posedge clk) state_r == IDLE && state_next == DONE);
  _auto_tr_IDLE_to_BUSY: cover property (@(posedge clk) state_r == IDLE && state_next == BUSY);
  _auto_tr_BUSY_to_DONE: cover property (@(posedge clk) state_r == BUSY && state_next == DONE);
  _auto_tr_DONE_to_IDLE: cover property (@(posedge clk) state_r == DONE && state_next == IDLE);
  // synopsys translate_on

endmodule

