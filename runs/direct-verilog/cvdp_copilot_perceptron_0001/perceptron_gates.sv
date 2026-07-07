module perceptron_gates (
    input  logic              clk,
    input  logic              rst_n,
    input  logic signed [3:0] x1,
    input  logic signed [3:0] x2,
    input  logic              learning_rate,
    input  logic signed [3:0] threshold,
    input  logic        [1:0] gate_select,
    output logic signed [3:0] percep_w1,
    output logic signed [3:0] percep_w2,
    output logic signed [3:0] percep_bias,
    output logic        [3:0] present_addr,
    output logic              stop,
    output logic        [2:0] input_index,
    output logic signed [3:0] y_in,
    output logic signed [3:0] y,
    output logic signed [3:0] prev_percep_wt_1,
    output logic signed [3:0] prev_percep_wt_2,
    output logic signed [3:0] prev_percep_bias
);
    logic epoch_changed;
    logic trained_once;

    logic signed [3:0] target;
    logic signed [3:0] y_next;
    logic signed [3:0] wt1_update;
    logic signed [3:0] wt2_update;
    logic signed [3:0] bias_update;
    logic signed [9:0] sum_next;
    logic              do_update;
    logic              update_any;
    logic              epoch_changed_next;

    always_comb begin
        unique case (gate_select)
            2'b00: target = (input_index == 3'd0) ? 4'sd1 : -4'sd1;
            2'b01: target = (input_index == 3'd3) ? -4'sd1 : 4'sd1;
            2'b10: target = (input_index == 3'd3) ? -4'sd1 : 4'sd1;
            default: target = (input_index == 3'd0) ? 4'sd1 : -4'sd1;
        endcase

        sum_next = $signed(percep_bias)
                 + ($signed(x1) * $signed(percep_w1))
                 + ($signed(x2) * $signed(percep_w2));

        if (sum_next > $signed(threshold)) begin
            y_next = 4'sd1;
        end else if (sum_next < $signed(threshold)) begin
            y_next = -4'sd1;
        end else begin
            y_next = 4'sd0;
        end

        do_update = learning_rate && (y_next != target);
        wt1_update = do_update ? $signed(x1 * target) : 4'sd0;
        wt2_update = do_update ? $signed(x2 * target) : 4'sd0;
        bias_update = do_update ? target : 4'sd0;
        update_any = (wt1_update != 4'sd0) || (wt2_update != 4'sd0) || (bias_update != 4'sd0);
        epoch_changed_next = (input_index == 3'd0) ? update_any : (epoch_changed || update_any);
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            percep_w1 <= 4'sd0;
            percep_w2 <= 4'sd0;
            percep_bias <= 4'sd0;
            present_addr <= 4'd0;
            stop <= 1'b0;
            input_index <= 3'd0;
            y_in <= 4'sd0;
            y <= 4'sd0;
            prev_percep_wt_1 <= 4'sd0;
            prev_percep_wt_2 <= 4'sd0;
            prev_percep_bias <= 4'sd0;
            epoch_changed <= 1'b0;
            trained_once <= 1'b0;
        end else if (!stop) begin
            present_addr <= 4'd5;
            y_in <= sum_next[3:0];
            y <= y_next;
            prev_percep_wt_1 <= wt1_update;
            prev_percep_wt_2 <= wt2_update;
            prev_percep_bias <= bias_update;
            percep_w1 <= percep_w1 + wt1_update;
            percep_w2 <= percep_w2 + wt2_update;
            percep_bias <= percep_bias + bias_update;

            if (input_index == 3'd3) begin
                input_index <= 3'd0;
                epoch_changed <= 1'b0;
                trained_once <= 1'b1;
                if (trained_once && !epoch_changed_next) begin
                    stop <= 1'b1;
                end
            end else begin
                input_index <= input_index + 3'd1;
                epoch_changed <= epoch_changed_next;
            end
        end
    end
endmodule
