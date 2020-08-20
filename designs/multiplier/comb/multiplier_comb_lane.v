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
    xor g_pi[N-1:0] (p, a_i, b_i);
    xor g_s[N-1:0]  (s, p, c[N-1:0]);

    // ==== carry tree ====
    assign c[0] = 1'b0;
    assign c[N:1] = (a_i & b_i) | (a_i & c[N-1:0]) | (b_i & c[N-1:0]);
    buf g_co (co, c[N]);


endmodule