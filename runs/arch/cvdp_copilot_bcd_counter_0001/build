//! ---
//! tags: [bcd, counter, clock, sequential]
//! ---
//!
//! Implements a 24-hour BCD clock counter. Six 4-bit digits track hours,
//! minutes, and seconds from 00:00:00 through 23:59:59 and reset to zero.
/// 24-hour BCD time counter with active-high reset.
///
/// The module increments seconds on each rising clock edge, cascades carries
/// through minutes and hours, and wraps from 23:59:59 to 00:00:00.
module bcd_counter (
  input logic clk,
  input logic rst,
  output logic [3:0] ms_hr,
  output logic [3:0] ls_hr,
  output logic [3:0] ms_min,
  output logic [3:0] ls_min,
  output logic [3:0] ms_sec,
  output logic [3:0] ls_sec
);

  logic [3:0] hr_tens;
  logic [3:0] hr_ones;
  logic [3:0] min_tens;
  logic [3:0] min_ones;
  logic [3:0] sec_tens;
  logic [3:0] sec_ones;
  assign ms_hr = hr_tens;
  assign ls_hr = hr_ones;
  assign ms_min = min_tens;
  assign ls_min = min_ones;
  assign ms_sec = sec_tens;
  assign ls_sec = sec_ones;
  always_ff @(posedge clk) begin
    if (rst) begin
      hr_ones <= 0;
      hr_tens <= 0;
      min_ones <= 0;
      min_tens <= 0;
      sec_ones <= 0;
      sec_tens <= 0;
    end else begin
      if (sec_ones == 9) begin
        sec_ones <= 0;
        if (sec_tens == 5) begin
          sec_tens <= 0;
          if (min_ones == 9) begin
            min_ones <= 0;
            if (min_tens == 5) begin
              min_tens <= 0;
              if (hr_tens == 2 && hr_ones == 3) begin
                hr_tens <= 0;
                hr_ones <= 0;
              end else if (hr_ones == 9) begin
                hr_ones <= 0;
                hr_tens <= (4 > 1 ? 4 : 1)'(hr_tens + 1);
              end else begin
                hr_ones <= (4 > 1 ? 4 : 1)'(hr_ones + 1);
              end
            end else begin
              min_tens <= (4 > 1 ? 4 : 1)'(min_tens + 1);
            end
          end else begin
            min_ones <= (4 > 1 ? 4 : 1)'(min_ones + 1);
          end
        end else begin
          sec_tens <= (4 > 1 ? 4 : 1)'(sec_tens + 1);
        end
      end else begin
        sec_ones <= (4 > 1 ? 4 : 1)'(sec_ones + 1);
      end
    end
  end

endmodule

