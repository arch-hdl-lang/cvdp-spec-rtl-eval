module static_branch_predict (
    input  logic [31:0] fetch_rdata_i,
    input  logic [31:0] fetch_pc_i,
    input  logic        fetch_valid_i,
    output logic        predict_branch_taken_o,
    output logic [31:0] predict_branch_pc_o
);

    localparam logic [6:0] OPCODE_BRANCH = 7'h63;
    localparam logic [6:0] OPCODE_JAL    = 7'h6f;
    localparam logic [6:0] OPCODE_JALR   = 7'h67;

    logic [6:0]  opcode;
    logic        instr_jal;
    logic        instr_jalr;
    logic        instr_b;
    logic [31:0] imm_j_type;
    logic [31:0] imm_i_type;
    logic [31:0] imm_b_type;
    logic [31:0] branch_imm;

    always_comb begin
        opcode = fetch_rdata_i[6:0];

        instr_jal  = (opcode == OPCODE_JAL);
        instr_jalr = (opcode == OPCODE_JALR);
        instr_b    = (opcode == OPCODE_BRANCH);

        imm_j_type = {{12{fetch_rdata_i[31]}}, fetch_rdata_i[19:12],
                      fetch_rdata_i[20], fetch_rdata_i[30:21], 1'b0};
        imm_i_type = {{20{fetch_rdata_i[31]}}, fetch_rdata_i[31:20]};
        imm_b_type = {{19{fetch_rdata_i[31]}}, fetch_rdata_i[31],
                      fetch_rdata_i[7], fetch_rdata_i[30:25],
                      fetch_rdata_i[11:8], 1'b0};

        if (instr_jal) begin
            branch_imm = imm_j_type;
        end else if (instr_jalr) begin
            branch_imm = imm_i_type;
        end else if (instr_b) begin
            branch_imm = imm_b_type;
        end else begin
            branch_imm = 32'h0000_0000;
        end

        predict_branch_taken_o =
            fetch_valid_i && (instr_jal || instr_jalr || (instr_b && imm_b_type[31]));

        if (fetch_valid_i && (instr_jal || instr_jalr || instr_b)) begin
            predict_branch_pc_o = fetch_pc_i + branch_imm;
        end else begin
            predict_branch_pc_o = 32'h0000_0000;
        end
    end

endmodule
