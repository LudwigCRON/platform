`default_nettype none

module reset_resync #(
    parameter integer STAGES = 2
) (
    input   wire    clk,
    input   wire    rstb,
    output  wire    srstb
);

    reg [STAGES-1:0] resync;

    always @(posedge clk, negedge rstb)
        if (!rstb)
            resync <= {STAGES{1'b0}};
        else
            resync <= {resync[STAGES-2:0], 1'b1};

    buf g_o (srstb, resync[STAGES-1]);
endmodule

module dff_resync #(
    parameter integer STAGES = 2
) (
    input   wire    clk,
    input   wire    rstb,
    input   wire    in,
    output  wire    out
);

    reg [STAGES-1:0] resync;

    always @(posedge clk, negedge rstb)
        if (!rstb)
            resync <= {STAGES{1'b0}};
        else
            resync <= {resync[STAGES-2:0], in};

    buf g_o (out, resync[STAGES-1]);
endmodule

module clock_mux #(
    parameter integer N = 2,
    parameter integer STAGES = 2
) (
    input   wire [N-1:0]    clk,
    input   wire [N-1:0]    rstb,
    input   wire [N-1:0]    select,
    output  wire            q
);

    wire [N-1:0] select_o;
    wire [N-1:0] block;
    reg  [N-1:0] select_fo;

    dff_resync #(
        .STAGES (STAGES)
    ) select_resync[N-1:0] (
        .clk    (clk),
        .rstb   (rstb),
        .in     (select & ~block),
        .out    (select_o)
    );

    genvar gi;
    for (gi = 0; gi < N; gi = gi + 1)
    begin
        // ==== ensure only one clock is selected ====
        if (gi == 0)
            assign block[0] = |select_fo[N-1:1];
        else if (gi == N-1)
            assign block[N-1] = |select_fo[N-2:0];
        else
            assign block[gi] = |select_fo[N-1:gi+1] || |select_fo[gi-1:0];

        //==== falling edge latch ====
        always @(clk[gi], select_o)
            if (!clk[gi]) select_fo <= select_o;
    end

    assign q = |(select_fo & clk);
endmodule

module aio_blk_latch #(
    parameter integer N = 4
) (
    input  wire [N-1:0] a,
    input  wire         en,
    output reg [N-1:0]  q
);
    always @(a, en)
        if (en)
            q <= a;
endmodule