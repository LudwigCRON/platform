`default_nettype none

module abus_lf #(
    parameter integer N = 4
) (
    input  wire [N-1:0] req,
    output wire [N-1:0] grant
);

    wire [N-1:0] prio;

    adder_cla #(
        .N (N)
    ) sub (
        .a  (req),
        .b  ({N{1'b1}}),
        .ci (1'b0),
        .s  (prio),
        .co ()
    );

    assign grant = req & ~prio;

endmodule