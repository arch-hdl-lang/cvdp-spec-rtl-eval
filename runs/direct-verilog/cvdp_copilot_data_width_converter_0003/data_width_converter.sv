module data_width_converter (
    input  wire         clk,
    input  wire         reset,
    input  wire [31:0]  data_in,
    input  wire         data_valid,
    output reg  [127:0] o_data_out,
    output reg          o_data_out_valid
);

    reg [95:0] partial_data;
    reg [1:0]  sample_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            partial_data      <= 96'd0;
            sample_count      <= 2'd0;
            o_data_out        <= 128'd0;
            o_data_out_valid  <= 1'b0;
        end else begin
            o_data_out_valid <= 1'b0;

            if (data_valid) begin
                case (sample_count)
                    2'd0: begin
                        partial_data <= {data_in, 64'd0};
                        sample_count <= 2'd1;
                    end
                    2'd1: begin
                        partial_data <= {partial_data[95:64], data_in, 32'd0};
                        sample_count <= 2'd2;
                    end
                    2'd2: begin
                        partial_data <= {partial_data[95:32], data_in};
                        sample_count <= 2'd3;
                    end
                    default: begin
                        o_data_out       <= {partial_data, data_in};
                        o_data_out_valid <= 1'b1;
                        partial_data     <= 96'd0;
                        sample_count     <= 2'd0;
                    end
                endcase
            end
        end
    end

endmodule
