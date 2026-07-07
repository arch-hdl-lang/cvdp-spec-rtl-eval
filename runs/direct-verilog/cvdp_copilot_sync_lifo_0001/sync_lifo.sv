module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
) (
    input  wire                  clock,
    input  wire                  reset,
    input  wire                  write_en,
    input  wire                  read_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire                  empty,
    output wire                  full,
    output reg  [DATA_WIDTH-1:0] data_out
);
    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] depth_used;

    wire push_ok = write_en && !full;
    wire pop_ok  = read_en && !empty;
    wire [ADDR_WIDTH-1:0] top_index = (depth_used - 1'b1);

    assign empty = (depth_used == 0);
    assign full  = (depth_used == DEPTH);

    integer i;

    always @(posedge clock) begin
        if (reset) begin
            depth_used <= {ADDR_WIDTH+1{1'b0}};
            data_out <= {DATA_WIDTH{1'b0}};
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            case ({push_ok, pop_ok})
                2'b10: begin
                    mem[depth_used[ADDR_WIDTH-1:0]] <= data_in;
                    depth_used <= depth_used + 1'b1;
                end
                2'b01: begin
                    data_out <= mem[top_index];
                    depth_used <= depth_used - 1'b1;
                end
                2'b11: begin
                    data_out <= mem[top_index];
                    mem[top_index] <= data_in;
                end
                default: begin
                    data_out <= data_out;
                    depth_used <= depth_used;
                end
            endcase
        end
    end
endmodule
