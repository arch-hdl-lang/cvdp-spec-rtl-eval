module thermostat (
    input  wire       i_clk,
    input  wire       i_rst,
    input  wire [5:0] i_temp_feedback,
    input  wire       i_fan_on,
    input  wire       i_enable,
    input  wire       i_fault,
    input  wire       i_clr,
    output reg        o_heater_full,
    output reg        o_heater_medium,
    output reg        o_heater_low,
    output reg        o_aircon_full,
    output reg        o_aircon_medium,
    output reg        o_aircon_low,
    output reg        o_fan,
    output reg  [2:0] o_state
);

    localparam [2:0] HEAT_LOW  = 3'b000;
    localparam [2:0] HEAT_MED  = 3'b001;
    localparam [2:0] HEAT_FULL = 3'b010;
    localparam [2:0] AMBIENT   = 3'b011;
    localparam [2:0] COOL_LOW  = 3'b100;
    localparam [2:0] COOL_MED  = 3'b101;
    localparam [2:0] COOL_FULL = 3'b110;

    reg fault_latched;
    reg [2:0] next_state;

    always @* begin
        if (i_temp_feedback[5]) begin
            next_state = HEAT_FULL;
        end else if (i_temp_feedback[4]) begin
            next_state = HEAT_MED;
        end else if (i_temp_feedback[3]) begin
            next_state = HEAT_LOW;
        end else if (i_temp_feedback[0]) begin
            next_state = COOL_FULL;
        end else if (i_temp_feedback[1]) begin
            next_state = COOL_MED;
        end else if (i_temp_feedback[2]) begin
            next_state = COOL_LOW;
        end else begin
            next_state = AMBIENT;
        end
    end

    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            fault_latched   <= 1'b0;
            o_state         <= AMBIENT;
            o_heater_full   <= 1'b0;
            o_heater_medium <= 1'b0;
            o_heater_low    <= 1'b0;
            o_aircon_full   <= 1'b0;
            o_aircon_medium <= 1'b0;
            o_aircon_low    <= 1'b0;
            o_fan           <= 1'b0;
        end else begin
            if (i_fault) begin
                fault_latched <= 1'b1;
            end else if (i_clr) begin
                fault_latched <= 1'b0;
            end

            o_heater_full   <= 1'b0;
            o_heater_medium <= 1'b0;
            o_heater_low    <= 1'b0;
            o_aircon_full   <= 1'b0;
            o_aircon_medium <= 1'b0;
            o_aircon_low    <= 1'b0;
            o_fan           <= 1'b0;

            if (i_fault || fault_latched || !i_enable) begin
                o_state <= AMBIENT;
            end else if (i_clr) begin
                o_state <= AMBIENT;
            end else begin
                o_state <= next_state;

                case (next_state)
                    HEAT_FULL: begin
                        o_heater_full <= 1'b1;
                        o_fan         <= 1'b1;
                    end
                    HEAT_MED: begin
                        o_heater_medium <= 1'b1;
                        o_fan           <= 1'b1;
                    end
                    HEAT_LOW: begin
                        o_heater_low <= 1'b1;
                        o_fan        <= 1'b1;
                    end
                    COOL_FULL: begin
                        o_aircon_full <= 1'b1;
                        o_fan         <= 1'b1;
                    end
                    COOL_MED: begin
                        o_aircon_medium <= 1'b1;
                        o_fan           <= 1'b1;
                    end
                    COOL_LOW: begin
                        o_aircon_low <= 1'b1;
                        o_fan        <= 1'b1;
                    end
                    default: begin
                        o_fan <= i_fan_on;
                    end
                endcase
            end
        end
    end

endmodule
