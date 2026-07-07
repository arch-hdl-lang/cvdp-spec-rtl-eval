module clock_divider (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] sel,
    output logic       clk_out
);

    logic [2:0] phase;
    logic [2:0] next_phase;

    assign next_phase = phase + 3'd1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase   <= 3'b000;
            clk_out <= 1'b0;
        end else begin
            case (sel)
                2'b00: begin
                    phase   <= next_phase;
                    clk_out <= next_phase[0];
                end
                2'b01: begin
                    phase   <= next_phase;
                    clk_out <= next_phase[1];
                end
                2'b10: begin
                    phase   <= next_phase;
                    clk_out <= next_phase[2];
                end
                default: begin
                    phase   <= 3'b000;
                    clk_out <= 1'b0;
                end
            endcase
        end
    end

endmodule
