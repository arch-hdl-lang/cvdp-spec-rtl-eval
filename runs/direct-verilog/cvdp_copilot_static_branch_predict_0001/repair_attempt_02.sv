module static_branch_predict(
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic        fetch_valid_i,
  input  logic [31:0] register_addr_i,
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o
);
  logic [6:0] opc;
  logic [31:0] immj;
  logic [31:0] immb;
  logic [31:0] immi;
  logic [31:0] imm;

  always_comb begin
    opc = fetch_rdata_i[6:0];
    immj = {{12{fetch_rdata_i[31]}}, fetch_rdata_i[19:12],
            fetch_rdata_i[20], fetch_rdata_i[30:21], 1'b0};
    immb = {{19{fetch_rdata_i[31]}}, fetch_rdata_i[31],
            fetch_rdata_i[7], fetch_rdata_i[30:25], fetch_rdata_i[11:8], 1'b0};
    immi = {{20{fetch_rdata_i[31]}}, fetch_rdata_i[31:20]};
    imm = 32'd0;
    predict_branch_taken_o = 1'b0;

    if (fetch_valid_i) begin
      if (opc == 7'h6f) begin
        imm = immj;
        predict_branch_taken_o = 1'b1;
      end else if (opc == 7'h67) begin
        imm = immi + register_addr_i;
        predict_branch_taken_o = 1'b1;
      end else if (opc == 7'h63) begin
        imm = immb;
        predict_branch_taken_o = immb[31];
      end
    end

    predict_branch_pc_o = fetch_pc_i + imm;
  end
endmodule
