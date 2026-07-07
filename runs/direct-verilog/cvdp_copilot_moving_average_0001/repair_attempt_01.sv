module moving_average (clk, reset, data_in, data_out);
    input clk;
    input reset;
    input [11:0] data_in;
    output [11:0] data_out;
    reg [11:0] data_out;

    reg [11:0] sample0;
    reg [11:0] sample1;
    reg [11:0] sample2;
    reg [11:0] sample3;
    reg [11:0] sample4;
    reg [11:0] sample5;
    reg [11:0] sample6;
    reg [11:0] sample7;
    reg [14:0] sum;
    reg [2:0]  write_index;
    reg [11:0] old_sample;
    wire [14:0] next_sum;

    always @* begin
        case (write_index)
            3'd0: old_sample = sample0;
            3'd1: old_sample = sample1;
            3'd2: old_sample = sample2;
            3'd3: old_sample = sample3;
            3'd4: old_sample = sample4;
            3'd5: old_sample = sample5;
            3'd6: old_sample = sample6;
            default: old_sample = sample7;
        endcase
    end

    assign next_sum = sum - {3'b000, old_sample} + {3'b000, data_in};

    always @(posedge clk) begin
        if (reset) begin
            sum <= 15'd0;
            write_index <= 3'd0;
            data_out <= 12'd0;
            sample0 <= 12'd0;
            sample1 <= 12'd0;
            sample2 <= 12'd0;
            sample3 <= 12'd0;
            sample4 <= 12'd0;
            sample5 <= 12'd0;
            sample6 <= 12'd0;
            sample7 <= 12'd0;
        end else begin
            sum <= next_sum;
            case (write_index)
                3'd0: sample0 <= data_in;
                3'd1: sample1 <= data_in;
                3'd2: sample2 <= data_in;
                3'd3: sample3 <= data_in;
                3'd4: sample4 <= data_in;
                3'd5: sample5 <= data_in;
                3'd6: sample6 <= data_in;
                default: sample7 <= data_in;
            endcase
            write_index <= write_index + 3'd1;
            data_out <= next_sum[14:3];
        end
    end

endmodule
