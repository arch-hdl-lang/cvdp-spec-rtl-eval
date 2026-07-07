module palindrome_detect #(
    parameter N = 3
) (
    input  clk,
    input  reset,
    input  bit_stream,
    output reg palindrome_detected
);

    reg [N-2:0] history;
    reg [$clog2(N):0] sample_count;

    always @(posedge clk) begin
        if (reset) begin
            history <= '0;
            sample_count <= '0;
            palindrome_detected <= 1'b0;
        end else begin
            palindrome_detected <= (sample_count >= N-1) && (bit_stream == history[N-2]);
            history <= {history[N-3:0], bit_stream};

            if (sample_count < N-1) begin
                sample_count <= sample_count + 1'b1;
            end
        end
    end

endmodule
