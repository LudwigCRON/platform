`default_nettype none

module jtag_tdr #(
    parameter integer       N_CONF      = 4,
    parameter integer       N_SCOPE     = 1,
    parameter [N_CONF-1:0]  INIT_VALUE  = 0
) (
    input   wire                tck,
    input   wire                trstb,
    input   wire                shift,
    input   wire                select,
    input   wire                capture,
    // ==== interface to sib ====
    input   wire                cti,
    output  wire                cto,
    // ==== interface instrument ====
    input   wire [N_CONF-1:0]   cfi,
    input   wire [N_SCOPE-1:0]  sfi,
    output  wire [N_CONF-1:0]   cfo,
    output  wire [N_SCOPE-1:0]  sfo
);

    localparam integer       NSHR = N_CONF + N_SCOPE;
    localparam [N_SCOPE-1:0] ZERO = 0;

    // ==== shift register ====
    reg [NSHR-1:0] shiftreg;

    always @(posedge tck, negedge trstb)
    begin
        if (!trstb)
            shiftreg <= {NSHR{1'b0}};
        else if (shift && capture)
            shiftreg <= {sfi, shiftreg[N_CONF-1:0]};
        else if (shift)
            shiftreg <= {shiftreg[NSHR-2:0], cti};
    end

    // ==== store configuration ====
    reg [N_CONF-1:0] save;

    always @(posedge tck, negedge trstb)
    begin
        if (!trstb)
            save <= INIT_VALUE;
        else if (capture)
            save <= shiftreg[N_CONF-1:0];
    end

    // ==== buffers/muxes ====
    assign cfo = (select) ? save : cfi;
    buf g_sfo[N_SCOPE-1:0] (sfo, sfi);
    buf g_cto(cto, shiftreg[NSHR-1]);

endmodule