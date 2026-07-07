module factorial (
    input  logic        clk,
    input  logic        arst_n,
    input  logic [4:0]  num_in,
    input  logic        start,
    output logic        busy,
    output logic [63:0] fact,
    output logic        done
);

    typedef enum logic [1:0] {
        IDLE,
        BUSY,
        DONE
    } state_t;

    state_t state, next_state;
    logic [4:0] target_num;
    logic [5:0] iter_idx;
    logic [63:0] acc;

    assign busy = (state == BUSY);
    assign done = (state == DONE);
    assign fact = acc;

    always_comb begin
        next_state = state;

        unique case (state)
            IDLE: begin
                if (start) begin
                    next_state = BUSY;
                end
            end

            BUSY: begin
                if ((target_num == 5'd0) || (iter_idx >= {1'b0, target_num})) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            state      <= IDLE;
            target_num <= 5'd0;
            iter_idx   <= 6'd1;
            acc        <= 64'd0;
        end else begin
            state <= next_state;

            unique case (state)
                IDLE: begin
                    if (start) begin
                        target_num <= num_in;
                        iter_idx   <= 6'd1;
                        acc        <= 64'd1;
                    end
                end

                BUSY: begin
                    if (target_num == 5'd0) begin
                        acc <= 64'd1;
                    end else begin
                        acc <= acc * {{58{1'b0}}, iter_idx};
                        if (iter_idx < {1'b0, target_num}) begin
                            iter_idx <= iter_idx + 6'd1;
                        end
                    end
                end

                DONE: begin
                end

                default: begin
                    target_num <= 5'd0;
                    iter_idx   <= 6'd1;
                    acc        <= 64'd0;
                end
            endcase
        end
    end

endmodule
