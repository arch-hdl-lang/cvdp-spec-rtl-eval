module vending_machine (
    input  logic       clk,
    input  logic       rst,
    input  logic       item_button,
    input  logic [2:0] item_selected,
    input  logic [3:0] coin_input,
    input  logic       cancel,
    output logic       dispense_item,
    output logic       return_change,
    output logic [4:0] item_price,
    output logic [4:0] change_amount,
    output logic [2:0] dispense_item_id,
    output logic       error,
    output logic       return_money
);

    typedef enum logic [2:0] {
        IDLE,
        ITEM_SELECTION,
        PAYMENT_VALIDATION,
        DISPENSING_ITEM,
        RETURN_CHANGE,
        RETURN_MONEY
    } state_t;

    state_t state;

    logic [4:0] coins_accumulated;
    logic [2:0] selected_item_id;
    logic       item_button_d;
    logic       cancel_d;
    logic       pending_refund;

    wire item_button_edge = item_button & ~item_button_d;
    wire cancel_edge      = cancel & ~cancel_d;
    wire coin_present     = (coin_input != 4'd0);

    function automatic logic valid_item(input logic [2:0] item_id);
        valid_item = (item_id >= 3'd1) && (item_id <= 3'd4);
    endfunction

    function automatic logic [4:0] price_for_item(input logic [2:0] item_id);
        unique case (item_id)
            3'd1: price_for_item = 5'd10;
            3'd2: price_for_item = 5'd15;
            3'd3: price_for_item = 5'd20;
            3'd4: price_for_item = 5'd25;
            default: price_for_item = 5'd0;
        endcase
    endfunction

    function automatic logic valid_coin(input logic [3:0] coin);
        valid_coin = (coin == 4'd1) || (coin == 4'd2) ||
                     (coin == 4'd5) || (coin == 4'd10);
    endfunction

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state             <= IDLE;
            coins_accumulated <= 5'd0;
            selected_item_id  <= 3'd0;
            item_button_d     <= 1'b0;
            cancel_d          <= 1'b0;
            pending_refund    <= 1'b0;
            dispense_item     <= 1'b0;
            return_change     <= 1'b0;
            item_price        <= 5'd0;
            change_amount     <= 5'd0;
            dispense_item_id  <= 3'd0;
            error             <= 1'b0;
            return_money      <= 1'b0;
        end else begin
            item_button_d <= item_button;
            cancel_d      <= cancel;

            dispense_item <= 1'b0;
            return_change <= 1'b0;
            error         <= 1'b0;
            return_money  <= 1'b0;

            case (state)
                IDLE: begin
                    coins_accumulated <= 5'd0;
                    selected_item_id  <= 3'd0;
                    item_price        <= 5'd0;
                    change_amount     <= 5'd0;
                    pending_refund    <= 1'b0;

                    if (item_button || item_button_edge) begin
                        state <= ITEM_SELECTION;
                    end else if (coin_present) begin
                        error          <= 1'b1;
                        pending_refund <= 1'b1;
                        state          <= RETURN_MONEY;
                    end
                end

                ITEM_SELECTION: begin
                    if (cancel_edge) begin
                        error          <= 1'b1;
                        pending_refund <= (coins_accumulated != 5'd0);
                        state          <= RETURN_MONEY;
                    end else if (valid_item(item_selected)) begin
                        selected_item_id <= item_selected;
                        item_price       <= price_for_item(item_selected);
                        state            <= PAYMENT_VALIDATION;
                    end else if (item_selected != 3'd0) begin
                        error          <= 1'b1;
                        pending_refund <= (coins_accumulated != 5'd0);
                        state          <= RETURN_MONEY;
                    end
                end

                PAYMENT_VALIDATION: begin
                    if (cancel_edge) begin
                        error          <= 1'b1;
                        pending_refund <= (coins_accumulated != 5'd0);
                        state          <= RETURN_MONEY;
                    end else if (coin_present && !valid_coin(coin_input)) begin
                        error             <= 1'b1;
                        return_money      <= (coins_accumulated != 5'd0);
                        coins_accumulated <= 5'd0;
                        selected_item_id  <= 3'd0;
                        item_price        <= 5'd0;
                        change_amount     <= 5'd0;
                        dispense_item_id  <= 3'd0;
                        pending_refund    <= 1'b0;
                        state             <= IDLE;
                    end else if (valid_coin(coin_input)) begin
                        logic [5:0] new_total;
                        logic [4:0] selected_price;

                        new_total      = coins_accumulated + coin_input;
                        selected_price = item_price;

                        if (new_total >= selected_price) begin
                            coins_accumulated <= new_total[4:0];
                            change_amount     <= new_total[4:0] - selected_price;
                            dispense_item_id  <= selected_item_id;
                            state             <= DISPENSING_ITEM;
                        end else begin
                            coins_accumulated <= new_total[4:0];
                        end
                    end
                end

                DISPENSING_ITEM: begin
                    dispense_item    <= 1'b1;
                    dispense_item_id <= selected_item_id;
                    if (change_amount != 5'd0) begin
                        state <= RETURN_CHANGE;
                    end else begin
                        state             <= IDLE;
                        coins_accumulated <= 5'd0;
                        selected_item_id  <= 3'd0;
                        item_price        <= 5'd0;
                    end
                end

                RETURN_CHANGE: begin
                    return_change     <= 1'b1;
                    state             <= IDLE;
                    coins_accumulated <= 5'd0;
                    selected_item_id  <= 3'd0;
                    item_price        <= 5'd0;
                end

                RETURN_MONEY: begin
                    return_money      <= pending_refund;
                    state             <= IDLE;
                    coins_accumulated <= 5'd0;
                    selected_item_id  <= 3'd0;
                    item_price        <= 5'd0;
                    change_amount     <= 5'd0;
                    dispense_item_id  <= 3'd0;
                    pending_refund    <= 1'b0;
                end

                default: begin
                    error             <= 1'b1;
                    state             <= IDLE;
                    coins_accumulated <= 5'd0;
                    selected_item_id  <= 3'd0;
                    item_price        <= 5'd0;
                    change_amount     <= 5'd0;
                    dispense_item_id  <= 3'd0;
                    pending_refund    <= 1'b0;
                end
            endcase
        end
    end

endmodule
