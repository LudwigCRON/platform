`default_nettype none

module abus_rr #(
    parameter integer N = 4
) (
    input  wire [N-1:0] req,
    input  wire [N-1:0] prio,
    output wire [N-1:0] grant
);

    wire [2*N-1:0] double_req;
    wire [2*N-1:0] double_sel;
    wire [2*N-1:0] double_grant;

    assign double_req = {req, req};
    assign double_grant = double_req & ~double_sel;

    adder_cla #(
        .N (2*N)
    ) sub (
        .a  ({{N{1'b1}}, ~prio}),
        .b  (double_req),
        .ci (1'b1),
        .s  (double_sel),
        .co ()
    );

    assign grant = double_grant[2*N-1:N] | double_grant[N-1:0];

endmodule