module dig_stopwatch #(
  parameter integer CLK_FREQ = 50000000
) (
  input  wire       clk,
  input  wire       reset,
  input  wire       start_stop,
  output reg  [5:0] seconds,
  output reg  [5:0] minutes,
  output reg        hour
);
  localparam integer DIV_WIDTH = (CLK_FREQ <= 1) ? 1 : $clog2(CLK_FREQ);
  reg [DIV_WIDTH-1:0] div_count;

  initial begin
    div_count = '0;
    seconds = 6'd0;
    minutes = 6'd0;
    hour = 1'b0;
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      div_count <= '0;
      seconds   <= 6'd0;
      minutes   <= 6'd0;
      hour      <= 1'b0;
    end else if (start_stop && !hour) begin
      if (div_count == CLK_FREQ - 1) begin
        div_count <= '0;
        if (seconds == 6'd59) begin
          seconds <= 6'd0;
          if (minutes == 6'd59) begin
            minutes <= 6'd0;
            hour    <= 1'b1;
          end else begin
            minutes <= minutes + 6'd1;
          end
        end else begin
          seconds <= seconds + 6'd1;
        end
      end else begin
        div_count <= div_count + 1'b1;
      end
    end
  end
endmodule
