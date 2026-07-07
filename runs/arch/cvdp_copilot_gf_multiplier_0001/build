//! ---
//! tags: [gf16, combinational, multiplier, polynomial-reduction]
//! ---
//!
//! Combinational 4-bit GF(2^4) multiplier using the irreducible polynomial x^4 + x + 1.
//! The datapath follows the prompt algorithm by conditionally XORing shifted multiplicands for each bit of B.
/// Top-level 4-bit Galois-field multiplier for GF(2^4).
///
/// Produces a same-cycle reduced product of A and B modulo x^4 + x + 1.
module gf_multiplier (
  input logic [3:0] A,
  input logic [3:0] B,
  output logic [3:0] result
);

  logic [3:0] m0;
  logic [3:0] add0;
  logic [3:0] sh0;
  logic [3:0] m1;
  logic [3:0] add1;
  logic [3:0] sh1;
  logic [3:0] m2;
  logic [3:0] add2;
  logic [3:0] sh2;
  logic [3:0] m3;
  logic [3:0] add3;
  logic [3:0] product;
  assign m0 = A;
  assign add0 = B[0] ? m0 : 4'd0;
  assign sh0 = {m0[2:0], 1'd0};
  assign m1 = m0[3] ? sh0 ^ 4'd3 : sh0;
  assign add1 = B[1] ? m1 : 4'd0;
  assign sh1 = {m1[2:0], 1'd0};
  assign m2 = m1[3] ? sh1 ^ 4'd3 : sh1;
  assign add2 = B[2] ? m2 : 4'd0;
  assign sh2 = {m2[2:0], 1'd0};
  assign m3 = m2[3] ? sh2 ^ 4'd3 : sh2;
  assign add3 = B[3] ? m3 : 4'd0;
  assign product = add0 ^ add1 ^ add2 ^ add3;
  assign result = product;

endmodule

