//! ---
//! tags: [moving_average, rolling_sum, datapath]
//! ---
//!
//! Computes a rolling integer average over the most recent eight unsigned
//! 12-bit input samples. Reset clears the stored samples, running sum,
//! fill count, write pointer, and registered output.
/// Synchronous moving average over an eight-sample window.
///
/// Each rising clock edge accepts one input sample when reset is low and
/// updates data_out to the eight-divided rolling sum including that sample.
module moving_average (
  input logic clk,
  input logic reset,
  input logic [11:0] data_in,
  output logic [11:0] data_out
);

  logic [14:0] incoming_wide;
  logic [11:0] oldest_sample;
  logic [14:0] oldest_wide;
  logic [14:0] sum_with_incoming;
  logic [14:0] full_window_sum;
  logic [14:0] next_sum;
  logic [11:0] next_average;
  logic [11:0] sample0;
  logic [11:0] sample1;
  logic [11:0] sample2;
  logic [11:0] sample3;
  logic [11:0] sample4;
  logic [11:0] sample5;
  logic [11:0] sample6;
  logic [11:0] sample7;
  logic [14:0] rolling_sum;
  logic [3:0] fill_count;
  logic [2:0] write_ptr;
  assign incoming_wide = 15'($unsigned(data_in));
  assign oldest_sample = write_ptr == 3'd0 ? sample0 : write_ptr == 3'd1 ? sample1 : write_ptr == 3'd2 ? sample2 : write_ptr == 3'd3 ? sample3 : write_ptr == 3'd4 ? sample4 : write_ptr == 3'd5 ? sample5 : write_ptr == 3'd6 ? sample6 : sample7;
  assign oldest_wide = 15'($unsigned(oldest_sample));
  assign sum_with_incoming = 15'(rolling_sum + incoming_wide);
  assign full_window_sum = 15'(sum_with_incoming - oldest_wide);
  assign next_sum = fill_count < 4'd8 ? sum_with_incoming : full_window_sum;
  assign next_average = next_sum[14:3];
  always_ff @(posedge clk) begin
    if (reset) begin
      data_out <= 0;
      fill_count <= 0;
      rolling_sum <= 0;
      sample0 <= 0;
      sample1 <= 0;
      sample2 <= 0;
      sample3 <= 0;
      sample4 <= 0;
      sample5 <= 0;
      sample6 <= 0;
      sample7 <= 0;
      write_ptr <= 0;
    end else begin
      if (reset) begin
        sample0 <= 0;
        sample1 <= 0;
        sample2 <= 0;
        sample3 <= 0;
        sample4 <= 0;
        sample5 <= 0;
        sample6 <= 0;
        sample7 <= 0;
        rolling_sum <= 0;
        fill_count <= 0;
        write_ptr <= 0;
        data_out <= 0;
      end else begin
        if (write_ptr == 3'd0) begin
          sample0 <= data_in;
        end else if (write_ptr == 3'd1) begin
          sample1 <= data_in;
        end else if (write_ptr == 3'd2) begin
          sample2 <= data_in;
        end else if (write_ptr == 3'd3) begin
          sample3 <= data_in;
        end else if (write_ptr == 3'd4) begin
          sample4 <= data_in;
        end else if (write_ptr == 3'd5) begin
          sample5 <= data_in;
        end else if (write_ptr == 3'd6) begin
          sample6 <= data_in;
        end else begin
          sample7 <= data_in;
        end
        rolling_sum <= next_sum;
        data_out <= next_average;
        if (fill_count < 4'd8) begin
          fill_count <= 4'(fill_count + 4'd1);
        end
        write_ptr <= 3'(write_ptr + 3'd1);
      end
    end
  end

endmodule

