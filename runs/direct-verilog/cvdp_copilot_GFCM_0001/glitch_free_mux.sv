module glitch_free_mux (
    input  wire clk1,
    input  wire clk2,
    input  wire sel,
    input  wire rst_n,
    output wire clkout
);
    reg clk1_en;
    reg clk2_en;

    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n) begin
            clk1_en <= 1'b0;
        end else begin
            clk1_en <= ~sel & ~clk2_en;
        end
    end

    always @(posedge clk2 or negedge rst_n) begin
        if (!rst_n) begin
            clk2_en <= 1'b0;
        end else begin
            clk2_en <= sel & ~clk1_en;
        end
    end

    assign clkout = rst_n & ((clk1 & clk1_en) | (clk2 & clk2_en));
endmodule
