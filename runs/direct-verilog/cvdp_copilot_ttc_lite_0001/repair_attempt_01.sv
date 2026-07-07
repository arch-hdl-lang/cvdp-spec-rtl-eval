module ttc_counter_lite (
    input  wire        clk,
    input  wire        reset,
    input  wire [3:0]  axi_addr,
    input  wire [31:0] axi_wdata,
    input  wire        axi_write_en,
    input  wire        axi_read_en,
    output reg  [31:0] axi_rdata,
    output reg         interrupt
);

    reg [15:0] count;
    reg [15:0] match_value;
    reg [15:0] reload_value;
    reg        enable;
    reg        interval_mode;
    reg        interrupt_enable;

    wire [15:0] count_plus_one = count + 16'd1;
    wire        match_now      = (count == match_value);
    wire        match_next     = (count_plus_one == match_value);
    wire        match_event    = enable && (match_now || match_next);

    always @(posedge clk) begin
        if (reset) begin
            count            <= 16'd0;
            match_value      <= 16'd0;
            reload_value     <= 16'd0;
            enable           <= 1'b0;
            interval_mode    <= 1'b0;
            interrupt_enable <= 1'b0;
            interrupt        <= 1'b0;
        end else begin
            if (enable) begin
                if (match_event) begin
                    count <= interval_mode ? reload_value : match_value;
                    if (interrupt_enable) begin
                        interrupt <= 1'b1;
                    end
                end else begin
                    count <= count_plus_one;
                end
            end

            if (axi_write_en) begin
                case (axi_addr)
                    4'h1: match_value <= axi_wdata[15:0];
                    4'h2: reload_value <= axi_wdata[15:0];
                    4'h3: begin
                        enable           <= axi_wdata[0];
                        interval_mode    <= axi_wdata[1];
                        interrupt_enable <= axi_wdata[2];
                    end
                    4'h4: interrupt <= 1'b0;
                    default: begin
                    end
                endcase
            end
        end
    end

    always @* begin
        if (axi_read_en) begin
            case (axi_addr)
                4'h0: axi_rdata = {16'd0, count};
                4'h1: axi_rdata = {16'd0, match_value};
                4'h2: axi_rdata = {16'd0, reload_value};
                4'h3: axi_rdata = {29'd0, interrupt_enable, interval_mode, enable};
                4'h4: axi_rdata = {31'd0, interrupt};
                default: axi_rdata = 32'd0;
            endcase
        end else begin
            axi_rdata = 32'd0;
        end
    end

endmodule
