`default_nettype none

module multiplier_comb_lane #(
    parameter integer N = 4
) (
    input   wire            a,
    input   wire [N-1:0]    b,
    input   wire [N-2:0]    ci,
    output  wire [N-1:0]    s,
    output  wire            co
);

    wire [N-1:0] p;
    wire [N-1:0] a_i;
    wire [N-1:0] b_i;
    wire   [N:0] c;

    assign a_i = {ci, 1'b0};

    // ==== addition ====
    and g_a[N-1:0]  (b_i, {N{a}}, b);

    adder_cla #(
        .N  (N)
    ) add (
        .a  (a_i),
        .b  (b_i),
        .ci (1'b0),
        .s  (s),
        .co (co)
    );


endmodule