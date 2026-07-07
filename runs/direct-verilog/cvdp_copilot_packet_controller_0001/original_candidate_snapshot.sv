module packet_controller(
  input  logic       clk,
  input  logic       rst,
  input  logic       rx_valid_i,
  input  logic [7:0] rx_data_8_i,
  input  logic       tx_done_tick_i,
  output logic       tx_start_o,
  output logic [7:0] tx_data_8_o
);
  logic [7:0] pkt [0:7];
  logic [7:0] resp [0:4];
  logic [3:0] cnt;
  logic [3:0] txcnt;
  logic       sending;
  logic [15:0] n1;
  logic [15:0] n2;
  logic [15:0] res;
  logic [7:0] sum;
  integer i;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cnt         <= 4'd0;
      txcnt       <= 4'd0;
      sending     <= 1'b0;
      tx_start_o  <= 1'b0;
      tx_data_8_o <= 8'h00;
    end else begin
      tx_start_o  <= 1'b0;
      tx_data_8_o <= 8'h00;

      if (sending) begin
        tx_start_o  <= 1'b1;
        tx_data_8_o <= resp[txcnt];
        if (tx_done_tick_i) begin
          if (txcnt == 4'd4) begin
            sending <= 1'b0;
            txcnt   <= 4'd0;
            tx_start_o <= 1'b0;
            tx_data_8_o <= 8'h00;
          end else begin
            txcnt <= txcnt + 4'd1;
          end
        end
      end else if (rx_valid_i) begin
        pkt[cnt] <= rx_data_8_i;
        if (cnt == 4'd7) begin
          sum = rx_data_8_i;
          for (i = 0; i < 7; i = i + 1) begin
            sum = sum + pkt[i];
          end

          if ({pkt[0], pkt[1]} == 16'hBACD && sum == 8'h00) begin
            n1 = {pkt[2], pkt[3]};
            n2 = {pkt[4], pkt[5]};
            res = (pkt[6] == 8'h00) ? (n1 + n2) :
                  (pkt[6] == 8'h01) ? (n1 - n2) : 16'd0;
            resp[0] <= 8'hAB;
            resp[1] <= 8'hCD;
            resp[2] <= res[15:8];
            resp[3] <= res[7:0];
            resp[4] <= 8'(0 - (8'hAB + 8'hCD + res[15:8] + res[7:0]));
            sending <= 1'b1;
            txcnt   <= 4'd0;
          end
          cnt <= 4'd0;
          if (!({pkt[0], pkt[1]} == 16'hBACD && sum == 8'h00)) begin
            tx_start_o  <= 1'b0;
            tx_data_8_o <= 8'h00;
            sending     <= 1'b0;
            txcnt       <= 4'd0;
          end
        end else begin
          cnt <= cnt + 4'd1;
        end
      end
    end
  end
endmodule
