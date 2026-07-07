module bcd_counter (
    input  logic       clk,
    input  logic       rst,
    output logic [3:0] ms_hr,
    output logic [3:0] ls_hr,
    output logic [3:0] ms_min,
    output logic [3:0] ls_min,
    output logic [3:0] ms_sec,
    output logic [3:0] ls_sec
);

    always_ff @(posedge clk) begin
        if (rst) begin
            ms_hr  <= 4'd0;
            ls_hr  <= 4'd0;
            ms_min <= 4'd0;
            ls_min <= 4'd0;
            ms_sec <= 4'd0;
            ls_sec <= 4'd0;
        end else if ((ms_hr == 4'd2) && (ls_hr == 4'd3) &&
                     (ms_min == 4'd5) && (ls_min == 4'd9) &&
                     (ms_sec == 4'd5) && (ls_sec == 4'd9)) begin
            ms_hr  <= 4'd0;
            ls_hr  <= 4'd0;
            ms_min <= 4'd0;
            ls_min <= 4'd0;
            ms_sec <= 4'd0;
            ls_sec <= 4'd0;
        end else if ((ms_min == 4'd5) && (ls_min == 4'd9) &&
                     (ms_sec == 4'd5) && (ls_sec == 4'd9)) begin
            ms_min <= 4'd0;
            ls_min <= 4'd0;
            ms_sec <= 4'd0;
            ls_sec <= 4'd0;

            if (((ms_hr == 4'd0) || (ms_hr == 4'd1)) && (ls_hr == 4'd9)) begin
                ms_hr <= ms_hr + 4'd1;
                ls_hr <= 4'd0;
            end else begin
                ls_hr <= ls_hr + 4'd1;
            end
        end else if ((ms_sec == 4'd5) && (ls_sec == 4'd9)) begin
            ms_sec <= 4'd0;
            ls_sec <= 4'd0;

            if (ls_min == 4'd9) begin
                ls_min <= 4'd0;
                ms_min <= ms_min + 4'd1;
            end else begin
                ls_min <= ls_min + 4'd1;
            end
        end else if (ls_sec == 4'd9) begin
            ls_sec <= 4'd0;
            ms_sec <= ms_sec + 4'd1;
        end else begin
            ls_sec <= ls_sec + 4'd1;
        end
    end

endmodule
