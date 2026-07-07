//! ---
//! tags: [clock-divider, async-reset, frequency-select]
//! ---
//!
//! Clock divider with selectable divide-by-2, divide-by-4, or divide-by-8 output.
//! Invalid selection holds the output low until a valid divider selection is applied.
/// Top-level selectable clock divider.
///
/// A resettable 3-bit free-running divider counter supplies the divided clock phases;
/// `sel` selects the counter bit for the requested divide ratio, while `2'b11` forces
/// `clk_out` low and clears the divider state.
module clock_divider (
  input logic clk,
  input logic rst_n,
  input logic [1:0] sel,
  output logic clk_out
);

  logic valid_sel;
  logic [2:0] next_count;
  logic [2:0] div_count;
  assign valid_sel = sel != 2'd3;
  assign next_count = 3'(div_count + 3'd1);
  assign clk_out = valid_sel ? sel == 2'd0 ? div_count[0] : sel == 2'd1 ? div_count[1] : div_count[2] : 1'b0;
  always_ff @(posedge clk or negedge rst_n) begin
    if ((!rst_n)) begin
      div_count <= 0;
    end else begin
      if (valid_sel) begin
        div_count <= next_count;
      end else begin
        div_count <= 3'd0;
      end
    end
  end

endmodule

