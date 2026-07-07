module hebb_gates (
    input  logic              clk,
    input  logic              rst,
    input  logic              start,
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,
    input  logic        [1:0] gate_select,
    output logic signed [3:0] w1,
    output logic signed [3:0] w2,
    output logic signed [3:0] bias,
    output logic        [3:0] present_state,
    output logic        [3:0] next_state
);

    localparam logic [3:0] STATE_0  = 4'd0;
    localparam logic [3:0] STATE_1  = 4'd1;
    localparam logic [3:0] STATE_2  = 4'd2;
    localparam logic [3:0] STATE_3  = 4'd3;
    localparam logic [3:0] STATE_4  = 4'd4;
    localparam logic [3:0] STATE_5  = 4'd5;
    localparam logic [3:0] STATE_6  = 4'd6;
    localparam logic [3:0] STATE_7  = 4'd7;
    localparam logic [3:0] STATE_8  = 4'd8;
    localparam logic [3:0] STATE_9  = 4'd9;
    localparam logic [3:0] STATE_10 = 4'd10;

    logic signed [3:0] last_a;
    logic signed [3:0] last_b;
    logic        [1:0] last_gate_select;
    logic              have_sample;
    logic              start_q;
    logic        [1:0] iteration;

    function automatic logic signed [3:0] gate_target (
        input logic signed [3:0] lhs,
        input logic signed [3:0] rhs,
        input logic        [1:0] sel
    );
        logic lhs_pos;
        logic rhs_pos;
        begin
            lhs_pos = (lhs == 4'sd1);
            rhs_pos = (rhs == 4'sd1);
            unique case (sel)
                2'b00: gate_target = (lhs_pos && rhs_pos) ? 4'sd1 : -4'sd1;
                2'b01: gate_target = (lhs_pos || rhs_pos) ? 4'sd1 : -4'sd1;
                2'b10: gate_target = (lhs_pos && rhs_pos) ? -4'sd1 : 4'sd1;
                default: gate_target = (lhs_pos || rhs_pos) ? -4'sd1 : 4'sd1;
            endcase
        end
    endfunction

    logic signed [3:0] target_now;
    logic              new_training_run;
    logic              gate_changed;
    logic              new_sample;

    always_comb begin
        target_now = gate_target(a, b, gate_select);
        new_training_run = start && !start_q;
        gate_changed = start && have_sample && (gate_select != last_gate_select);
        new_sample = start && (!have_sample ||
                               (a != last_a) ||
                               (b != last_b) ||
                               (gate_select != last_gate_select));

        unique case (present_state)
            STATE_0:  next_state = start ? STATE_1 : STATE_0;
            STATE_1:  next_state = STATE_2;
            STATE_2:  next_state = STATE_3;
            STATE_3:  next_state = STATE_4;
            STATE_4:  next_state = STATE_5;
            STATE_5:  next_state = STATE_6;
            STATE_6:  next_state = STATE_7;
            STATE_7:  next_state = STATE_8;
            STATE_8:  next_state = STATE_9;
            STATE_9:  next_state = (iteration == 2'd3) ? STATE_10 : STATE_1;
            STATE_10: next_state = STATE_0;
            default:  next_state = STATE_0;
        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            present_state    <= STATE_0;
            w1               <= 4'sd0;
            w2               <= 4'sd0;
            bias             <= 4'sd0;
            last_a           <= 4'sd0;
            last_b           <= 4'sd0;
            last_gate_select <= 2'd0;
            have_sample      <= 1'b0;
            start_q          <= 1'b0;
            iteration        <= 2'd0;
        end else begin
            start_q <= start;

            if (!start) begin
                present_state <= STATE_0;
                have_sample   <= 1'b0;
                iteration     <= 2'd0;
            end else begin
                present_state <= next_state;

                if (present_state == STATE_9 && iteration != 2'd3) begin
                    iteration <= iteration + 2'd1;
                end else if (present_state == STATE_10) begin
                    iteration <= 2'd0;
                end
            end

            if (new_training_run || gate_changed) begin
                w1               <= a * target_now;
                w2               <= b * target_now;
                bias             <= target_now;
                last_a           <= a;
                last_b           <= b;
                last_gate_select <= gate_select;
                have_sample      <= 1'b1;
                iteration        <= 2'd0;
            end else if (new_sample) begin
                w1               <= w1 + (a * target_now);
                w2               <= w2 + (b * target_now);
                bias             <= bias + target_now;
                last_a           <= a;
                last_b           <= b;
                last_gate_select <= gate_select;
                have_sample      <= 1'b1;
            end
        end
    end

endmodule
