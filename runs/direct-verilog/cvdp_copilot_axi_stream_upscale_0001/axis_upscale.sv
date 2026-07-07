module axis_upscale (
    input  wire        clk,
    input  wire        resetn,
    input  wire        dfmt_enable,
    input  wire        dfmt_type,
    input  wire        dfmt_se,
    input  wire        s_axis_valid,
    input  wire [23:0] s_axis_data,
    input  wire        m_axis_ready,
    output wire        s_axis_ready,
    output reg         m_axis_valid,
    output reg  [31:0] m_axis_data
);

    wire        formatted_msb = dfmt_type ? ~s_axis_data[23] : s_axis_data[23];
    wire [7:0]  upper_bits = (dfmt_enable && dfmt_se) ? {8{formatted_msb}} : 8'h00;
    wire [23:0] lower_bits = dfmt_enable ? {formatted_msb, s_axis_data[22:0]} : s_axis_data;
    wire [31:0] formatted_data = {upper_bits, lower_bits};

    assign s_axis_ready = resetn && m_axis_ready;

    always @(posedge clk) begin
        if (!resetn) begin
            m_axis_valid <= 1'b0;
            m_axis_data  <= 32'h00000000;
        end else begin
            m_axis_valid <= s_axis_valid;
            if (s_axis_valid) begin
                m_axis_data <= formatted_data;
            end
        end
    end

endmodule
