//! ---
//! tags: [convolutional-encoder, serial, constraint-k3, generator-polynomial]
//! ---
//!
//! Fixed K=3 convolutional encoder for a serial data stream. Each sampled input bit is encoded with generator polynomials 111 and 101 using the current bit and the previous two input bits.
/// Top-level K=3 convolutional encoder.
///
/// On each rising clock edge, the module emits registered encoded bits for the current input and then advances the two-bit history. The active-high asynchronous reset clears both encoded outputs and the implementation-visible `shift_reg` history register.
module convolutional_encoder (
  input logic clk,
  input logic rst,
  input logic data_in,
  output logic encoded_bit1,
  output logic encoded_bit2
);

  logic next_encoded_bit1;
  logic next_encoded_bit2;
  logic [1:0] next_shift_reg;
  logic [1:0] shift_reg;
  assign next_encoded_bit1 = data_in ^ shift_reg[1] ^ shift_reg[0];
  assign next_encoded_bit2 = data_in ^ shift_reg[0];
  assign next_shift_reg = {data_in, shift_reg[1]};
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      encoded_bit1 <= 0;
      encoded_bit2 <= 0;
      shift_reg <= 0;
    end else begin
      encoded_bit1 <= next_encoded_bit1;
      encoded_bit2 <= next_encoded_bit2;
      shift_reg <= next_shift_reg;
    end
  end

endmodule

