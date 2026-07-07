module qam16_mapper_interpolated #(
    parameter N = 4,
    parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = 3
) (
    input  [4*N-1:0] bits,
    output reg [(N + N/2)*3-1:0] I,
    output reg [(N + N/2)*3-1:0] Q
);

    integer p;
    integer i0;
    integer i1;
    integer q0;
    integer q1;
    integer im;
    integer qm;

    always @* begin
        I = 0;
        Q = 0;

        for (p = 0; p < N/2; p = p + 1) begin
            case (bits[(2*p)*4+3 -: 2])
                2'b00: i0 = -3;
                2'b01: i0 = -1;
                2'b10: i0 =  1;
                default: i0 = 3;
            endcase

            case (bits[(2*p+1)*4+3 -: 2])
                2'b00: i1 = -3;
                2'b01: i1 = -1;
                2'b10: i1 =  1;
                default: i1 = 3;
            endcase

            case (bits[(2*p)*4+1 -: 2])
                2'b00: q0 = -3;
                2'b01: q0 = -1;
                2'b10: q0 =  1;
                default: q0 = 3;
            endcase

            case (bits[(2*p+1)*4+1 -: 2])
                2'b00: q1 = -3;
                2'b01: q1 = -1;
                2'b10: q1 =  1;
                default: q1 = 3;
            endcase

            im = (i0 + i1) / 2;
            qm = (q0 + q1) / 2;

            I[(3*p)*3 +: 3] = i0[2:0];
            I[(3*p+1)*3 +: 3] = im[2:0];
            I[(3*p+2)*3 +: 3] = i1[2:0];

            Q[(3*p)*3 +: 3] = q0[2:0];
            Q[(3*p+1)*3 +: 3] = qm[2:0];
            Q[(3*p+2)*3 +: 3] = q1[2:0];
        end
    end

endmodule
