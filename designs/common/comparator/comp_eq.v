`default_nettype none

module comp_eq #(
    parameter integer N = 4
) (
    input   wire [N-1:0] a,
    input   wire [N-1:0] b,
    output  wire         a_eq_b
);

    wire [N-1:0] diff;

    xor g_diff[N-1:0] (diff, a, b);
    
    assign a_eq_b = ~|diff;

endmodule