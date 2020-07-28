
module adder_cla #(
    parameter integer N = 4
) (
    input   wire [N-1:0]    a,
    input   wire [N-1:0]    b,
    input   wire            ci,
    output  wire [N-1:0]    s,
    output  wire            co
);

    wire [N-1:0] p;
    wire [N-1:0] g;
    wire   [N:0] c;

    // ==== addition ====
    xor g_pi[N-1:0] (p, a, b);
    xor g_s[N-1:0]  (s, p, {c[N-2:0], ci});
    and g_g[N-1:0]  (g, a, b);

    // ==== carry tree ====
    wire [N:0] g_w;
    assign g_w = {g, ci};
    
    genvar k;
    genvar j;
    generate
        for(k = 0; k < N; k = k + 1)
        begin
            wire [k:0] c_w;

            for(j = 0; j <= k; j = j + 1)
            begin
                assign c_w[j] = &p[k:j] & g_w[j];
            end

            assign c[k] = (|c_w) | g_w[k+1];
        end
    endgenerate

    buf g_co (co, c[N-1]);

endmodule