module load_store_unit (
    input  logic        clk,
    input  logic        rst_n,

    output logic        dmem_req_o,
    input  logic        dmem_gnt_i,
    output logic [31:0] dmem_req_addr_o,
    output logic        dmem_req_we_o,
    output logic [3:0]  dmem_req_be_o,
    output logic [31:0] dmem_req_wdata_o,
    input  logic        dmem_rvalid_i,
    input  logic [31:0] dmem_rsp_rdata_i,

    input  logic        ex_if_req_i,
    input  logic        ex_if_we_i,
    input  logic [1:0]  ex_if_type_i,
    input  logic [31:0] ex_if_wdata_i,
    input  logic [31:0] ex_if_addr_base_i,
    input  logic [31:0] ex_if_addr_offset_i,
    output logic        ex_if_ready_o,

    output logic [31:0] wb_if_rdata_o,
    output logic        wb_if_rvalid_o
);

    typedef enum logic [1:0] {
        LSU_IDLE,
        LSU_REQ,
        LSU_WAIT_RSP
    } lsu_state_e;

    lsu_state_e state_q;
    logic       pending_load_q;

    logic [31:0] eff_addr;
    logic [1:0]  addr_lsb;
    logic        aligned;
    logic [3:0]  byte_enable;

    assign eff_addr = ex_if_addr_base_i + ex_if_addr_offset_i;
    assign addr_lsb = eff_addr[1:0];

    always_comb begin
        aligned     = 1'b0;
        byte_enable = 4'b0000;

        unique case (ex_if_type_i)
            2'b00: begin
                aligned     = 1'b1;
                byte_enable = 4'b0001 << addr_lsb;
            end
            2'b01: begin
                aligned     = (addr_lsb[0] == 1'b0);
                byte_enable = addr_lsb[1] ? 4'b1100 : 4'b0011;
            end
            2'b10: begin
                aligned     = (addr_lsb == 2'b00);
                byte_enable = 4'b1111;
            end
            default: begin
                aligned     = 1'b0;
                byte_enable = 4'b0000;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q          <= LSU_IDLE;
            pending_load_q   <= 1'b0;
            dmem_req_o       <= 1'b0;
            dmem_req_addr_o  <= 32'b0;
            dmem_req_we_o    <= 1'b0;
            dmem_req_be_o    <= 4'b0;
            dmem_req_wdata_o <= 32'b0;
            ex_if_ready_o    <= 1'b1;
            wb_if_rdata_o    <= 32'b0;
            wb_if_rvalid_o   <= 1'b0;
        end else begin
            wb_if_rvalid_o <= 1'b0;

            unique case (state_q)
                LSU_IDLE: begin
                    dmem_req_o       <= 1'b0;
                    dmem_req_addr_o  <= 32'b0;
                    dmem_req_we_o    <= 1'b0;
                    dmem_req_be_o    <= 4'b0;
                    dmem_req_wdata_o <= 32'b0;
                    pending_load_q   <= 1'b0;
                    ex_if_ready_o    <= 1'b1;

                    if (ex_if_req_i && aligned) begin
                        dmem_req_o       <= 1'b1;
                        dmem_req_addr_o  <= eff_addr;
                        dmem_req_we_o    <= ex_if_we_i;
                        dmem_req_be_o    <= byte_enable;
                        dmem_req_wdata_o <= ex_if_we_i ? ex_if_wdata_i : 32'b0;
                        pending_load_q   <= !ex_if_we_i;
                        ex_if_ready_o    <= 1'b0;
                        state_q          <= LSU_REQ;
                    end
                end

                LSU_REQ: begin
                    ex_if_ready_o <= 1'b0;

                    if (dmem_gnt_i) begin
                        dmem_req_o       <= 1'b0;
                        dmem_req_addr_o  <= 32'b0;
                        dmem_req_we_o    <= 1'b0;
                        dmem_req_be_o    <= 4'b0;
                        dmem_req_wdata_o <= 32'b0;

                        if (pending_load_q) begin
                            state_q <= LSU_WAIT_RSP;
                        end else begin
                            pending_load_q <= 1'b0;
                            ex_if_ready_o  <= 1'b1;
                            state_q        <= LSU_IDLE;
                        end
                    end
                end

                LSU_WAIT_RSP: begin
                    dmem_req_o       <= 1'b0;
                    dmem_req_addr_o  <= 32'b0;
                    dmem_req_we_o    <= 1'b0;
                    dmem_req_be_o    <= 4'b0;
                    dmem_req_wdata_o <= 32'b0;
                    ex_if_ready_o    <= 1'b0;

                    if (dmem_rvalid_i) begin
                        wb_if_rdata_o  <= dmem_rsp_rdata_i;
                        wb_if_rvalid_o <= 1'b1;
                        pending_load_q <= 1'b0;
                        ex_if_ready_o  <= 1'b1;
                        state_q        <= LSU_IDLE;
                    end
                end

                default: begin
                    state_q          <= LSU_IDLE;
                    pending_load_q   <= 1'b0;
                    dmem_req_o       <= 1'b0;
                    dmem_req_addr_o  <= 32'b0;
                    dmem_req_we_o    <= 1'b0;
                    dmem_req_be_o    <= 4'b0;
                    dmem_req_wdata_o <= 32'b0;
                    ex_if_ready_o    <= 1'b1;
                end
            endcase
        end
    end

endmodule
