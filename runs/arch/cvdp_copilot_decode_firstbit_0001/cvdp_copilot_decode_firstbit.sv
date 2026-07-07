//! ---
//! tags: [firstbit, decoder, combinational, parameterized]
//! ---
//!
//! Parameterized first-set-bit decoder for CVDP. The externally observed outputs decode the current input word combinationally.
/// Combinational first-set-bit decoder.
///
/// Out_FirstBit reports the lowest asserted bit index, Out_Found reports whether any input bit is asserted, and Out_Valid follows In_Valid. The register-related parameters are retained for interface compatibility with the original problem.
module cvdp_copilot_decode_firstbit #(
  parameter int InWidth_g = 32,
  parameter int InReg_g = 1,
  parameter int OutReg_g = 1,
  parameter int PlRegs_g = 1,
  localparam int BinBits_c = $clog2(InWidth_g)
) (
  input logic Clk,
  input logic Rst,
  input logic [InWidth_g-1:0] In_Data,
  input logic In_Valid,
  output logic [BinBits_c-1:0] Out_FirstBit,
  output logic Out_Found,
  output logic Out_Valid
);

  logic [InWidth_g-1:0] selected_neg;
  logic [InWidth_g-1:0] lowest_mask;
  logic scan_found;
  assign selected_neg = (1 > InWidth_g ? 1 : InWidth_g)'(0 - In_Data);
  assign lowest_mask = In_Data & selected_neg;
  assign scan_found = In_Data != 0;
  logic [BinBits_c-1:0] scan_first;
  assign Out_FirstBit = scan_found ? scan_first : 0;
  assign Out_Found = scan_found;
  assign Out_Valid = In_Valid;
  always_comb begin
    scan_first = 0;
    for (int bit_pos = 0; bit_pos <= InWidth_g - 1; bit_pos++) begin
      if (lowest_mask[bit_pos] == 1) begin
        scan_first = bit_pos;
      end
    end
  end

endmodule

