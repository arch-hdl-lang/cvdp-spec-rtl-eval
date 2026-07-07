module cvdp_copilot_decode_firstbit #(
  parameter InWidth_g = 32,
  parameter OutReg_g = 0,
  parameter InReg_g = 0,
  parameter PlRegs_g = 0
) (
  input  logic                         Clk,
  input  logic                         Rst,
  input  logic [InWidth_g-1:0]         In_Data,
  input  logic                         In_Valid,
  output logic [$clog2(InWidth_g)-1:0] Out_FirstBit,
  output logic                         Out_Found,
  output logic                         Out_Valid
);

  localparam OutWidth_c = $clog2(InWidth_g);

  logic [InWidth_g-1:0]  data_in;
  logic                  valid_in;
  logic [OutWidth_c-1:0] dec_firstbit;
  logic                  dec_found;
  logic [OutWidth_c-1:0] stage_firstbit [0:PlRegs_g];
  logic                  stage_found    [0:PlRegs_g];
  logic                  stage_valid    [0:PlRegs_g];
  integer i;
  integer p;

  generate
    if (InReg_g != 0) begin : gen_input_reg
      logic [InWidth_g-1:0] data_q;
      logic                 valid_q;
      always_ff @(posedge Clk or posedge Rst) begin
        if (Rst) begin
          data_q  <= '0;
          valid_q <= 1'b0;
        end else begin
          data_q  <= In_Data;
          valid_q <= In_Valid;
        end
      end
      assign data_in  = data_q;
      assign valid_in = valid_q;
    end else begin : gen_input_wire
      assign data_in  = In_Data;
      assign valid_in = In_Valid;
    end
  endgenerate

  always_comb begin
    dec_firstbit = '0;
    dec_found    = 1'b0;
    for (i = 0; i < InWidth_g; i = i + 1) begin
      if (!dec_found && data_in[i]) begin
        dec_firstbit = i[OutWidth_c-1:0];
        dec_found    = 1'b1;
      end
    end
  end

  always_ff @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      for (p = 0; p <= PlRegs_g; p = p + 1) begin
        stage_firstbit[p] <= '0;
        stage_found[p]    <= 1'b0;
        stage_valid[p]    <= 1'b0;
      end
    end else begin
      stage_firstbit[0] <= valid_in && dec_found ? dec_firstbit : '0;
      stage_found[0]    <= valid_in && dec_found;
      stage_valid[0]    <= valid_in;
      for (p = 1; p <= PlRegs_g; p = p + 1) begin
        stage_firstbit[p] <= stage_valid[p-1] && stage_found[p-1] ? stage_firstbit[p-1] : '0;
        stage_found[p]    <= stage_valid[p-1] && stage_found[p-1];
        stage_valid[p]    <= stage_valid[p-1];
      end
    end
  end

  generate
    if (OutReg_g != 0) begin : gen_output_reg
      always_ff @(posedge Clk or posedge Rst) begin
        if (Rst) begin
          Out_FirstBit <= '0;
          Out_Found    <= 1'b0;
          Out_Valid    <= 1'b0;
        end else begin
          Out_FirstBit <= stage_valid[PlRegs_g] && stage_found[PlRegs_g] ? stage_firstbit[PlRegs_g] : '0;
          Out_Found    <= stage_valid[PlRegs_g] && stage_found[PlRegs_g];
          Out_Valid    <= stage_valid[PlRegs_g];
        end
      end
    end else begin : gen_output_wire
      assign Out_FirstBit = stage_valid[PlRegs_g] && stage_found[PlRegs_g] ? stage_firstbit[PlRegs_g] : '0;
      assign Out_Found    = stage_valid[PlRegs_g] && stage_found[PlRegs_g];
      assign Out_Valid    = stage_valid[PlRegs_g];
    end
  endgenerate

endmodule
