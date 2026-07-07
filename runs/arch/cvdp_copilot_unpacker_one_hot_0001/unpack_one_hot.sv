//! ---
//! tags: [unpack, one_hot, sign_extension, packed_data]
//! ---
//!
//! Combinational unpacker for expanding packed source lanes into a 512-bit destination.
//! The selector chooses 1-, 2-, 4-, or 8-bit source lanes, with signed or unsigned extension.
/// Unpacks a 256-bit packed source register into a 512-bit destination register.
///
/// The output is combinational and zero-initialized before the selected unpacking mode writes its lanes.
module unpack_one_hot (
  input logic [0:0] sign,
  input logic [0:0] size,
  input logic [2:0] one_hot_selector,
  input logic [255:0] source_reg,
  output logic [511:0] destination_reg
);

  always_comb begin
    destination_reg = 0;
    if (one_hot_selector == 3'd1) begin
      for (int i = 0; i <= 63; i++) begin
        destination_reg[i * 8 +: 8] = sign == 1'd1 && source_reg[i] == 1'd1 ? 8'd255 : {7'd0, source_reg[i]};
      end
    end else if (one_hot_selector == 3'd2) begin
      for (int i = 0; i <= 63; i++) begin
        destination_reg[i * 8 +: 8] = sign == 1'd1 && source_reg[i * 2 + 1] == 1'd1 ? {6'd63, source_reg[i * 2 +: 2]} : {6'd0, source_reg[i * 2 +: 2]};
      end
    end else if (one_hot_selector == 3'd4) begin
      if (size == 1'd1) begin
        for (int i = 0; i <= 31; i++) begin
          destination_reg[i * 16 +: 16] = sign == 1'd1 && source_reg[i * 8 + 7] == 1'd1 ? {8'd255, source_reg[i * 8 +: 8]} : {8'd0, source_reg[i * 8 +: 8]};
        end
      end else begin
        for (int i = 0; i <= 63; i++) begin
          destination_reg[i * 8 +: 8] = sign == 1'd1 && source_reg[i * 4 + 3] == 1'd1 ? {4'd15, source_reg[i * 4 +: 4]} : {4'd0, source_reg[i * 4 +: 4]};
        end
      end
    end else begin
      destination_reg[255:0] = source_reg;
    end
  end

endmodule

