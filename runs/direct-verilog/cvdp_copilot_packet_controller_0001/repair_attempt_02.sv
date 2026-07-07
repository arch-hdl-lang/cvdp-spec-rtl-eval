module packet_controller(
  input  logic       clk,
  input  logic       rst,
  input  logic       rx_valid_i,
  input  logic [7:0] rx_data_8_i,
  input  logic       tx_done_tick_i,
  output logic       tx_start_o,
  output logic [7:0] tx_data_8_o
);
  typedef enum logic [2:0] {
    S_IDLE,
    S_GOT_8_BYTES,
    S_RECV_CHECKSUM,
    S_BUILD_RESPONSE,
    S_SEND_FIRST_BYTE,
    S_RESPONSE_READY
  } state_t;

  state_t state;
  logic [7:0] pkt [0:7];
  logic [7:0] resp [0:4];
  logic [2:0] rx_count;
  logic [2:0] tx_count;
  logic [7:0] checksum;
  logic [15:0] num1;
  logic [15:0] num2;
  logic [15:0] result;

  always_comb begin
    checksum = pkt[0] + pkt[1] + pkt[2] + pkt[3] +
               pkt[4] + pkt[5] + pkt[6] + pkt[7];
    num1 = {pkt[2], pkt[3]};
    num2 = {pkt[4], pkt[5]};
    unique case (pkt[6])
      8'h00: result = num1 + num2;
      8'h01: result = num1 - num2;
      default: result = 16'h0000;
    endcase
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state       <= S_IDLE;
      rx_count    <= 3'd0;
      tx_count    <= 3'd0;
      tx_start_o  <= 1'b0;
      tx_data_8_o <= 8'h00;
      resp[0]     <= 8'h00;
      resp[1]     <= 8'h00;
      resp[2]     <= 8'h00;
      resp[3]     <= 8'h00;
      resp[4]     <= 8'h00;
    end else begin
      tx_start_o  <= 1'b0;
      tx_data_8_o <= 8'h00;

      case (state)
        S_IDLE: begin
          tx_count <= 3'd0;
          if (rx_valid_i) begin
            pkt[rx_count] <= rx_data_8_i;
            if (rx_count == 3'd7) begin
              rx_count <= 3'd0;
              state    <= S_GOT_8_BYTES;
            end else begin
              rx_count <= rx_count + 3'd1;
            end
          end
        end

        S_GOT_8_BYTES: begin
          state <= S_RECV_CHECKSUM;
        end

        S_RECV_CHECKSUM: begin
          state <= S_BUILD_RESPONSE;
        end

        S_BUILD_RESPONSE: begin
          resp[0]  <= 8'hAB;
          resp[1]  <= 8'hCD;
          resp[2]  <= result[15:8];
          resp[3]  <= result[7:0];
          resp[4]  <= 8'(0 - (8'hAB + 8'hCD + result[15:8] + result[7:0]));
          tx_count <= 3'd0;
          state    <= S_SEND_FIRST_BYTE;
        end

        S_SEND_FIRST_BYTE: begin
          tx_start_o  <= 1'b1;
          tx_data_8_o <= resp[0];
          if (tx_done_tick_i) begin
            tx_count <= 3'd1;
            state    <= S_RESPONSE_READY;
          end
        end

        S_RESPONSE_READY: begin
          tx_start_o  <= 1'b1;
          tx_data_8_o <= resp[tx_count];
          if (tx_done_tick_i) begin
            if (tx_count == 3'd4) begin
              tx_count <= 3'd0;
              state    <= S_IDLE;
            end else begin
              tx_count <= tx_count + 3'd1;
            end
          end
        end

        default: begin
          rx_count <= 3'd0;
          tx_count <= 3'd0;
          state    <= S_IDLE;
        end
      endcase
    end
  end
endmodule
