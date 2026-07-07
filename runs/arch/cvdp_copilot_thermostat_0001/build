//! ---
//! tags: [thermostat, fsm, heating, cooling, fault]
//! ---
//!
//! Sequential thermostat controller that selects heating, cooling, or ambient
//! operation from prioritized temperature feedback. Fault, clear, enable, and
//! asynchronous active-low reset behavior are captured directly in the state and
//! registered output update logic.
/// Thermostat controller top-level module.
///
/// Samples temperature feedback on `i_clk`, tracks a retained fault condition,
/// and drives registered heat, cool, fan, and state outputs with asynchronous
/// active-low reset to the ambient/off condition.
module thermostat (
  input logic i_clk,
  input logic i_rst,
  input logic [5:0] i_temp_feedback,
  input logic i_fan_on,
  input logic i_enable,
  input logic i_fault,
  input logic i_clr,
  output logic o_heater_full,
  output logic o_heater_medium,
  output logic o_heater_low,
  output logic o_aircon_full,
  output logic o_aircon_medium,
  output logic o_aircon_low,
  output logic o_fan,
  output logic [2:0] o_state
);

  logic [2:0] HEAT_LOW;
  logic [2:0] HEAT_MED;
  logic [2:0] HEAT_FULL;
  logic [2:0] AMBIENT;
  logic [2:0] COOL_LOW;
  logic [2:0] COOL_MED;
  logic [2:0] COOL_FULL;
  logic full_cold;
  logic medium_cold;
  logic low_cold;
  logic low_hot;
  logic medium_hot;
  logic full_hot;
  assign HEAT_LOW = 3'd0;
  assign HEAT_MED = 3'd1;
  assign HEAT_FULL = 3'd2;
  assign AMBIENT = 3'd3;
  assign COOL_LOW = 3'd4;
  assign COOL_MED = 3'd5;
  assign COOL_FULL = 3'd6;
  assign full_cold = i_temp_feedback[5];
  assign medium_cold = i_temp_feedback[4];
  assign low_cold = i_temp_feedback[3];
  assign low_hot = i_temp_feedback[2];
  assign medium_hot = i_temp_feedback[1];
  assign full_hot = i_temp_feedback[0];
  logic fault_active;
  always_ff @(posedge i_clk or negedge i_rst) begin
    if ((!i_rst)) begin
      fault_active <= 1'b0;
      o_aircon_full <= 1'b0;
      o_aircon_low <= 1'b0;
      o_aircon_medium <= 1'b0;
      o_fan <= 1'b0;
      o_heater_full <= 1'b0;
      o_heater_low <= 1'b0;
      o_heater_medium <= 1'b0;
      o_state <= 3'd3;
    end else begin
      if (i_fault) begin
        fault_active <= 1'b1;
        o_state <= AMBIENT;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b0;
      end else if (i_clr) begin
        fault_active <= 1'b0;
        o_state <= AMBIENT;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b0;
      end else if (fault_active) begin
        fault_active <= 1'b1;
        o_state <= AMBIENT;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b0;
      end else if (!i_enable) begin
        fault_active <= 1'b0;
        o_state <= AMBIENT;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b0;
      end else if (full_cold) begin
        fault_active <= 1'b0;
        o_state <= HEAT_FULL;
        o_heater_full <= 1'b1;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b1;
      end else if (medium_cold) begin
        fault_active <= 1'b0;
        o_state <= HEAT_MED;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b1;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b1;
      end else if (low_cold) begin
        fault_active <= 1'b0;
        o_state <= HEAT_LOW;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b1;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b1;
      end else if (full_hot) begin
        fault_active <= 1'b0;
        o_state <= COOL_FULL;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b1;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b1;
      end else if (medium_hot) begin
        fault_active <= 1'b0;
        o_state <= COOL_MED;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b1;
        o_aircon_low <= 1'b0;
        o_fan <= 1'b1;
      end else if (low_hot) begin
        fault_active <= 1'b0;
        o_state <= COOL_LOW;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b1;
        o_fan <= 1'b1;
      end else begin
        fault_active <= 1'b0;
        o_state <= AMBIENT;
        o_heater_full <= 1'b0;
        o_heater_medium <= 1'b0;
        o_heater_low <= 1'b0;
        o_aircon_full <= 1'b0;
        o_aircon_medium <= 1'b0;
        o_aircon_low <= 1'b0;
        o_fan <= i_fan_on;
      end
    end
  end

endmodule

