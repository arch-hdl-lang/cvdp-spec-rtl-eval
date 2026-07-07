//! ---
//! tags: [perfect_squares, sequence, saturation]
//! ---
//!
//! Generates a sequence of 32-bit perfect squares from an active-high asynchronous reset.
//! The datapath uses the odd-increment recurrence and saturates the output at 32'hFFFFFFFF before wrapping.
/// Top-level perfect square sequence generator.
///
/// On reset the visible square is 1; each subsequent positive clock edge advances to the next square until saturation.
module perfect_squares_generator (
  input logic clk,
  input logic reset,
  output logic [31:0] sqr_o
);

  logic [32:0] sqr_ext;
  logic [32:0] odd_ext;
  logic [32:0] sum_ext;
  logic [32:0] max_ext;
  logic [31:0] next_square;
  logic [31:0] next_odd;
  logic [31:0] odd_step;
  assign sqr_ext = 33'($unsigned(sqr_o));
  assign odd_ext = 33'($unsigned(odd_step));
  assign sum_ext = 33'(sqr_ext + odd_ext);
  assign max_ext = 33'd4294967295;
  assign next_square = sum_ext[31:0];
  assign next_odd = 32'(odd_step + 32'd2);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      odd_step <= 32'd3;
      sqr_o <= 32'd1;
    end else begin
      if (sqr_o == 32'd4294967295) begin
        sqr_o <= 32'd4294967295;
        odd_step <= odd_step;
      end else if (sum_ext > max_ext) begin
        sqr_o <= 32'd4294967295;
        odd_step <= odd_step;
      end else begin
        sqr_o <= next_square;
        odd_step <= next_odd;
      end
    end
  end

endmodule

