module unpack_one_hot (
    input  logic        sign,
    input  logic        size,
    input  logic [2:0]  one_hot_selector,
    input  logic [255:0] source_reg,
    output logic [511:0] destination_reg
);
    integer i;

    always_comb begin
        destination_reg = 512'b0;

        case (one_hot_selector)
            3'b001: begin
                for (i = 0; i < 64; i = i + 1) begin
                    destination_reg[i*8 +: 8] = sign
                        ? {8{source_reg[i]}}
                        : {7'b0, source_reg[i]};
                end
            end

            3'b010: begin
                for (i = 0; i < 64; i = i + 1) begin
                    destination_reg[i*8 +: 8] = sign
                        ? {{6{source_reg[i*2 + 1]}}, source_reg[i*2 +: 2]}
                        : {6'b0, source_reg[i*2 +: 2]};
                end
            end

            3'b100: begin
                if (size) begin
                    for (i = 0; i < 32; i = i + 1) begin
                        destination_reg[i*16 +: 16] = sign
                            ? {{8{source_reg[i*8 + 7]}}, source_reg[i*8 +: 8]}
                            : {8'b0, source_reg[i*8 +: 8]};
                    end
                end else begin
                    for (i = 0; i < 64; i = i + 1) begin
                        destination_reg[i*8 +: 8] = sign
                            ? {{4{source_reg[i*4 + 3]}}, source_reg[i*4 +: 4]}
                            : {4'b0, source_reg[i*4 +: 4]};
                    end
                end
            end

            default: begin
                destination_reg = source_reg;
            end
        endcase
    end
endmodule
