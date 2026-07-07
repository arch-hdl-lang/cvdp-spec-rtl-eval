module restoring_division #(
    parameter int WIDTH = 6
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             start,
    input  logic [WIDTH-1:0] dividend,
    input  logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic             valid
);

    localparam integer TOTAL_CYCLES = ((WIDTH & (WIDTH - 1)) == 0) ? WIDTH : (WIDTH + 1);
    localparam integer COUNT_WIDTH  = (TOTAL_CYCLES <= 1) ? 1 : $clog2(TOTAL_CYCLES + 1);

    logic [WIDTH:0]       remainder_work;
    logic [WIDTH-1:0]     dividend_work;
    logic [WIDTH-1:0]     divisor_work;
    logic [COUNT_WIDTH-1:0] cycle_count;
    logic                 busy;

    function automatic [3*WIDTH:0] div_step;
        input logic [WIDTH:0]   rem_in;
        input logic [WIDTH-1:0] quot_in;
        input logic [WIDTH-1:0] dvd_in;
        input logic [WIDTH-1:0] div_in;

        logic [WIDTH:0] shifted_rem;
        logic [WIDTH:0] sub_rem;
        logic [WIDTH:0] next_rem;
        logic           next_bit;
        begin
            shifted_rem = {rem_in[WIDTH-1:0], dvd_in[WIDTH-1]};
            sub_rem = shifted_rem - {1'b0, div_in};

            if (sub_rem[WIDTH] == 1'b0) begin
                next_rem = sub_rem;
                next_bit = 1'b1;
            end else begin
                next_rem = shifted_rem;
                next_bit = 1'b0;
            end

            div_step = {next_rem, ((quot_in << 1) | next_bit), (dvd_in << 1)};
        end
    endfunction

    wire [3*WIDTH:0] start_step = div_step({(WIDTH+1){1'b0}}, {WIDTH{1'b0}}, dividend, divisor);
    wire [WIDTH:0]   start_rem  = start_step[3*WIDTH:2*WIDTH];
    wire [WIDTH-1:0] start_quot = start_step[2*WIDTH-1:WIDTH];
    wire [WIDTH-1:0] start_dvd  = start_step[WIDTH-1:0];

    wire [3*WIDTH:0] work_step = div_step(remainder_work, quotient, dividend_work, divisor_work);
    wire [WIDTH:0]   work_rem  = work_step[3*WIDTH:2*WIDTH];
    wire [WIDTH-1:0] work_quot = work_step[2*WIDTH-1:WIDTH];
    wire [WIDTH-1:0] work_dvd  = work_step[WIDTH-1:0];

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            quotient       <= '0;
            remainder      <= '0;
            valid          <= 1'b0;
            remainder_work <= '0;
            dividend_work  <= '0;
            divisor_work   <= '0;
            cycle_count    <= '0;
            busy           <= 1'b0;
        end else begin
            valid <= 1'b0;

            if (!busy && start) begin
                quotient       <= start_quot;
                remainder      <= start_rem[WIDTH-1:0];
                remainder_work <= start_rem;
                dividend_work  <= start_dvd;
                divisor_work   <= divisor;
                cycle_count    <= 1;

                if (TOTAL_CYCLES == 1) begin
                    valid <= 1'b1;
                    busy  <= 1'b0;
                end else begin
                    busy <= 1'b1;
                end
            end else if (busy) begin
                if (cycle_count < WIDTH) begin
                    quotient       <= work_quot;
                    remainder      <= work_rem[WIDTH-1:0];
                    remainder_work <= work_rem;
                    dividend_work  <= work_dvd;

                    if ((cycle_count + 1) >= TOTAL_CYCLES) begin
                        valid <= 1'b1;
                        busy  <= 1'b0;
                    end
                end else if ((cycle_count + 1) >= TOTAL_CYCLES) begin
                    valid <= 1'b1;
                    busy  <= 1'b0;
                end

                cycle_count <= cycle_count + 1;
            end
        end
    end

endmodule
