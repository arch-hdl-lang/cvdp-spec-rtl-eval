module digital_dice_roller (
    input  logic       clk,
    input  logic       reset,
    input  logic       button,
    output logic [2:0] dice_value
);

    typedef enum logic [0:0] {
        IDLE    = 1'b0,
        ROLLING = 1'b1
    } state_t;

    state_t state;
    logic [2:0] counter;
    logic [2:0] next_count;

    always_comb begin
        next_count = (counter == 3'd6) ? 3'd1 : counter + 3'd1;
    end

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            state      <= IDLE;
            counter    <= 3'd1;
            dice_value <= 3'd1;
        end else begin
            case (state)
                IDLE: begin
                    if (button) begin
                        state      <= ROLLING;
                        counter    <= next_count;
                        dice_value <= next_count;
                    end
                end

                ROLLING: begin
                    if (button) begin
                        counter    <= next_count;
                        dice_value <= next_count;
                    end else begin
                        state      <= IDLE;
                        dice_value <= ((counter >= 3'd1) && (counter <= 3'd6)) ? counter : 3'd1;
                    end
                end

                default: begin
                    state      <= IDLE;
                    counter    <= 3'd1;
                    dice_value <= 3'd1;
                end
            endcase
        end
    end

endmodule
