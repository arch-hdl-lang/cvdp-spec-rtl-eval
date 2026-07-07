module GP (
    i_A,
    i_B,
    i_Cin,
    o_generate,
    o_propagate,
    o_Cout
);
    input  i_A;
    input  i_B;
    input  i_Cin;
    output o_generate;
    output o_propagate;
    output o_Cout;

    reg o_generate;
    reg o_propagate;
    reg o_Cout;

    always @* begin
        o_generate  = i_A & i_B;
        o_propagate = i_A | i_B;
        o_Cout      = (i_A & i_B) | ((i_A | i_B) & i_Cin);
    end

endmodule
