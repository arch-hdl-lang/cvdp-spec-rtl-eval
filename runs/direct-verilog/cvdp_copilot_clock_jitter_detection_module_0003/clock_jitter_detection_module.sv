module clock_jitter_detection_module #(
  parameter integer JITTER_THRESHOLD = 5
) (
  input  logic clk,
  input  logic system_clk,
  input  logic rst,
  output logic jitter_detected
);
  localparam [31:0] LOW_LIMIT  = (JITTER_THRESHOLD > 1) ? (JITTER_THRESHOLD - 1) : 0;
  localparam [31:0] HIGH_LIMIT = JITTER_THRESHOLD + 1;

  logic [31:0] edge_count;
  logic        prev_system_clk;
  logic        counter_started;

  wire        system_clk_rise = system_clk && !prev_system_clk;
  wire [31:0] measured_count  = edge_count + 32'd1;
  wire        outside_window  = (measured_count < LOW_LIMIT) || (measured_count > HIGH_LIMIT);
  wire        timeout_jitter  = counter_started && (measured_count > HIGH_LIMIT);

  always_ff @(posedge clk) begin
    if (rst) begin
      edge_count      <= 32'd0;
      prev_system_clk <= system_clk;
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
        jitter_detected <= timeout_jitter;
        edge_count      <= edge_count + 32'd1;
      end
    end
  end
endmodule
