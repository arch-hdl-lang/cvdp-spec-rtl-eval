module ttc_counter_lite(
  input  logic        clk,
  input  logic        reset,
  input  logic [3:0]  axi_addr,
  input  logic [31:0] axi_wdata,
  input  logic        axi_write_en,
  input  logic        axi_read_en,
  output logic [31:0] axi_rdata,
  output logic        interrupt
);
  logic [31:0] count;
  logic [31:0] match_value;
  logic [31:0] reload_value;
  logic enable;
  logic interval_mode;
  logic interrupt_enable;
  logic match_flag;

  always_comb begin
    case (axi_addr)
      4'h0: axi_rdata = count;
      4'h1: axi_rdata = match_value;
      4'h2: axi_rdata = reload_value;
      4'h3: axi_rdata = {29'd0, interrupt_enable, interval_mode, enable};
      4'h4: axi_rdata = {31'd0, match_flag};
      default: axi_rdata = 32'd0;
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      count <= 32'd0;
      match_value <= 32'd0;
      reload_value <= 32'd0;
      enable <= 1'b0;
      interval_mode <= 1'b0;
      interrupt_enable <= 1'b0;
      interrupt <= 1'b0;
      match_flag <= 1'b0;
    end else begin
      if (axi_write_en) begin
        case (axi_addr)
          4'h1: match_value <= {16'd0, axi_wdata[15:0]};
          4'h2: reload_value <= {16'd0, axi_wdata[15:0]};
          4'h3: begin
            enable <= axi_wdata[0];
            interval_mode <= axi_wdata[1];
            interrupt_enable <= axi_wdata[2];
          end
          4'h4: begin
            interrupt <= 1'b0;
            match_flag <= 1'b0;
          end
          default: begin
          end
        endcase
      end

      if (enable) begin
        if (count == match_value) begin
          match_flag <= 1'b1;
          interrupt <= interrupt_enable;
          count <= interval_mode ? reload_value : match_value;
        end else begin
          count <= count + 32'd1;
        end
      end
    end
  end
endmodule
