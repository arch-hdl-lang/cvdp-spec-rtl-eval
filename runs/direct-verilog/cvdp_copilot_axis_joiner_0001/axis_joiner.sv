module axis_joiner (
    input  wire       clk,
    input  wire       rst,

    input  wire [7:0] s_axis_tdata_1,
    input  wire       s_axis_tvalid_1,
    output wire       s_axis_tready_1,
    input  wire       s_axis_tlast_1,

    input  wire [7:0] s_axis_tdata_2,
    input  wire       s_axis_tvalid_2,
    output wire       s_axis_tready_2,
    input  wire       s_axis_tlast_2,

    input  wire [7:0] s_axis_tdata_3,
    input  wire       s_axis_tvalid_3,
    output wire       s_axis_tready_3,
    input  wire       s_axis_tlast_3,

    output wire [7:0] m_axis_tdata,
    output wire       m_axis_tvalid,
    input  wire       m_axis_tready,
    output wire       m_axis_tlast,
    output wire [1:0] m_axis_tuser,

    output wire       busy
);

    localparam [1:0] STATE_IDLE = 2'd0;
    localparam [1:0] STATE_1    = 2'd1;
    localparam [1:0] STATE_2    = 2'd2;
    localparam [1:0] STATE_3    = 2'd3;

    localparam [1:0] TAG_ID_1 = 2'h1;
    localparam [1:0] TAG_ID_2 = 2'h2;
    localparam [1:0] TAG_ID_3 = 2'h3;

    reg [1:0] state_reg;
    reg       temp_valid_reg;
    reg [7:0] temp_data_reg;
    reg       temp_last_reg;
    reg [1:0] temp_user_reg;

    reg [1:0] selected_stream;
    reg [7:0] selected_data;
    reg       selected_valid;
    reg       selected_last;
    reg [1:0] selected_user;

    always @* begin
        selected_stream = STATE_IDLE;
        selected_data   = 8'h00;
        selected_valid  = 1'b0;
        selected_last   = 1'b0;
        selected_user   = 2'h0;

        case (state_reg)
            STATE_1: begin
                selected_stream = STATE_1;
                selected_data   = s_axis_tdata_1;
                selected_valid  = s_axis_tvalid_1;
                selected_last   = s_axis_tlast_1;
                selected_user   = TAG_ID_1;
            end
            STATE_2: begin
                selected_stream = STATE_2;
                selected_data   = s_axis_tdata_2;
                selected_valid  = s_axis_tvalid_2;
                selected_last   = s_axis_tlast_2;
                selected_user   = TAG_ID_2;
            end
            STATE_3: begin
                selected_stream = STATE_3;
                selected_data   = s_axis_tdata_3;
                selected_valid  = s_axis_tvalid_3;
                selected_last   = s_axis_tlast_3;
                selected_user   = TAG_ID_3;
            end
            default: begin
                if (s_axis_tvalid_1) begin
                    selected_stream = STATE_1;
                    selected_data   = s_axis_tdata_1;
                    selected_valid  = s_axis_tvalid_1;
                    selected_last   = s_axis_tlast_1;
                    selected_user   = TAG_ID_1;
                end else if (s_axis_tvalid_2) begin
                    selected_stream = STATE_2;
                    selected_data   = s_axis_tdata_2;
                    selected_valid  = s_axis_tvalid_2;
                    selected_last   = s_axis_tlast_2;
                    selected_user   = TAG_ID_2;
                end else if (s_axis_tvalid_3) begin
                    selected_stream = STATE_3;
                    selected_data   = s_axis_tdata_3;
                    selected_valid  = s_axis_tvalid_3;
                    selected_last   = s_axis_tlast_3;
                    selected_user   = TAG_ID_3;
                end
            end
        endcase
    end

    wire selected_ready = !temp_valid_reg;
    wire selected_fire  = selected_valid && selected_ready;
    wire output_fire    = m_axis_tvalid && m_axis_tready;

    assign s_axis_tready_1 = (selected_stream == STATE_1) && selected_ready;
    assign s_axis_tready_2 = (selected_stream == STATE_2) && selected_ready;
    assign s_axis_tready_3 = (selected_stream == STATE_3) && selected_ready;

    assign m_axis_tvalid = temp_valid_reg || selected_valid;
    assign m_axis_tdata  = temp_valid_reg ? temp_data_reg : selected_data;
    assign m_axis_tlast  = temp_valid_reg ? temp_last_reg : selected_last;
    assign m_axis_tuser  = temp_valid_reg ? temp_user_reg : selected_user;

    assign busy = (state_reg != STATE_IDLE) || temp_valid_reg ||
                  s_axis_tvalid_1 || s_axis_tvalid_2 || s_axis_tvalid_3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg      <= STATE_IDLE;
            temp_valid_reg <= 1'b0;
            temp_data_reg  <= 8'h00;
            temp_last_reg  <= 1'b0;
            temp_user_reg  <= 2'h0;
        end else begin
            if (temp_valid_reg && m_axis_tready) begin
                temp_valid_reg <= 1'b0;
            end

            if (!temp_valid_reg && selected_valid && !m_axis_tready) begin
                temp_valid_reg <= 1'b1;
                temp_data_reg  <= selected_data;
                temp_last_reg  <= selected_last;
                temp_user_reg  <= selected_user;
            end

            if (state_reg == STATE_IDLE) begin
                if (selected_fire && !selected_last) begin
                    state_reg <= selected_stream;
                end
            end else if (output_fire && m_axis_tlast) begin
                state_reg <= STATE_IDLE;
            end
        end
    end

endmodule
