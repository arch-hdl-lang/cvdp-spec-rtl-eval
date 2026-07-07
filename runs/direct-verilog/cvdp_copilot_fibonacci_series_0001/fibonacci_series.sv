module fibonacci_series (
    input  wire        clk,
    input  wire        rst,
    output reg  [31:0] fib_out,
    output reg         overflow_flag
);

    reg [31:0] reg_a;
    reg [31:0] reg_b;
    reg        overflow_pending;
    reg        restart_hold;

    wire [32:0] next_fib = {1'b0, reg_a} + {1'b0, reg_b};

    always @(posedge clk) begin
        if (rst) begin
            reg_a <= 32'd0;
            reg_b <= 32'd1;
            fib_out <= 32'd0;
            overflow_flag <= 1'b0;
            overflow_pending <= 1'b0;
            restart_hold <= 1'b0;
        end else if (overflow_pending) begin
            reg_a <= 32'd0;
            reg_b <= 32'd1;
            fib_out <= 32'd0;
            overflow_flag <= 1'b1;
            overflow_pending <= 1'b0;
            restart_hold <= 1'b1;
        end else if (restart_hold) begin
            reg_a <= 32'd0;
            reg_b <= 32'd1;
            fib_out <= 32'd0;
            overflow_flag <= 1'b0;
            overflow_pending <= 1'b0;
            restart_hold <= 1'b0;
        end else begin
            fib_out <= reg_b;
            overflow_flag <= 1'b0;
            restart_hold <= 1'b0;

            if (next_fib[32]) begin
                overflow_pending <= 1'b1;
            end else begin
                reg_a <= reg_b;
                reg_b <= next_fib[31:0];
                overflow_pending <= 1'b0;
            end
        end
    end

endmodule
