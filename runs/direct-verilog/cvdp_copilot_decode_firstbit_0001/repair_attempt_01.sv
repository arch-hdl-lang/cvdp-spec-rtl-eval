module cvdp_copilot_decode_firstbit #(
    parameter integer InWidth_g = 32,
    parameter integer InReg_g   = 1,
    parameter integer OutReg_g  = 1,
    parameter integer PlRegs_g  = 1,
    localparam integer BinBits_c = (InWidth_g <= 1) ? 1 : $clog2(InWidth_g)
) (
    input  wire                         Clk,
    input  wire                         Rst,
    input  wire [InWidth_g-1:0]         In_Data,
    input  wire                         In_Valid,
    output wire [BinBits_c-1:0]         Out_FirstBit,
    output wire                         Out_Found,
    output wire                         Out_Valid
);

    reg [InWidth_g-1:0] in_data_q;
    reg                 in_valid_q;

    wire [InWidth_g-1:0] dec_data  = (InReg_g != 0) ? in_data_q  : In_Data;
    wire                 dec_valid = (InReg_g != 0) ? in_valid_q : In_Valid;

    reg [BinBits_c-1:0] dec_first_bit;
    reg                 dec_found;
    integer             bit_idx;

    always @* begin
        dec_first_bit = {BinBits_c{1'b0}};
        dec_found = 1'b0;
        for (bit_idx = 0; bit_idx < InWidth_g; bit_idx = bit_idx + 1) begin
            if (!dec_found && dec_data[bit_idx]) begin
                dec_first_bit = bit_idx[BinBits_c-1:0];
                dec_found = 1'b1;
            end
        end
    end

    generate
        if (InReg_g != 0) begin : gen_input_register
            always @(posedge Clk or posedge Rst) begin
                if (Rst) begin
                    in_data_q  <= {InWidth_g{1'b0}};
                    in_valid_q <= 1'b0;
                end else begin
                    in_data_q  <= In_Data;
                    in_valid_q <= In_Valid;
                end
            end
        end else begin : gen_no_input_register
            always @* begin
                in_data_q  = {InWidth_g{1'b0}};
                in_valid_q = 1'b0;
            end
        end
    endgenerate

    generate
        if (PlRegs_g > 0) begin : gen_pipeline
            reg [BinBits_c-1:0] first_pipe [0:PlRegs_g-1];
            reg                 found_pipe [0:PlRegs_g-1];
            reg                 valid_pipe [0:PlRegs_g-1];
            integer             pipe_idx;

            always @(posedge Clk or posedge Rst) begin
                if (Rst) begin
                    for (pipe_idx = 0; pipe_idx < PlRegs_g; pipe_idx = pipe_idx + 1) begin
                        first_pipe[pipe_idx] <= {BinBits_c{1'b0}};
                        found_pipe[pipe_idx] <= 1'b0;
                        valid_pipe[pipe_idx] <= 1'b0;
                    end
                end else begin
                    first_pipe[0] <= dec_found ? dec_first_bit : {BinBits_c{1'b0}};
                    found_pipe[0] <= dec_found;
                    valid_pipe[0] <= dec_valid;
                    for (pipe_idx = 1; pipe_idx < PlRegs_g; pipe_idx = pipe_idx + 1) begin
                        first_pipe[pipe_idx] <= first_pipe[pipe_idx-1];
                        found_pipe[pipe_idx] <= found_pipe[pipe_idx-1];
                        valid_pipe[pipe_idx] <= valid_pipe[pipe_idx-1];
                    end
                end
            end

            wire [BinBits_c-1:0] pipe_first = first_pipe[PlRegs_g-1];
            wire                 pipe_found = found_pipe[PlRegs_g-1];
            wire                 pipe_valid = valid_pipe[PlRegs_g-1];
        end else begin : gen_pipeline
            wire [BinBits_c-1:0] pipe_first = dec_found ? dec_first_bit : {BinBits_c{1'b0}};
            wire                 pipe_found = dec_found;
            wire                 pipe_valid = dec_valid;
        end
    endgenerate

    generate
        if (OutReg_g != 0) begin : gen_output_register
            reg [BinBits_c-1:0] out_first_q;
            reg                 out_found_q;
            reg                 out_valid_q;

            always @(posedge Clk or posedge Rst) begin
                if (Rst) begin
                    out_first_q <= {BinBits_c{1'b0}};
                    out_found_q <= 1'b0;
                    out_valid_q <= 1'b0;
                end else begin
                    out_first_q <= gen_pipeline.pipe_first;
                    out_found_q <= gen_pipeline.pipe_found;
                    out_valid_q <= gen_pipeline.pipe_valid;
                end
            end

            assign Out_FirstBit = out_first_q;
            assign Out_Found    = out_found_q;
            assign Out_Valid    = out_valid_q;
        end else begin : gen_no_output_register
            assign Out_FirstBit = gen_pipeline.pipe_first;
            assign Out_Found    = gen_pipeline.pipe_found;
            assign Out_Valid    = gen_pipeline.pipe_valid;
        end
    endgenerate

endmodule
