//! ---
//! tags: [caesar, cipher, combinational]
//! ---
//!
//! Combinational Caesar cipher for 8-bit ASCII input characters. Alphabetic
//! uppercase and lowercase characters are shifted by a 4-bit key with wraparound;
//! non-alphabetic characters pass through unchanged.
/// Implements the top-level Caesar cipher datapath.
///
/// The module has purely combinational timing: output_char reflects input_char
/// and key in the same cycle with no clocked storage.
module caesar_cipher (
  input logic [7:0] input_char,
  input logic [3:0] key,
  output logic [7:0] output_char
);

  logic is_upper;
  logic is_lower;
  logic [7:0] key8;
  logic [7:0] upper_pos;
  logic [7:0] upper_sum;
  logic [7:0] upper_mod;
  logic [7:0] upper_shifted;
  logic [7:0] lower_pos;
  logic [7:0] lower_sum;
  logic [7:0] lower_mod;
  logic [7:0] lower_shifted;
  assign is_upper = input_char >= 8'd65 && input_char <= 8'd90;
  assign is_lower = input_char >= 8'd97 && input_char <= 8'd122;
  assign key8 = 8'($unsigned(key));
  assign upper_pos = 8'(input_char - 8'd65);
  assign upper_sum = 8'(upper_pos + key8);
  assign upper_mod = upper_sum >= 8'd26 ? 8'(upper_sum - 8'd26) : upper_sum;
  assign upper_shifted = 8'(upper_mod + 8'd65);
  assign lower_pos = 8'(input_char - 8'd97);
  assign lower_sum = 8'(lower_pos + key8);
  assign lower_mod = lower_sum >= 8'd26 ? 8'(lower_sum - 8'd26) : lower_sum;
  assign lower_shifted = 8'(lower_mod + 8'd97);
  always_comb begin
    if (is_upper) begin
      output_char = upper_shifted;
    end else if (is_lower) begin
      output_char = lower_shifted;
    end else begin
      output_char = input_char;
    end
  end

endmodule

