//! ---
//! tags: [prbs, lfsr, generator, checker]
//! ---
//!
//! Configurable PRBS generator/checker. The design keeps a POLY_LENGTH-bit LFSR seeded to all ones and emits one WIDTH-bit registered result per clock.
/// PRBS generator and checker with a parameterized polynomial length, tap, mode, and data width.
///
/// On each rising clock edge the module advances WIDTH serial LFSR steps from the current state. In generator mode the registered output is the generated PRBS word; in checker mode it is data_in XOR the expected PRBS word.
module cvdp_prbs_gen #(
  parameter int CHECK_MODE = 0,
  parameter int POLY_LENGTH = 31,
  parameter int POLY_TAP = 3,
  parameter int WIDTH = 16
) (
  input logic clk,
  input logic rst,
  input logic [WIDTH-1:0] data_in,
  output logic [WIDTH-1:0] data_out
);

  logic [POLY_LENGTH-1:0] lfsr_state;
  logic [POLY_LENGTH-1:0] working_state;
  logic [WIDTH-1:0] prbs_word;
  logic [WIDTH-1:0] next_word;
  always_comb begin
    working_state = lfsr_state;
    for (int i = 0; i <= WIDTH - 1; i++) begin
      prbs_word[i] = working_state[POLY_LENGTH - 1] ^ working_state[POLY_TAP - 1];
      working_state = {working_state[POLY_LENGTH - 2:0], prbs_word[i]};
    end
    if (CHECK_MODE == 1) begin
      next_word = data_in ^ prbs_word;
    end else begin
      next_word = prbs_word;
    end
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      data_out <= ~0;
      lfsr_state <= ~0;
    end else begin
      lfsr_state <= working_state;
      data_out <= next_word;
    end
  end

endmodule

