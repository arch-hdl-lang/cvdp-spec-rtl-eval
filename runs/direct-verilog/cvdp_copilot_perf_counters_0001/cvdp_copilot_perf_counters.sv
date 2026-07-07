module cvdp_copilot_perf_counters #(
    parameter integer CNT_W = 8
) (
    input  wire             clk,
    input  wire             reset,
    input  wire             sw_req_i,
    input  wire             cpu_trig_i,
    output wire [CNT_W-1:0] p_count_o
);

    reg [CNT_W-1:0] count_q;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_q <= {CNT_W{1'b0}};
        end else if (sw_req_i) begin
            count_q <= cpu_trig_i ? ({CNT_W{1'b0}} + 1'b1) : {CNT_W{1'b0}};
        end else if (cpu_trig_i) begin
            count_q <= count_q + 1'b1;
        end
    end

    assign p_count_o = sw_req_i ? count_q : {CNT_W{1'b0}};

endmodule
