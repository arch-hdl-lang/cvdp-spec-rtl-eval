module caesar_cipher (
    input  logic [7:0] input_char,
    input  logic [3:0] key,
    output logic [7:0] output_char
);
    logic [4:0] shifted_pos;

    always_comb begin
        output_char = input_char;
        shifted_pos = 5'd0;

        if ((input_char >= 8'h41) && (input_char <= 8'h5A)) begin
            shifted_pos = (input_char - 8'h41 + key) % 5'd26;
            output_char = 8'h41 + shifted_pos;
        end else if ((input_char >= 8'h61) && (input_char <= 8'h7A)) begin
            shifted_pos = (input_char - 8'h61 + key) % 5'd26;
            output_char = 8'h61 + shifted_pos;
        end
    end
endmodule
