module digital_dice_roller(
  input  logic       clk,
  input  logic       reset,
  input  logic       button,
  output logic [2:0] dice_value
);
  logic [2:0] counter;
  logic [2:0] next_value;

  always_comb begin
    next_value = (counter == 3'd6) ? 3'd1 : counter + 3'd1;
  end

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      counter    <= 3'd1;
      dice_value <= 3'd1;
    end else if (button) begin
      counter    <= next_value;
      dice_value <= next_value;
    end
  end
endmodule
