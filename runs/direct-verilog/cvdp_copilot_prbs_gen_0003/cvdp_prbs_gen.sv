module cvdp_prbs_gen #(
  parameter WIDTH = 8,
  parameter POLY_LENGTH = 7,
  parameter POLY_TAP = 6,
  parameter CHECK_MODE = 0
) (
  input  logic             clk,
  input  logic             rst,
  input  logic [WIDTH-1:0] data_in,
  output logic [WIDTH-1:0] data_out
);
  logic [POLY_LENGTH-1:0] lfsr;
  logic [POLY_LENGTH-1:0] nxt;
  logic [WIDTH-1:0] prbs;
  integer i;

  always_comb begin
    nxt = lfsr;
    prbs = '0;
    for (i = 0; i < WIDTH; i = i + 1) begin
      prbs[i] = nxt[POLY_TAP-1] ^ nxt[POLY_LENGTH-1];
      nxt = {nxt[POLY_LENGTH-2:0], prbs[i]};
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      lfsr <= {POLY_LENGTH{1'b1}};
      data_out <= {WIDTH{1'b1}};
    end else begin
      data_out <= CHECK_MODE ? (data_in ^ prbs) : prbs;
      lfsr <= nxt;
    end
  end
endmodule
