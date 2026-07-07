module gf_multiplier (
    input  logic [3:0] A,
    input  logic [3:0] B,
    output logic [3:0] result
);

    function automatic logic [3:0] xtime(input logic [3:0] value);
        logic [3:0] shifted;
        begin
            shifted = {value[2:0], 1'b0};
            xtime = value[3] ? (shifted ^ 4'b0011) : shifted;
        end
    endfunction

    logic [3:0] multiplicand0;
    logic [3:0] multiplicand1;
    logic [3:0] multiplicand2;
    logic [3:0] multiplicand3;
    logic [3:0] partial0;
    logic [3:0] partial1;
    logic [3:0] partial2;

    always_comb begin
        multiplicand0 = A;

        partial0 = B[0] ? multiplicand0 : 4'b0000;
        multiplicand1 = xtime(multiplicand0);

        partial1 = partial0 ^ (B[1] ? multiplicand1 : 4'b0000);
        multiplicand2 = xtime(multiplicand1);

        partial2 = partial1 ^ (B[2] ? multiplicand2 : 4'b0000);
        multiplicand3 = xtime(multiplicand2);

        result = partial2 ^ (B[3] ? multiplicand3 : 4'b0000);
    end

endmodule
