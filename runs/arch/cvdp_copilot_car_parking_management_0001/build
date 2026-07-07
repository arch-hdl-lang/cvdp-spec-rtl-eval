//! ---
//! tags: [parking, fsm, counters, seven_segment]
//! refs: []
//! ---
//!
//! Car parking management system for the CVDP prompt. The design tracks
//! available spaces and parked-car count, rejects entries when full, and
//! displays both counts as two decimal digits on active-high seven-segment
//! outputs with segment A in the MSB and segment G in the LSB.
/// Top-level car parking controller.
///
/// Timing/type notes: `vehicle_entry_sensor` and `vehicle_exit_sensor` are
/// sampled on the rising edge of `clk`; `reset` is asynchronous active high.
/// The count outputs are the current registered count values, while LED and
/// seven-segment outputs are combinationally derived from those counts.
/// Transition table: Idle with valid entry and space available updates to the
/// entry-processing count values; Idle with valid exit and at least one car
/// updates to the exit-processing count values; Full denies entry while no exit
/// is present; otherwise state and counts hold. Simultaneous entry and exit
/// preserve the current count because one car leaves as one arrives.
module car_parking_system #(
  parameter int TOTAL_SPACES = 12,
  localparam int COUNT_W = $clog2(TOTAL_SPACES)
) (
  input logic clk,
  input logic reset,
  input logic vehicle_entry_sensor,
  input logic vehicle_exit_sensor,
  output logic [COUNT_W-1:0] available_spaces,
  output logic [COUNT_W-1:0] count_car,
  output logic led_status,
  output logic [6:0] seven_seg_display_available_tens,
  output logic [6:0] seven_seg_display_available_units,
  output logic [6:0] seven_seg_display_count_tens,
  output logic [6:0] seven_seg_display_count_units
);

  typedef enum logic [1:0] {
    IDLE = 2'd0,
    ENTRYPROCESSING = 2'd1,
    EXITPROCESSING = 2'd2,
    FULL = 2'd3
  } car_parking_system_state_t;
  
  car_parking_system_state_t state_r, state_next;
  
  logic [COUNT_W-1:0] available_r;
  logic [COUNT_W-1:0] count_r;
  
  logic is_full;
  assign is_full = available_r == 0;
  logic has_cars;
  assign has_cars = count_r != 0;
  logic can_enter;
  assign can_enter = vehicle_entry_sensor && !vehicle_exit_sensor && !is_full;
  logic can_exit;
  assign can_exit = vehicle_exit_sensor && !vehicle_entry_sensor && has_cars;
  logic [COUNT_W-1:0] available_tens_wide;
  assign available_tens_wide = available_r / 10;
  logic [COUNT_W-1:0] available_units_wide;
  assign available_units_wide = available_r % 10;
  logic [COUNT_W-1:0] count_tens_wide;
  assign count_tens_wide = count_r / 10;
  logic [COUNT_W-1:0] count_units_wide;
  assign count_units_wide = count_r % 10;
  logic [3:0] available_tens_digit;
  assign available_tens_digit = 4'(available_tens_wide);
  logic [3:0] available_units_digit;
  assign available_units_digit = 4'(available_units_wide);
  logic [3:0] count_tens_digit;
  assign count_tens_digit = 4'(count_tens_wide);
  logic [3:0] count_units_digit;
  assign count_units_digit = 4'(count_units_wide);
  logic [6:0] available_tens_segments;
  assign available_tens_segments = available_tens_digit == 0 ? 7'd126 : available_tens_digit == 1 ? 7'd48 : available_tens_digit == 2 ? 7'd109 : available_tens_digit == 3 ? 7'd121 : available_tens_digit == 4 ? 7'd51 : available_tens_digit == 5 ? 7'd91 : available_tens_digit == 6 ? 7'd95 : available_tens_digit == 7 ? 7'd112 : available_tens_digit == 8 ? 7'd127 : 7'd123;
  logic [6:0] available_units_segments;
  assign available_units_segments = available_units_digit == 0 ? 7'd126 : available_units_digit == 1 ? 7'd48 : available_units_digit == 2 ? 7'd109 : available_units_digit == 3 ? 7'd121 : available_units_digit == 4 ? 7'd51 : available_units_digit == 5 ? 7'd91 : available_units_digit == 6 ? 7'd95 : available_units_digit == 7 ? 7'd112 : available_units_digit == 8 ? 7'd127 : 7'd123;
  logic [6:0] count_tens_segments;
  assign count_tens_segments = count_tens_digit == 0 ? 7'd126 : count_tens_digit == 1 ? 7'd48 : count_tens_digit == 2 ? 7'd109 : count_tens_digit == 3 ? 7'd121 : count_tens_digit == 4 ? 7'd51 : count_tens_digit == 5 ? 7'd91 : count_tens_digit == 6 ? 7'd95 : count_tens_digit == 7 ? 7'd112 : count_tens_digit == 8 ? 7'd127 : 7'd123;
  logic [6:0] count_units_segments;
  assign count_units_segments = count_units_digit == 0 ? 7'd126 : count_units_digit == 1 ? 7'd48 : count_units_digit == 2 ? 7'd109 : count_units_digit == 3 ? 7'd121 : count_units_digit == 4 ? 7'd51 : count_units_digit == 5 ? 7'd91 : count_units_digit == 6 ? 7'd95 : count_units_digit == 7 ? 7'd112 : count_units_digit == 8 ? 7'd127 : 7'd123;
  assign available_spaces = available_r;
  assign count_car = count_r;
  assign led_status = !is_full;
  assign seven_seg_display_available_tens = available_tens_segments;
  assign seven_seg_display_available_units = available_units_segments;
  assign seven_seg_display_count_tens = count_tens_segments;
  assign seven_seg_display_count_units = count_units_segments;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state_r <= IDLE;
      available_r <= COUNT_W'(TOTAL_SPACES);
      count_r <= 0;
    end else begin
      state_r <= state_next;
      unique case (state_r)
        IDLE: begin
          if (can_enter) begin
            available_r <= (COUNT_W > 1 ? COUNT_W : 1)'(available_r - 1);
            count_r <= (COUNT_W > 1 ? COUNT_W : 1)'(count_r + 1);
          end else if (can_exit) begin
            available_r <= (COUNT_W > 1 ? COUNT_W : 1)'(available_r + 1);
            count_r <= (COUNT_W > 1 ? COUNT_W : 1)'(count_r - 1);
          end
        end
        FULL: begin
          if (can_exit) begin
            available_r <= (COUNT_W > 1 ? COUNT_W : 1)'(available_r + 1);
            count_r <= (COUNT_W > 1 ? COUNT_W : 1)'(count_r - 1);
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
        if (can_enter) state_next = ENTRYPROCESSING;
        else if (can_exit) state_next = EXITPROCESSING;
        else if (is_full) state_next = FULL;
      end
      ENTRYPROCESSING: begin
        if (is_full) state_next = FULL;
        else if (!is_full) state_next = IDLE;
      end
      EXITPROCESSING: begin
        state_next = IDLE;
      end
      FULL: begin
        if (can_exit) state_next = EXITPROCESSING;
      end
      default: state_next = state_r;
    endcase
  end
  
  always_comb begin
    unique case (state_r)
      IDLE: begin
      end
      ENTRYPROCESSING: begin
      end
      EXITPROCESSING: begin
      end
      FULL: begin
      end
      default: ;
    endcase
  end
  
  // synopsys translate_off
  _auto_reach_Idle: cover property (@(posedge clk) state_r == IDLE);
  _auto_reach_EntryProcessing: cover property (@(posedge clk) state_r == ENTRYPROCESSING);
  _auto_reach_ExitProcessing: cover property (@(posedge clk) state_r == EXITPROCESSING);
  _auto_reach_Full: cover property (@(posedge clk) state_r == FULL);
  _auto_tr_IDLE_to_ENTRYPROCESSING: cover property (@(posedge clk) state_r == IDLE && state_next == ENTRYPROCESSING);
  _auto_tr_IDLE_to_EXITPROCESSING: cover property (@(posedge clk) state_r == IDLE && state_next == EXITPROCESSING);
  _auto_tr_IDLE_to_FULL: cover property (@(posedge clk) state_r == IDLE && state_next == FULL);
  _auto_tr_ENTRYPROCESSING_to_FULL: cover property (@(posedge clk) state_r == ENTRYPROCESSING && state_next == FULL);
  _auto_tr_ENTRYPROCESSING_to_IDLE: cover property (@(posedge clk) state_r == ENTRYPROCESSING && state_next == IDLE);
  _auto_tr_EXITPROCESSING_to_IDLE: cover property (@(posedge clk) state_r == EXITPROCESSING && state_next == IDLE);
  _auto_tr_FULL_to_EXITPROCESSING: cover property (@(posedge clk) state_r == FULL && state_next == EXITPROCESSING);
  // synopsys translate_on

endmodule

