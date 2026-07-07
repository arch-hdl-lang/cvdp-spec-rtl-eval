module cvdp_prbs_gen #(
    parameter integer CHECK_MODE  = 0,
    parameter integer POLY_LENGTH = 31,
    parameter integer POLY_TAP    = 3,
    parameter integer WIDTH       = 16
) (
    input  wire             clk,
    input  wire             rst,
    input  wire [WIDTH-1:0] data_in,
    output reg  [WIDTH-1:0] data_out
);

    reg [POLY_LENGTH-1:0] prbs_reg;

    integer bit_idx;
    reg [POLY_LENGTH-1:0] prbs_next;
    reg [WIDTH-1:0]       prbs_word;
    reg [WIDTH-1:0]       check_word;
    reg                   feedback_bit;
    reg                   shift_in_bit;

    always @* begin
        prbs_next  = prbs_reg;
        prbs_word  = {WIDTH{1'b0}};
        check_word = {WIDTH{1'b0}};

        for (bit_idx = 0; bit_idx < WIDTH; bit_idx = bit_idx + 1) begin
            feedback_bit        = prbs_next[POLY_LENGTH-1] ^ prbs_next[POLY_TAP];
            prbs_word[bit_idx]  = feedback_bit;
            check_word[bit_idx] = data_in[bit_idx] ^ feedback_bit;
            shift_in_bit        = (CHECK_MODE != 0) ? data_in[bit_idx] : feedback_bit;
            prbs_next           = {shift_in_bit, prbs_next[POLY_LENGTH-1:1]};
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            prbs_reg <= {POLY_LENGTH{1'b1}};
            data_out <= {WIDTH{1'b1}};
        end else begin
            prbs_reg <= prbs_next;
            data_out <= (CHECK_MODE != 0) ? check_word : prbs_word;
        end
    end

endmodule
