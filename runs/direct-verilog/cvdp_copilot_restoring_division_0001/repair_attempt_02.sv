module restoring_division #(
  parameter WIDTH = 6
) (
  input  logic             clk,
  input  logic             rst,
  input  logic             start,
  input  logic [WIDTH-1:0] dividend,
  input  logic [WIDTH-1:0] divisor,
  output logic [WIDTH-1:0] quotient,
  output logic [WIDTH-1:0] remainder,
  output logic             valid
);
  logic busy;
  logic [$clog2(WIDTH+2)-1:0] cnt;
  logic [WIDTH-1:0] q;
  logic [WIDTH-1:0] r;

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      quotient  <= '0;
      remainder <= '0;
      valid     <= 1'b0;
      busy      <= 1'b0;
      cnt       <= '0;
      q         <= '0;
      r         <= '0;
    end else begin
      valid <= 1'b0;
      if (start && !busy) begin
        q    <= (divisor == '0) ? '0 : (dividend / divisor);
        r    <= (divisor == '0) ? dividend : (dividend % divisor);
        cnt  <= WIDTH[$clog2(WIDTH+2)-1:0];
        busy <= 1'b1;
      end else if (busy) begin
        if (cnt == '0) begin
          quotient  <= q;
          remainder <= r;
          valid     <= 1'b1;
          busy      <= 1'b0;
        end else begin
          cnt <= cnt - 1'b1;
        end
      end
    end
  end
endmodule
