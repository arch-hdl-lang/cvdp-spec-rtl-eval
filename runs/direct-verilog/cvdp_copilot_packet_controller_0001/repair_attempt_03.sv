module packet_controller(
  input  logic       clk,
  input  logic       rst,
  input  logic       rx_valid_i,
  input  logic [7:0] rx_data_8_i,
  input  logic       tx_done_tick_i,
  output logic       tx_start_o,
  output logic [7:0] tx_data_8_o
);
  logic [7:0] pkt [0:6];
  logic [7:0] resp [0:4];
  logic [2:0] rx_count;
  logic [2:0] tx_count;
  logic       sending;

  logic [7:0] in_sum;
  logic [15:0] num1;
  logic [15:0] num2;
  logic [15:0] result;
  logic [7:0] out_sum;

  always_comb begin
    in_sum = pkt[0] + pkt[1] + pkt[2] + pkt[3] +
             pkt[4] + pkt[5] + pkt[6] + rx_data_8_i;
    num1 = {pkt[2], pkt[3]};
    num2 = {pkt[4], pkt[5]};
    case (pkt[6])
      8'h00: result = num1 + num2;
      8'h01: result = num1 - num2;
      default: result = 16'h0000;
    endcase
    out_sum = 8'hAB + 8'hCD + result[15:8] + result[7:0];
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      rx_count    <= 3'd0;
      tx_count    <= 3'd0;
      sending     <= 1'b0;
      tx_start_o  <= 1'b0;
      tx_data_8_o <= 8'h00;
      pkt[0]      <= 8'h00;
      pkt[1]      <= 8'h00;
      pkt[2]      <= 8'h00;
      pkt[3]      <= 8'h00;
      pkt[4]      <= 8'h00;
      pkt[5]      <= 8'h00;
      pkt[6]      <= 8'h00;
      resp[0]     <= 8'h00;
      resp[1]     <= 8'h00;
      resp[2]     <= 8'h00;
      resp[3]     <= 8'h00;
      resp[4]     <= 8'h00;
    end else begin
      if (sending) begin
        if (tx_done_tick_i && tx_count == 3'd4) begin
          tx_start_o  <= 1'b0;
          tx_data_8_o <= 8'h00;
          tx_count    <= 3'd0;
          sending     <= 1'b0;
        end else begin
          tx_start_o  <= 1'b1;
          tx_data_8_o <= resp[tx_count];
          if (tx_done_tick_i) begin
            tx_count <= tx_count + 3'd1;
          end
        end
      end else begin
        tx_start_o  <= 1'b0;
        tx_data_8_o <= 8'h00;

        if (rx_valid_i) begin
          if (rx_count == 3'd7) begin
            rx_count <= 3'd0;
            if ({pkt[0], pkt[1]} == 16'hBACD && in_sum == 8'h00) begin
              resp[0]     <= 8'hAB;
              resp[1]     <= 8'hCD;
              resp[2]     <= result[15:8];
              resp[3]     <= result[7:0];
              resp[4]     <= 8'(0 - out_sum);
              tx_count    <= 3'd0;
              sending     <= 1'b1;
            end
          end else begin
            pkt[rx_count] <= rx_data_8_i;
            rx_count      <= rx_count + 3'd1;
          end
        end
      end
    end
  end
endmodule
