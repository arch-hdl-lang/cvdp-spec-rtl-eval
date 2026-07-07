module binary_to_one_hot_decoder_sequential #(
    parameter integer BINARY_WIDTH = 5,
    parameter integer OUTPUT_WIDTH = 32
) (
    input  wire [BINARY_WIDTH-1:0] i_binary_in,
    input  wire                    i_clk,
    input  wire                    i_rstb,
    output reg  [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    always @(posedge i_clk or negedge i_rstb) begin
        if (!i_rstb) begin
            o_one_hot_out <= {OUTPUT_WIDTH{1'b0}};
        end else begin
            o_one_hot_out <= {OUTPUT_WIDTH{1'b0}};
            if (i_binary_in < OUTPUT_WIDTH) begin
                o_one_hot_out[i_binary_in] <= 1'b1;
            end
        end
    end

endmodule
