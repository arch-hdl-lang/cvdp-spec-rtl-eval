module dbi_enc (
    input  wire [39:0] data_in,
    input  wire        clk,
    input  wire        rst_n,
    output reg  [39:0] data_out,
    output reg  [1:0]  dbi_cntrl
);

    function automatic [5:0] popcount20;
        input [19:0] value;
        integer i;
        begin
            popcount20 = 6'd0;
            for (i = 0; i < 20; i = i + 1) begin
                popcount20 = popcount20 + value[i];
            end
        end
    endfunction

    wire [19:0] diff0 = data_in[19:0]  ^ data_out[19:0];
    wire [19:0] diff1 = data_in[39:20] ^ data_out[39:20];

    wire ctrl0 = (popcount20(diff0) > 6'd10);
    wire ctrl1 = (popcount20(diff1) > 6'd10);

    wire [19:0] enc0 = ctrl0 ? ~data_in[19:0]  : data_in[19:0];
    wire [19:0] enc1 = ctrl1 ? ~data_in[39:20] : data_in[39:20];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out  <= 40'h00_0000_0000;
            dbi_cntrl <= 2'b00;
        end else begin
            data_out  <= {enc1, enc0};
            dbi_cntrl <= {ctrl1, ctrl0};
        end
    end

endmodule
