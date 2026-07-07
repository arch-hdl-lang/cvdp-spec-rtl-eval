//! ---
//! tags: [lifo, stack, synchronous, memory]
//! ---
//!
//! Synchronous configurable-depth LIFO stack. Writes push data when not full,
//! reads pop the most recently written value when not empty, and reset clears
//! the stack state, memory contents, and output register.
/// Top-level synchronous LIFO memory for CVDP problem cvdp_copilot_sync_lifo_0001.
///
/// `data_out` is registered by the read operation and holds its prior value on
/// underflow; `empty` and `full` report the current occupancy combinationally.
module sync_lifo #(
  parameter int DATA_WIDTH = 8,
  parameter int ADDR_WIDTH = 3,
  localparam int DEPTH = 1 << ADDR_WIDTH
) (
  input logic clock,
  input logic reset,
  input logic write_en,
  input logic read_en,
  input logic [DATA_WIDTH-1:0] data_in,
  output logic empty,
  output logic full,
  output logic [DATA_WIDTH-1:0] data_out
);

  logic [ADDR_WIDTH-1:0] write_index;
  logic [ADDR_WIDTH + 1-1:0] read_count;
  logic [ADDR_WIDTH-1:0] read_index;
  logic do_write;
  logic do_read;
  logic [DEPTH-1:0] [DATA_WIDTH-1:0] entries;
  logic [ADDR_WIDTH + 1-1:0] used_count;
  assign empty = used_count == 0;
  assign full = used_count[ADDR_WIDTH] == 1;
  assign write_index = used_count[ADDR_WIDTH - 1:0];
  assign read_count = ((ADDR_WIDTH + 1 > 1 ? ADDR_WIDTH + 1 : 1))'(used_count - 1);
  assign read_index = read_count[ADDR_WIDTH - 1:0];
  assign do_write = write_en && !full;
  assign do_read = read_en && !empty;
  always_ff @(posedge clock) begin
    if (reset) begin
      data_out <= 0;
      for (int __ri0 = 0; __ri0 < DEPTH; __ri0++) begin
        entries[__ri0] <= 0;
      end
      used_count <= 0;
    end else begin
      if (do_write && !do_read) begin
        entries[write_index] <= data_in;
        used_count <= ((ADDR_WIDTH + 1 > 1 ? ADDR_WIDTH + 1 : 1))'(used_count + 1);
      end else if (do_read && !do_write) begin
        data_out <= entries[read_index];
        entries[read_index] <= 0;
        used_count <= read_count;
      end else if (do_write && do_read) begin
        data_out <= entries[read_index];
        entries[read_index] <= data_in;
      end
    end
  end
  // synopsys translate_off
  // Auto-generated safety assertions (bounds / divide-by-zero)
  _auto_bound_vec_0: assert property (@(posedge clock) disable iff (reset) ((do_write && !do_read) |-> (int'(write_index) < (DEPTH))))
    else $fatal(1, "BOUNDS VIOLATION: sync_lifo._auto_bound_vec_0");
  _auto_bound_vec_1: assert property (@(posedge clock) disable iff (reset) (((!(do_write && !do_read)) && (do_read && !do_write)) |-> (int'(read_index) < (DEPTH))))
    else $fatal(1, "BOUNDS VIOLATION: sync_lifo._auto_bound_vec_1");
  _auto_bound_vec_2: assert property (@(posedge clock) disable iff (reset) ((((!(do_write && !do_read)) && (!(do_read && !do_write))) && (do_write && do_read)) |-> (int'(read_index) < (DEPTH))))
    else $fatal(1, "BOUNDS VIOLATION: sync_lifo._auto_bound_vec_2");
  // synopsys translate_on

endmodule

