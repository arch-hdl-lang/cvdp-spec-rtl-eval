module binary_to_one_hot_decoder (binary_in, one_hot_out);
    input [4:0] binary_in;
    output [31:0] one_hot_out;

    assign one_hot_out = 32'b00000000000000000000000000000001 << binary_in;
endmodule
