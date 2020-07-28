
module adder_rca #(
    parameter integer N = 4
) (
    input   wire [N-1:0]    a,
    input   wire [N-1:0]    b,
    input   wire            ci,
    output  wire [N-1:0]    s,
    output  wire            co
);

    wire [N-1:0] p;
    wire   [N:0] c;

    // ==== addition ====
    xor g_pi[N-1:0] (p, a, b);
    xor g_s[N-1:0]  (s, p, c[N-1:0]);

    // ==== carry tree ====
    assign c[0] = ci;
    assign c[N:1] = (a & b) | (a & c[N-1:0]) | (b & c[N-1:0]);
    buf g_co (co, c[N]);

endmodule