//! ---
//! tags: [division, unsigned-arithmetic, latency, registered-output]
//! ---
//!
//! Unsigned divider with restoring-divider style latency. The module samples operands on a start pulse, iterates one quotient bit per clock, and asserts valid for one cycle when the quotient and remainder registers hold the completed operation.
/// Top-level unsigned restoring division datapath.
///
/// Input timing: clk rising edge samples start, dividend, and divisor. rst is asynchronous active-low for the CVDP harness and clears all state.
/// Output timing: quotient and remainder update on the final iteration; valid is a one-cycle pulse with the completed result.
module restoring_division #(
  parameter int WIDTH = 6,
  localparam int COUNT_W = $clog2(WIDTH + 2),
  localparam int REM_W = WIDTH + 1
) (
  input logic clk,
  input logic rst,
  input logic start,
  input logic [WIDTH-1:0] dividend,
  input logic [WIDTH-1:0] divisor,
  output logic [WIDTH-1:0] quotient,
  output logic [WIDTH-1:0] remainder,
  output logic valid
);

  logic [WIDTH-1:0] rem_low;
  logic [REM_W-1:0] shifted_rem;
  logic [REM_W-1:0] divisor_ext;
  logic can_subtract;
  logic [REM_W-1:0] subtract_rem;
  logic [REM_W-1:0] next_rem;
  logic [WIDTH-1:0] next_quotient;
  logic [WIDTH-1:0] next_dividend;
  logic final_iter;
  logic [WIDTH-1:0] dividend_r;
  logic [WIDTH-1:0] divisor_r;
  logic [WIDTH-1:0] quotient_work_r;
  logic [REM_W-1:0] remainder_work_r;
  logic [WIDTH-1:0] quotient_r;
  logic [WIDTH-1:0] remainder_r;
  logic valid_r;
  logic busy_r;
  logic [COUNT_W-1:0] iter_count_r;
  assign rem_low = remainder_work_r[WIDTH - 1:0];
  assign shifted_rem = {rem_low, dividend_r[WIDTH - 1]};
  assign divisor_ext = REM_W'($unsigned(divisor_r));
  assign can_subtract = shifted_rem >= divisor_ext;
  assign subtract_rem = REM_W'(shifted_rem - divisor_ext);
  assign next_rem = can_subtract ? subtract_rem : shifted_rem;
  assign next_quotient = {quotient_work_r[WIDTH - 2:0], can_subtract};
  assign next_dividend = {dividend_r[WIDTH - 2:0], 1'd0};
  assign final_iter = iter_count_r == COUNT_W'(WIDTH - 1);
  assign quotient = quotient_r;
  assign remainder = remainder_r;
  assign valid = valid_r;
  always_ff @(posedge clk or negedge rst) begin
    if ((!rst)) begin
      busy_r <= 0;
      dividend_r <= 0;
      divisor_r <= 0;
      iter_count_r <= 0;
      quotient_r <= 0;
      quotient_work_r <= 0;
      remainder_r <= 0;
      remainder_work_r <= 0;
      valid_r <= 0;
    end else begin
      if (start && !busy_r) begin
        dividend_r <= dividend;
        divisor_r <= divisor;
        quotient_work_r <= 0;
        remainder_work_r <= 0;
        quotient_r <= 0;
        remainder_r <= 0;
        iter_count_r <= 0;
        busy_r <= 1'b1;
        valid_r <= 1'b0;
      end else if (busy_r) begin
        dividend_r <= next_dividend;
        quotient_work_r <= next_quotient;
        remainder_work_r <= next_rem;
        if (final_iter) begin
          quotient_r <= next_quotient;
          remainder_r <= next_rem[WIDTH - 1:0];
          busy_r <= 1'b0;
          valid_r <= 1'b1;
        end else begin
          iter_count_r <= (COUNT_W > 1 ? COUNT_W : 1)'(iter_count_r + 1);
          valid_r <= 1'b0;
        end
      end else begin
        valid_r <= 1'b0;
      end
    end
  end

endmodule

