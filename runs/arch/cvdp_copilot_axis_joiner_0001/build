//! ---
//! tags: [axis, stream, joiner, fsm, buffering]
//! refs: []
//! ---
//!
//! Three AXI Stream inputs are packet-joined onto one AXI Stream output.
//! The controller selects one source at a time, tags output data with the
//! source ID, and holds one stalled output beat in a temporary buffer.
/// Packet-level AXI Stream joiner for three 8-bit sources.
///
/// Input sampling and state transitions occur on the rising edge of clk with
/// an asynchronous active-high reset. Outputs are combinational from the
/// current FSM state and the temporary stall buffer.
module axis_joiner (
  input logic clk,
  input logic rst,
  input logic [7:0] s_axis_tdata_1,
  input logic s_axis_tvalid_1,
  output logic s_axis_tready_1,
  input logic s_axis_tlast_1,
  input logic [7:0] s_axis_tdata_2,
  input logic s_axis_tvalid_2,
  output logic s_axis_tready_2,
  input logic s_axis_tlast_2,
  input logic [7:0] s_axis_tdata_3,
  input logic s_axis_tvalid_3,
  output logic s_axis_tready_3,
  input logic s_axis_tlast_3,
  output logic [7:0] m_axis_tdata,
  output logic m_axis_tvalid,
  input logic m_axis_tready,
  output logic m_axis_tlast,
  output logic [1:0] m_axis_tuser,
  output logic busy
);

  typedef enum logic [1:0] {
    STATE_IDLE = 2'd0,
    STATE_1 = 2'd1,
    STATE_2 = 2'd2,
    STATE_3 = 2'd3
  } axis_joiner_state_t;
  
  axis_joiner_state_t state_r, state_next;
  
  logic temp_valid;
  logic [7:0] temp_data;
  logic temp_last;
  logic [1:0] temp_user;
  
  logic can_select;
  assign can_select = !temp_valid;
  logic take_1;
  assign take_1 = can_select && s_axis_tvalid_1;
  logic take_2;
  assign take_2 = can_select && s_axis_tvalid_2;
  logic take_3;
  assign take_3 = can_select && s_axis_tvalid_3;
  logic stall_output;
  assign stall_output = !m_axis_tready;
  
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state_r <= STATE_IDLE;
      temp_valid <= 1'b0;
      temp_data <= 0;
      temp_last <= 1'b0;
      temp_user <= 0;
    end else begin
      state_r <= state_next;
      unique case (state_r)
        STATE_IDLE: begin
          if (temp_valid && m_axis_tready) begin
            temp_valid <= 1'b0;
          end
        end
        STATE_1: begin
          if (temp_valid && m_axis_tready) begin
            temp_valid <= 1'b0;
          end else if (!temp_valid && s_axis_tvalid_1 && stall_output) begin
            temp_valid <= 1'b1;
            temp_data <= s_axis_tdata_1;
            temp_last <= s_axis_tlast_1;
            temp_user <= 2'd1;
          end
        end
        STATE_2: begin
          if (temp_valid && m_axis_tready) begin
            temp_valid <= 1'b0;
          end else if (!temp_valid && s_axis_tvalid_2 && stall_output) begin
            temp_valid <= 1'b1;
            temp_data <= s_axis_tdata_2;
            temp_last <= s_axis_tlast_2;
            temp_user <= 2'd2;
          end
        end
        STATE_3: begin
          if (temp_valid && m_axis_tready) begin
            temp_valid <= 1'b0;
          end else if (!temp_valid && s_axis_tvalid_3 && stall_output) begin
            temp_valid <= 1'b1;
            temp_data <= s_axis_tdata_3;
            temp_last <= s_axis_tlast_3;
            temp_user <= 2'd3;
          end
        end
        default: ;
      endcase
    end
  end
  
  always_comb begin
    state_next = state_r; // hold by default
    unique case (state_r)
      STATE_IDLE: begin
        if (can_select && s_axis_tvalid_1) state_next = STATE_1;
        else if (can_select && !s_axis_tvalid_1 && s_axis_tvalid_2) state_next = STATE_2;
        else if (can_select && !s_axis_tvalid_1 && !s_axis_tvalid_2 && s_axis_tvalid_3) state_next = STATE_3;
      end
      STATE_1: begin
        if (take_1 && s_axis_tlast_1) state_next = STATE_IDLE;
      end
      STATE_2: begin
        if (take_2 && s_axis_tlast_2) state_next = STATE_IDLE;
      end
      STATE_3: begin
        if (take_3 && s_axis_tlast_3) state_next = STATE_IDLE;
      end
      default: state_next = state_r;
    endcase
  end
  
  always_comb begin
    s_axis_tready_1 = 1'b0;
    s_axis_tready_2 = 1'b0;
    s_axis_tready_3 = 1'b0;
    m_axis_tdata = 0;
    m_axis_tvalid = 1'b0;
    m_axis_tlast = 1'b0;
    m_axis_tuser = 0;
    busy = temp_valid;
    unique case (state_r)
      STATE_IDLE: begin
        if (temp_valid) begin
          m_axis_tdata = temp_data;
          m_axis_tvalid = 1'b1;
          m_axis_tlast = temp_last;
          m_axis_tuser = temp_user;
          busy = 1'b1;
        end else begin
          busy = 1'b0;
        end
      end
      STATE_1: begin
        busy = 1'b1;
        if (temp_valid) begin
          m_axis_tdata = temp_data;
          m_axis_tvalid = 1'b1;
          m_axis_tlast = temp_last;
          m_axis_tuser = temp_user;
        end else begin
          s_axis_tready_1 = 1'b1;
          m_axis_tdata = s_axis_tdata_1;
          m_axis_tvalid = s_axis_tvalid_1;
          m_axis_tlast = s_axis_tlast_1;
          m_axis_tuser = 2'd1;
        end
      end
      STATE_2: begin
        busy = 1'b1;
        if (temp_valid) begin
          m_axis_tdata = temp_data;
          m_axis_tvalid = 1'b1;
          m_axis_tlast = temp_last;
          m_axis_tuser = temp_user;
        end else begin
          s_axis_tready_2 = 1'b1;
          m_axis_tdata = s_axis_tdata_2;
          m_axis_tvalid = s_axis_tvalid_2;
          m_axis_tlast = s_axis_tlast_2;
          m_axis_tuser = 2'd2;
        end
      end
      STATE_3: begin
        busy = 1'b1;
        if (temp_valid) begin
          m_axis_tdata = temp_data;
          m_axis_tvalid = 1'b1;
          m_axis_tlast = temp_last;
          m_axis_tuser = temp_user;
        end else begin
          s_axis_tready_3 = 1'b1;
          m_axis_tdata = s_axis_tdata_3;
          m_axis_tvalid = s_axis_tvalid_3;
          m_axis_tlast = s_axis_tlast_3;
          m_axis_tuser = 2'd3;
        end
      end
      default: ;
    endcase
  end
  
  // synopsys translate_off
  _auto_reach_STATE_IDLE: cover property (@(posedge clk) state_r == STATE_IDLE);
  _auto_reach_STATE_1: cover property (@(posedge clk) state_r == STATE_1);
  _auto_reach_STATE_2: cover property (@(posedge clk) state_r == STATE_2);
  _auto_reach_STATE_3: cover property (@(posedge clk) state_r == STATE_3);
  _auto_tr_STATE_IDLE_to_STATE_1: cover property (@(posedge clk) state_r == STATE_IDLE && state_next == STATE_1);
  _auto_tr_STATE_IDLE_to_STATE_2: cover property (@(posedge clk) state_r == STATE_IDLE && state_next == STATE_2);
  _auto_tr_STATE_IDLE_to_STATE_3: cover property (@(posedge clk) state_r == STATE_IDLE && state_next == STATE_3);
  _auto_tr_STATE_1_to_STATE_IDLE: cover property (@(posedge clk) state_r == STATE_1 && state_next == STATE_IDLE);
  _auto_tr_STATE_2_to_STATE_IDLE: cover property (@(posedge clk) state_r == STATE_2 && state_next == STATE_IDLE);
  _auto_tr_STATE_3_to_STATE_IDLE: cover property (@(posedge clk) state_r == STATE_3 && state_next == STATE_IDLE);
  // synopsys translate_on

endmodule

