//! ---
//! tags: [complex-multiply, signed-arithmetic, registered-output]
//! ---
//!
//! One-cycle complex multiplier with asynchronous active-low reset. The datapath computes
//! signed 16-bit complex multiplication and registers the 32-bit real and imaginary results.
/// Top-level complex multiplier for cvdp_copilot_complex_multiplier_0001.
///
/// Inputs are sampled on the rising edge of clk, and result_real/result_imag update one
/// cycle later with reset clearing both registered outputs asynchronously when arst_n is low.
module complex_multiplier (
  input logic clk,
  input logic arst_n,
  input logic [15:0] a_real,
  input logic [15:0] a_imag,
  input logic [15:0] b_real,
  input logic [15:0] b_imag,
  output logic [31:0] result_real,
  output logic [31:0] result_imag
);

  logic signed [15:0] a_real_s;
  logic signed [15:0] a_imag_s;
  logic signed [15:0] b_real_s;
  logic signed [15:0] b_imag_s;
  logic signed [31:0] prod_ac;
  logic signed [31:0] prod_bd;
  logic signed [31:0] prod_ad;
  logic signed [31:0] prod_bc;
  logic signed [31:0] real_next;
  logic signed [31:0] imag_next;
  assign a_real_s = $signed(a_real);
  assign a_imag_s = $signed(a_imag);
  assign b_real_s = $signed(b_real);
  assign b_imag_s = $signed(b_imag);
  assign prod_ac = a_real_s * b_real_s;
  assign prod_bd = a_imag_s * b_imag_s;
  assign prod_ad = a_real_s * b_imag_s;
  assign prod_bc = a_imag_s * b_real_s;
  assign real_next = 32'(prod_ac - prod_bd);
  assign imag_next = 32'(prod_ad + prod_bc);
  always_ff @(posedge clk or negedge arst_n) begin
    if ((!arst_n)) begin
      result_imag <= 0;
      result_real <= 0;
    end else begin
      result_real <= $unsigned(real_next);
      result_imag <= $unsigned(imag_next);
    end
  end

endmodule

