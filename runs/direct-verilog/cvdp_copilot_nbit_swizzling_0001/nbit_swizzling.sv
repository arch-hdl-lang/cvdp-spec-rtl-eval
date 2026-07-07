module nbit_swizzling #(
  parameter int DATA_WIDTH = 64
) (
  input  logic [DATA_WIDTH-1:0] data_in,
  input  logic [1:0]            sel,
  output logic [DATA_WIDTH-1:0] data_out
);

  function automatic logic [DATA_WIDTH-1:0] reverse_chunks;
    input logic [DATA_WIDTH-1:0] value;
    input int                    chunk_size;
    int chunk_base;
    int bit_idx;
    begin
      reverse_chunks = '0;
      for (chunk_base = 0; chunk_base < DATA_WIDTH; chunk_base = chunk_base + chunk_size) begin
        for (bit_idx = 0; bit_idx < chunk_size; bit_idx = bit_idx + 1) begin
          reverse_chunks[chunk_base + bit_idx] = value[chunk_base + chunk_size - 1 - bit_idx];
        end
      end
    end
  endfunction

  always_comb begin
    unique case (sel)
      2'd0: data_out = reverse_chunks(data_in, DATA_WIDTH);
      2'd1: data_out = reverse_chunks(data_in, DATA_WIDTH / 2);
      2'd2: data_out = reverse_chunks(data_in, DATA_WIDTH / 4);
      2'd3: data_out = reverse_chunks(data_in, DATA_WIDTH / 8);
      default: data_out = data_in;
    endcase
  end

endmodule
