`default_nettype none

module multipler_comb #(
    parameter integer N = 8
) (
    input   wire [N-1:0]   a,
    input   wire [N-1:0]   b,
    output  wire [2*N-1:0] m
);
    wire [N-1:0] s[N-1:0];
    wire [N-1:0] c;
    wire [N-1:0] p;

    // ==== partial sums ====
    genvar gi;

        multiplier_comb_lane #(
            .N  (N)
        ) lane_0 (
            .a  (a[N-1]),
            .b  (b),
            .ci ({(N-1){1'b0}}),
            .s  (s[N-1]),
            .co (c[N-1])
        );

        assign p[N-1] = s[N-1][N-1];

    generate
        for(gi = 1; gi < N; gi++)
        begin
            multiplier_comb_lane #(
                .N  (N)
            ) lane (
                .a  (a[N-gi-1]),
                .b  (b),
                .ci (s[N-gi][N-2:0]),
                .s  (s[N-gi-1]),
                .co (c[N-gi-1])
            );

            assign p[N-gi-1] = s[N-gi-1][N-1];
        end
    endgenerate

    // ==== final sum ====
    adder_cla #(
        .N  (N)
    ) last (
        .a  ({1'b0, p[N-1:1]}),
        .b  (c),
        .ci (1'b0),
        .s  (m[2*N-1:N]),
        .co ()
    );

    assign m[N-1:0] = s[0];

endmodule