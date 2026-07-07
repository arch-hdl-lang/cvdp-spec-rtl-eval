module car_parking_system #(
    parameter integer TOTAL_SPACES = 12
) (
    input  wire clk,
    input  wire reset,
    input  wire vehicle_entry_sensor,
    input  wire vehicle_exit_sensor,
    output reg  [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg  [$clog2(TOTAL_SPACES)-1:0] count_car,
    output wire led_status,
    output wire [6:0] seven_seg_display_available_tens,
    output wire [6:0] seven_seg_display_available_units,
    output wire [6:0] seven_seg_display_count_tens,
    output wire [6:0] seven_seg_display_count_units
);
    localparam IDLE             = 2'd0;
    localparam ENTRY_PROCESSING = 2'd1;
    localparam EXIT_PROCESSING  = 2'd2;
    localparam FULL             = 2'd3;

    reg [1:0] state;

    function [6:0] seven_seg_encode;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seven_seg_encode = 7'b1111110;
                4'd1: seven_seg_encode = 7'b0110000;
                4'd2: seven_seg_encode = 7'b1101101;
                4'd3: seven_seg_encode = 7'b1111001;
                4'd4: seven_seg_encode = 7'b0110011;
                4'd5: seven_seg_encode = 7'b1011011;
                4'd6: seven_seg_encode = 7'b1011111;
                4'd7: seven_seg_encode = 7'b1110000;
                4'd8: seven_seg_encode = 7'b1111111;
                4'd9: seven_seg_encode = 7'b1111011;
                default: seven_seg_encode = 7'b0000001;
            endcase
        end
    endfunction

    wire parking_available = (available_spaces != 0);
    wire cars_present = (count_car != 0);
    wire entry_only = vehicle_entry_sensor && !vehicle_exit_sensor;
    wire exit_only = vehicle_exit_sensor && !vehicle_entry_sensor;
    wire simultaneous_full_exit = vehicle_entry_sensor && vehicle_exit_sensor &&
                                  !parking_available && cars_present;

    wire do_entry = entry_only && parking_available;
    wire do_exit = (exit_only && cars_present) || simultaneous_full_exit;

    assign led_status = (available_spaces != 0);

    assign seven_seg_display_available_tens  = seven_seg_encode((available_spaces / 10) % 10);
    assign seven_seg_display_available_units = seven_seg_encode(available_spaces % 10);
    assign seven_seg_display_count_tens      = seven_seg_encode((count_car / 10) % 10);
    assign seven_seg_display_count_units     = seven_seg_encode(count_car % 10);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            state <= IDLE;
        end else begin
            if (do_entry) begin
                available_spaces <= available_spaces - 1'b1;
                count_car <= count_car + 1'b1;
                state <= (available_spaces == 1) ? FULL : ENTRY_PROCESSING;
            end else if (do_exit) begin
                available_spaces <= available_spaces + 1'b1;
                count_car <= count_car - 1'b1;
                state <= EXIT_PROCESSING;
            end else if (!parking_available) begin
                state <= FULL;
            end else begin
                state <= IDLE;
            end
        end
    end

endmodule
