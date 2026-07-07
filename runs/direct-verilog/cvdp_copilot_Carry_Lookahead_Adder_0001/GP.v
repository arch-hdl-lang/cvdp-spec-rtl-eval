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

    assign o_generate  = i_A & i_B;
    assign o_propagate = i_A | i_B;
    assign o_Cout      = (i_A & i_B) | ((i_A | i_B) & i_Cin);

endmodule
