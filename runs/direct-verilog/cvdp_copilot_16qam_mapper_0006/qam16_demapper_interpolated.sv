module qam16_demapper_interpolated #(
    parameter integer N = 4,
    parameter integer OUT_WIDTH = 4,
    parameter integer IN_WIDTH = 3,
    parameter integer ERROR_THRESHOLD = 1
) (
    input  wire [(N + (N / 2)) * IN_WIDTH - 1:0] I,
    input  wire [(N + (N / 2)) * IN_WIDTH - 1:0] Q,
    output reg  [N * OUT_WIDTH - 1:0] bits,
    output reg  error_flag
);
    localparam integer TOTAL_SAMPLES = N + (N / 2);

    integer pair_idx;
    reg signed [IN_WIDTH-1:0] i_left;
    reg signed [IN_WIDTH-1:0] i_mid;
    reg signed [IN_WIDTH-1:0] i_right;
    reg signed [IN_WIDTH-1:0] q_left;
    reg signed [IN_WIDTH-1:0] q_mid;
    reg signed [IN_WIDTH-1:0] q_right;
    reg [OUT_WIDTH-1:0] left_bits;
    reg [OUT_WIDTH-1:0] right_bits;

    function automatic signed [IN_WIDTH-1:0] get_sample;
        input [(N + (N / 2)) * IN_WIDTH - 1:0] vec;
        input integer idx;
        begin
            get_sample = $signed(vec[(idx * IN_WIDTH) +: IN_WIDTH]);
        end
    endfunction

    function automatic [1:0] amp_to_bits;
        input signed [IN_WIDTH-1:0] amp;
        begin
            case (amp)
                -3: amp_to_bits = 2'b00;
                -1: amp_to_bits = 2'b01;
                 1: amp_to_bits = 2'b10;
                 3: amp_to_bits = 2'b11;
                default: begin
                    if (amp <= -2)
                        amp_to_bits = 2'b00;
                    else if (amp <= 0)
                        amp_to_bits = 2'b01;
                    else if (amp <= 2)
                        amp_to_bits = 2'b10;
                    else
                        amp_to_bits = 2'b11;
                end
            endcase
        end
    endfunction

    function automatic over_threshold;
        input signed [IN_WIDTH-1:0] left_sample;
        input signed [IN_WIDTH-1:0] interp_sample;
        input signed [IN_WIDTH-1:0] right_sample;
        reg signed [IN_WIDTH:0] expected;
        reg signed [IN_WIDTH:0] diff;
        reg [IN_WIDTH:0] abs_diff;
        begin
            expected = ($signed(left_sample) + $signed(right_sample)) / 2;
            diff = $signed(interp_sample) - expected;
            abs_diff = diff[IN_WIDTH] ? -diff : diff;
            over_threshold = (abs_diff > ERROR_THRESHOLD);
        end
    endfunction

    always @* begin
        bits = {N * OUT_WIDTH{1'b0}};
        error_flag = 1'b0;

        for (pair_idx = 0; pair_idx < (N / 2); pair_idx = pair_idx + 1) begin
            i_left  = get_sample(I, 3 * pair_idx);
            i_mid   = get_sample(I, (3 * pair_idx) + 1);
            i_right = get_sample(I, (3 * pair_idx) + 2);
            q_left  = get_sample(Q, 3 * pair_idx);
            q_mid   = get_sample(Q, (3 * pair_idx) + 1);
            q_right = get_sample(Q, (3 * pair_idx) + 2);

            left_bits = {amp_to_bits(i_left), amp_to_bits(q_left)};
            right_bits = {amp_to_bits(i_right), amp_to_bits(q_right)};

            bits[(2 * pair_idx) * OUT_WIDTH +: OUT_WIDTH] = left_bits;
            bits[((2 * pair_idx) + 1) * OUT_WIDTH +: OUT_WIDTH] = right_bits;

            if (over_threshold(i_left, i_mid, i_right) ||
                over_threshold(q_left, q_mid, q_right)) begin
                error_flag = 1'b1;
            end
        end
    end
endmodule
