module reverse_bits (
    input  logic [31:0] num_in,
    output logic [31:0] num_out
);
    genvar i;

    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_reverse_bits
            assign num_out[i] = num_in[31 - i];
        end
    endgenerate
endmodule
