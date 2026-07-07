module matrix_multiplier #(
    parameter int ROW_A = 4,
    parameter int COL_A = 4,
    parameter int ROW_B = 4,
    parameter int COL_B = 4,
    parameter int INPUT_DATA_WIDTH = 8,
    parameter int OUTPUT_DATA_WIDTH = (2 * INPUT_DATA_WIDTH) + $clog2(COL_A)
) (
    input  logic [(ROW_A * COL_A * INPUT_DATA_WIDTH) - 1:0] matrix_a,
    input  logic [(ROW_B * COL_B * INPUT_DATA_WIDTH) - 1:0] matrix_b,
    output logic [(ROW_A * COL_B * OUTPUT_DATA_WIDTH) - 1:0] matrix_c
);

    always_comb begin
        matrix_c = '0;

        for (int row = 0; row < ROW_A; row++) begin
            for (int col = 0; col < COL_B; col++) begin
                logic [OUTPUT_DATA_WIDTH - 1:0] sum;
                sum = '0;

                for (int idx = 0; idx < COL_A; idx++) begin
                    logic [(2 * INPUT_DATA_WIDTH) - 1:0] product;
                    product =
                        matrix_a[((row * COL_A + idx) * INPUT_DATA_WIDTH) +: INPUT_DATA_WIDTH] *
                        matrix_b[((idx * COL_B + col) * INPUT_DATA_WIDTH) +: INPUT_DATA_WIDTH];
                    sum = sum + product;
                end

                matrix_c[((row * COL_B + col) * OUTPUT_DATA_WIDTH) +: OUTPUT_DATA_WIDTH] = sum;
            end
        end
    end

endmodule
