`default_nettype none

module gray_counter #(
    parameter integer N = 4
) (
    input   wire         clk,
    input   wire         load,
    input   wire [N-1:0] load_value,
    input   wire         enable,
    output  reg  [N-1:0] q
);

    reg  [N-1:0] count;
    reg  [N-1:0] count_r;
    wire [N-1:0] count_next;
    wire [N-1:0] count_init;

    always @(*)
        if (clk && load)
            count <= count_init;
        else if (clk && enable)
            count <= count_next;

    always @(*)
        if (!clk) count_r <= count;

    assign count_init = load_value ^ {1'b0, count_init[N-1:1]};

    adder_cla #(
        .N  (N)
    ) cnt (
        .a  (count_r),
        .b  ({N{1'b0}}),
        .ci (1'b1),
        .s  (count_next),
        .co ()
    );

    always @(posedge clk)
    begin
        if (load)
            q <= load_value;
        else if (enable)
            q <= count_r ^ {1'b0, count_r[N-1:1]};
    end

endmodule