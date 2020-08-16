`default_nettype none

// ======== Resynchronization ========
/*
    reset_resync: async rstb -> sync srstb
    dff_resync: basic signal resync
    pulse_toggle: first part of toggle resync
    pulse_resync: second part of toggle resync
    bus_resync: recirculation mux
*/
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

module pulse_toggle #(
    parameter integer MODE = 0
) (
    input   wire    clk,
    input   wire    rstb,
    input   wire    in,
    output  wire    out
);

    reg [2:0] resync;
    wire      toggle;

    generate
        // both edges
        if (MODE == 0)
            assign toggle = resync[1] ^ resync[0];
        // rising edge
        else if (MODE == 1)
            assign toggle = resync[0] & ~resync[1];
        // falling edge
        else
            assign toogle = resync[1] & ~resync[0];
    endgenerate

    always @(posedge clk, negedge rstb)
        if (!rstb)
            resync <= 3'b000;
        else if (toggle)
            resync <= {~resync[2],resync[0], in};
        else
            resync <= {resync[2], resync[0], in};

    buf g_o (out, resync[2]);

endmodule

module pulse_resync #(
    parameter integer MODE   = 0,
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
    
    generate
        // both edges
        if (MODE == 0)
            assign out = resync[STAGES-1] ^ resync[STAGES-2];
        // rising edge
        else if (MODE == 1)
            assign out = resync[STAGES-2] & ~resync[STAGES-1];
        // falling edge
        else
            assign out = resync[STAGES-1] & ~resync[STAGES-2];
    endgenerate

endmodule

module bus_resync #(
    parameter integer N      = 4,
    parameter integer STAGES = 2
) (
    input   wire            clka,
    input   wire            rsta,
    input   wire            clkb,
    input   wire            rstb,
    input   wire [N-1:0]    in,
    input   wire            valida,
    input   wire            readyb,
    output  reg  [N-1:0]    out,
    output  wire            readya,
    output  wire            validb
);

    wire tvalid;
    wire tready;

    pulse_toggle #(
        .MODE   (1)
    ) toggle_valid (
        .clk    (clka),
        .rstb   (rsta),
        .in     (valida),
        .out    (tvalid)
    );

    pulse_resync #(
        .MODE   (1)
    ) pulse_valid (
        .clk    (clkb),
        .rstb   (rstb),
        .in     (tvalid),
        .out    (validb)
    );

    pulse_toggle #(
        .MODE   (1)
    ) toggle_ready (
        .clk    (clkb),
        .rstb   (rstb),
        .in     (readyb),
        .out    (tready)
    );

    pulse_resync #(
        .MODE   (1)
    ) pulse_ready (
        .clk    (clka),
        .rstb   (rsta),
        .in     (tready),
        .out    (readya)
    );

    always @(posedge clkb, negedge rstb)
        if (!rstb)
            out <= {N{1'b0}};
        else if (validb)
            out <= in;

endmodule

// ======== clock selection ========
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

// ======== mix mode component ========
/*
    aio_blk_latch: block signal during atpg
*/
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