module signed_unsigned_comparator #(
    parameter WIDTH = 5
) (
    input  wire [WIDTH-1:0] i_A,
    input  wire [WIDTH-1:0] i_B,
    input  wire             i_enable,
    input  wire             i_mode,
    output wire             o_greater,
    output wire             o_less,
    output wire             o_equal
);

    wire signed [WIDTH-1:0] signed_A = i_A;
    wire signed [WIDTH-1:0] signed_B = i_B;

    wire [WIDTH-2:0] magnitude_A = i_A[WIDTH-2:0];
    wire [WIDTH-2:0] magnitude_B = i_B[WIDTH-2:0];

    wire signed_greater = signed_A > signed_B;
    wire signed_less    = signed_A < signed_B;
    wire signed_equal   = signed_A == signed_B;

    wire magnitude_greater = magnitude_A > magnitude_B;
    wire magnitude_less    = magnitude_A < magnitude_B;
    wire magnitude_equal   = magnitude_A == magnitude_B;

    assign o_greater = i_enable && (i_mode ? signed_greater : magnitude_greater);
    assign o_less    = i_enable && (i_mode ? signed_less    : magnitude_less);
    assign o_equal   = i_enable && (i_mode ? signed_equal   : magnitude_equal);

endmodule
