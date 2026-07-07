module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk      ,
  input         rst_n    ,

  output        m0_ready ,
  input         m0_valid ,
  input [31:0]  m0_data  ,

  output        m1_ready ,
  input         m1_valid ,
  input [31:0]  m1_data  ,

  input         s_ready  ,
  output reg    s_valid  ,
  output reg [31:0] s_data
);

  assign m0_ready = s_ready;
  assign m1_ready = s_ready;

  wire select_m0 = m0_valid && (!m1_valid || (AFINITY == 0));
  wire select_m1 = m1_valid && (!m0_valid || (AFINITY == 1));
  wire accept    = s_ready && (select_m0 || select_m1);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s_valid <= 1'b0;
      s_data  <= 32'b0;
    end else begin
      s_valid <= accept;
      if (s_ready && select_m0) begin
        s_data <= m0_data;
      end else if (s_ready && select_m1) begin
        s_data <= m1_data;
      end else begin
        s_data <= 32'b0;
      end
    end
  end

endmodule
