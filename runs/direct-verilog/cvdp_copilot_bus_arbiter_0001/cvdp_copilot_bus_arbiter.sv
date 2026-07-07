module cvdp_copilot_bus_arbiter (
    input  wire reset,
    input  wire clk,
    input  wire req1,
    input  wire req2,
    output reg  grant1,
    output reg  grant2
);
    localparam [2:0] IDLE    = 3'b000;
    localparam [2:0] GRANT_1 = 3'b001;
    localparam [2:0] GRANT_2 = 3'b010;
    localparam [2:0] CLEAR   = 3'b011;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (req2) begin
                    next_state = GRANT_2;
                end else if (req1) begin
                    next_state = GRANT_1;
                end else begin
                    next_state = IDLE;
                end
            end

            GRANT_1: begin
                if (req2) begin
                    next_state = GRANT_2;
                end else if (req1) begin
                    next_state = GRANT_1;
                end else begin
                    next_state = CLEAR;
                end
            end

            GRANT_2: begin
                if (req2) begin
                    next_state = GRANT_2;
                end else if (req1) begin
                    next_state = GRANT_1;
                end else begin
                    next_state = CLEAR;
                end
            end

            CLEAR: begin
                if (req2) begin
                    next_state = GRANT_2;
                end else if (req1) begin
                    next_state = GRANT_1;
                end else begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant1 <= 1'b0;
            grant2 <= 1'b0;
        end else begin
            grant1 <= (next_state == GRANT_1);
            grant2 <= (next_state == GRANT_2);
        end
    end
endmodule
