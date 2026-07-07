//! ---
//! tags: [carry, cla, combinational]
//! ---
//!
//! Single-bit generate/propagate cell for a carry lookahead adder. The module computes carry generation, carry propagation, and carry-out directly from the operand bits and carry-in.
/// Generate/propagate cell for one carry lookahead adder bit.
///
/// Outputs are purely combinational: generate is `i_A & i_B`, propagate is `i_A | i_B`, and carry-out is `generate | (propagate & i_Cin)`.
module GP (
  input logic [0:0] i_A,
  input logic [0:0] i_B,
  input logic [0:0] i_Cin,
  output logic [0:0] o_generate,
  output logic [0:0] o_propagate,
  output logic [0:0] o_Cout
);

  logic [0:0] gp_generate;
  logic [0:0] gp_propagate;
  assign gp_generate = i_A & i_B;
  assign gp_propagate = i_A | i_B;
  assign o_generate = gp_generate;
  assign o_propagate = gp_propagate;
  assign o_Cout = gp_generate | (gp_propagate & i_Cin);

endmodule

