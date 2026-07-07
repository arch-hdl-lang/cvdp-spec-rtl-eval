module perfect_squares_generator (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] sqr_o
);

    logic [31:0] step;
    logic [32:0] next_square;

    assign next_square = {1'b0, sqr_o} + {1'b0, step};

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sqr_o <= 32'd1;
            step  <= 32'd3;
        end else if (sqr_o == 32'hFFFF_FFFF) begin
            sqr_o <= 32'hFFFF_FFFF;
            step  <= step;
        end else if (next_square[32]) begin
            sqr_o <= 32'hFFFF_FFFF;
            step  <= step;
        end else begin
            sqr_o <= next_square[31:0];
            step  <= step + 32'd2;
        end
    end

endmodule
