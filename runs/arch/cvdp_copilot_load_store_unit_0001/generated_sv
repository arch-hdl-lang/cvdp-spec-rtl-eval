//! ---
//! tags: [load_store, memory_stage, data_cache, ready_valid]
//! ---
//!
//! Load/store unit for a five-stage processor memory-access stage. It accepts aligned EX load/store requests, drives a data-cache request until grant, and returns load responses to writeback one cycle after memory read-valid.
/// Load/store unit controlling a single outstanding data-cache transaction.
///
/// Input timing: EX request/control and memory grant/read-valid are sampled on the rising edge of `clk`; `rst_n` is an active-low asynchronous reset.
/// Output timing: data-cache request outputs and EX ready are state-derived/combinational after registered state changes; writeback valid/data are visible in `Resp`, one cycle after sampled `dmem_rvalid_i`.
///
/// Transition table:
/// | Current state | Input condition | Next state | Externally visible outputs in current state |
/// | Idle | `ex_if_req_i && aligned` | Req | `ex_if_ready_o=1`, no data-cache request, `wb_if_rvalid_o=0` |
/// | Idle | otherwise | Idle | `ex_if_ready_o=1`, no data-cache request, `wb_if_rvalid_o=0` |
/// | Req | `dmem_gnt_i && saved write` | Idle | `dmem_req_o=1`, saved address/control/write-data, ready low |
/// | Req | `dmem_gnt_i && saved load` | WaitLoad | `dmem_req_o=1`, saved address/control, ready low |
/// | Req | otherwise | Req | data-cache request remains asserted, ready low |
/// | WaitLoad | `dmem_rvalid_i` | Resp | no data-cache request, ready low |
/// | WaitLoad | otherwise | WaitLoad | no data-cache request, ready low |
/// | Resp | `ex_if_req_i && aligned` | Req | `ex_if_ready_o=1`, `wb_if_rvalid_o=1` for one cycle, held read data on `wb_if_rdata_o` |
/// | Resp | otherwise | Idle | `ex_if_ready_o=1`, `wb_if_rvalid_o=1` for one cycle, held read data on `wb_if_rdata_o` |
module load_store_unit (
  input logic clk,
  input logic rst_n,
  output logic dmem_req_o,
  input logic dmem_gnt_i,
  output logic [31:0] dmem_req_addr_o,
  output logic dmem_req_we_o,
  output logic [3:0] dmem_req_be_o,
  output logic [31:0] dmem_req_wdata_o,
  input logic dmem_rvalid_i,
  input logic [31:0] dmem_rsp_rdata_i,
  input logic ex_if_req_i,
  input logic ex_if_we_i,
  input logic [1:0] ex_if_type_i,
  input logic [31:0] ex_if_wdata_i,
  input logic [31:0] ex_if_addr_base_i,
  input logic [31:0] ex_if_addr_offset_i,
  output logic ex_if_ready_o,
  output logic [31:0] wb_if_rdata_o,
  output logic wb_if_rvalid_o
);

  typedef enum logic [1:0] {
    IDLE = 2'd0,
    REQ = 2'd1,
    WAITLOAD = 2'd2,
    RESP = 2'd3
  } load_store_unit_state_t;
  
  load_store_unit_state_t state_r, state_next;
  
  logic [31:0] req_addr_r;
  logic req_we_r;
  logic [3:0] req_be_r;
  logic [31:0] req_wdata_r;
  logic [31:0] rsp_data_r;
  
  logic [31:0] eff_addr;
  assign eff_addr = 32'(ex_if_addr_base_i + ex_if_addr_offset_i);
  logic [1:0] addr_lsb;
  assign addr_lsb = eff_addr[1:0];
  logic is_byte_req;
  assign is_byte_req = ex_if_type_i == 2'd0;
  logic is_half_req;
  assign is_half_req = ex_if_type_i == 2'd1;
  logic is_word_req;
  assign is_word_req = ex_if_type_i == 2'd2;
  logic half_aligned;
  assign half_aligned = addr_lsb[0] == 1'd0;
  logic word_aligned;
  assign word_aligned = addr_lsb == 2'd0;
  logic aligned_req;
  assign aligned_req = is_byte_req || is_half_req && half_aligned || is_word_req && word_aligned;
  logic accept_req;
  assign accept_req = ex_if_req_i && aligned_req;
  logic [3:0] next_be;
  assign next_be = is_word_req ? 4'd15 : is_half_req ? addr_lsb[1] ? 4'd12 : 4'd3 : addr_lsb == 2'd0 ? 4'd1 : addr_lsb == 2'd1 ? 4'd2 : addr_lsb == 2'd2 ? 4'd4 : 4'd8;
  
  always_ff @(posedge clk or negedge rst_n) begin
    if ((!rst_n)) begin
      state_r <= IDLE;
      req_addr_r <= 0;
      req_we_r <= 1'b0;
      req_be_r <= 0;
      req_wdata_r <= 0;
      rsp_data_r <= 0;
    end else begin
      state_r <= state_next;
      unique case (state_r)
        IDLE: begin
          if (accept_req) begin
            req_addr_r <= eff_addr;
            req_we_r <= ex_if_we_i;
            req_be_r <= next_be;
            req_wdata_r <= ex_if_wdata_i;
          end
        end
        WAITLOAD: begin
          if (dmem_rvalid_i) begin
            rsp_data_r <= dmem_rsp_rdata_i;
          end
        end
        RESP: begin
          if (accept_req) begin
            req_addr_r <= eff_addr;
            req_we_r <= ex_if_we_i;
            req_be_r <= next_be;
            req_wdata_r <= ex_if_wdata_i;
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
        if (accept_req) state_next = REQ;
      end
      REQ: begin
        if (dmem_gnt_i && req_we_r) state_next = IDLE;
        else if (dmem_gnt_i && !req_we_r) state_next = WAITLOAD;
      end
      WAITLOAD: begin
        if (dmem_rvalid_i) state_next = RESP;
      end
      RESP: begin
        if (accept_req) state_next = REQ;
        else state_next = IDLE;
      end
      default: state_next = state_r;
    endcase
  end
  
  always_comb begin
    dmem_req_o = 1'b0;
    dmem_req_addr_o = 0;
    dmem_req_we_o = 1'b0;
    dmem_req_be_o = 0;
    dmem_req_wdata_o = 0;
    ex_if_ready_o = 1'b0;
    wb_if_rdata_o = rsp_data_r;
    wb_if_rvalid_o = 1'b0;
    unique case (state_r)
      IDLE: begin
        ex_if_ready_o = 1'b1;
      end
      REQ: begin
        dmem_req_o = 1'b1;
        dmem_req_addr_o = req_addr_r;
        dmem_req_we_o = req_we_r;
        dmem_req_be_o = req_be_r;
        dmem_req_wdata_o = req_wdata_r;
      end
      WAITLOAD: begin
      end
      RESP: begin
        ex_if_ready_o = 1'b1;
        wb_if_rvalid_o = 1'b1;
        wb_if_rdata_o = rsp_data_r;
      end
      default: ;
    endcase
  end
  
  // synopsys translate_off
  _auto_reach_Idle: cover property (@(posedge clk) state_r == IDLE);
  _auto_reach_Req: cover property (@(posedge clk) state_r == REQ);
  _auto_reach_WaitLoad: cover property (@(posedge clk) state_r == WAITLOAD);
  _auto_reach_Resp: cover property (@(posedge clk) state_r == RESP);
  _auto_tr_IDLE_to_REQ: cover property (@(posedge clk) state_r == IDLE && state_next == REQ);
  _auto_tr_REQ_to_IDLE: cover property (@(posedge clk) state_r == REQ && state_next == IDLE);
  _auto_tr_REQ_to_WAITLOAD: cover property (@(posedge clk) state_r == REQ && state_next == WAITLOAD);
  _auto_tr_WAITLOAD_to_RESP: cover property (@(posedge clk) state_r == WAITLOAD && state_next == RESP);
  _auto_tr_RESP_to_REQ: cover property (@(posedge clk) state_r == RESP && state_next == REQ);
  _auto_tr_RESP_to_IDLE: cover property (@(posedge clk) state_r == RESP && state_next == IDLE);
  // synopsys translate_on

endmodule

