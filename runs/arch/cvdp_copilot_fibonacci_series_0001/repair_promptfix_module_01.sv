//! ---
//! tags: [fibonacci, sequence, overflow, registered]
//! ---
//!
//! 32-bit Fibonacci generator with registered outputs and one-cycle delayed
//! overflow restart behavior. The sequence starts at F(0) = 0, F(1) = 1 and
//! restarts automatically after detecting a 33-bit sum.
/// Generates a 32-bit Fibonacci sequence and reports overflow on the restart cycle.
///
/// `fib_out` and `overflow_flag` are registered outputs driven on the rising edge of `clk`.
module fibonacci_series (
  input logic clk,
  input logic rst,
  output logic [31:0] fib_out,
  output logic overflow_flag
);

  logic [32:0] next_fib;
  logic overflow_now;
  logic [31:0] next_fib_low;
  logic [31:0] reg_a;
  logic [31:0] reg_b;
  logic overflow_pending;
  logic restart_hold;
  assign next_fib = 33'(33'($unsigned(reg_a)) + 33'($unsigned(reg_b)));
  assign overflow_now = next_fib[32];
  assign next_fib_low = next_fib[31:0];
  always_ff @(posedge clk) begin
    if (rst) begin
      fib_out <= 0;
      overflow_flag <= 1'b0;
      overflow_pending <= 1'b0;
      reg_a <= 0;
      reg_b <= 1;
      restart_hold <= 1'b0;
    end else begin
      if (overflow_pending) begin
        reg_a <= 0;
        reg_b <= 1;
        overflow_pending <= 1'b0;
        restart_hold <= 1'b1;
        fib_out <= 0;
        overflow_flag <= 1'b1;
      end else if (restart_hold) begin
        reg_a <= 0;
        reg_b <= 1;
        overflow_pending <= 1'b0;
        restart_hold <= 1'b0;
        fib_out <= 0;
        overflow_flag <= 1'b0;
      end else begin
        fib_out <= reg_b;
        overflow_flag <= 1'b0;
        restart_hold <= 1'b0;
        if (overflow_now) begin
          overflow_pending <= 1'b1;
        end else begin
          reg_a <= reg_b;
          reg_b <= next_fib_low;
          overflow_pending <= 1'b0;
        end
      end
    end
  end

endmodule

