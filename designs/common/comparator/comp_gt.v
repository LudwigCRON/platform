
module comp_gt #(
    parameter integer N = 4
) (
    input   wire [N-1:0] a,
    input   wire [N-1:0] b,
    output  wire         a_gt_b
);

    wire [N-1:0] g;
    wire [N-1:0] p;
    wire [N-1:1] gt;

    and  g_gt[N-1:0] (g, a, ~b);
    xnor g_eq[N-1:0] (p, a,  b);

    genvar gi;
    generate
        for(gi = 1; gi < N; gi = gi + 1)
        begin
            assign gt[gi] = &p[N-1:gi] & g[gi-1];
        end
    endgenerate

    assign a_gt_b = (|gt) | g[N-1];

endmodule