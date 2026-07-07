module clock_jitter_detection_module #(
  parameter int unsigned JITTER_THRESHOLD = 5
) (
  input  logic clk,
  input  logic system_clk,
  input  logic rst,
  output logic jitter_detected
);
  logic [31:0] edge_count;
  logic        prev_system_clk;
  logic        counter_started;

  wire        system_clk_rise = system_clk && !prev_system_clk;
  wire [31:0] measured_count  = edge_count + 32'd1;
  wire [31:0] low_limit       = (JITTER_THRESHOLD > 1) ? (JITTER_THRESHOLD - 1) : 32'd0;
  wire [31:0] high_limit      = JITTER_THRESHOLD + 1;
  wire        outside_window  = (measured_count < low_limit) || (measured_count > high_limit);

  always_ff @(posedge clk) begin
    if (rst) begin
      edge_count      <= 32'd0;
      prev_system_clk <= 1'b0;
      counter_started <= 1'b0;
      jitter_detected <= 1'b0;
    end else begin
      prev_system_clk <= system_clk;
      jitter_detected <= 1'b0;

      if (system_clk_rise) begin
        jitter_detected <= counter_started && outside_window;
        edge_count      <= 32'd0;
        counter_started <= 1'b1;
      end else if (counter_started) begin
        edge_count <= edge_count + 32'd1;
      end
    end
  end
endmodule
