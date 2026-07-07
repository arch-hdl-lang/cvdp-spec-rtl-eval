module cascaded_adder #(
    parameter int IN_DATA_WIDTH = 16,
    parameter int IN_DATA_NS = 4,
    parameter int OUT_DATA_WIDTH = IN_DATA_WIDTH + $clog2(IN_DATA_NS)
) (
    input  logic                                      clk,
    input  logic                                      rst_n,
    input  logic                                      i_valid,
    input  logic [IN_DATA_WIDTH * IN_DATA_NS - 1:0]   i_data,
    output logic                                      o_valid,
    output logic [OUT_DATA_WIDTH - 1:0]               o_data
);

    logic [IN_DATA_WIDTH * IN_DATA_NS - 1:0] data_q;
    logic                                    valid_q;
    logic [OUT_DATA_WIDTH - 1:0]             sum_comb;

    integer idx;

    always_comb begin
        sum_comb = '0;
        for (idx = 0; idx < IN_DATA_NS; idx = idx + 1) begin
            sum_comb = sum_comb + $unsigned(data_q[idx * IN_DATA_WIDTH +: IN_DATA_WIDTH]);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_q  <= '0;
            valid_q <= 1'b0;
            o_valid <= 1'b0;
            o_data  <= '0;
        end else begin
            if (i_valid) begin
                data_q <= i_data;
            end

            valid_q <= i_valid;
            o_valid <= valid_q;
            o_data  <= valid_q ? sum_comb : '0;
        end
    end

endmodule
