`default_nettype none

module adc_sar #(
    parameter integer N = 8
) (
    input   wire            clk,
    input   wire            rstb,
    input   wire            chain_scanen,
    // configuration
    input   wire            enable,
    input   wire            extra_sample,
    // interface with driver
    input   wire            soc,
    output  wire            eoa,
    output  wire            eoc,
    output  wire            eoc_it,
    output  wire [N-1:0]    dout,
    // interface with analog
    input   wire            ms_rdy,
    input   wire            ms_cmp,
    output  wire            ms_sample,
    output  wire [N-1:0]    ms_dac,
    output  wire            ms_clk
);

    localparam integer STATE_SIZE = $clog2(N + 3);

    `include "designs/adc_sar/adc_sar_encoding.vh"

    wire                  rdy;
    reg                   cmp;
    wire [STATE_SIZE-1:0] current_state;

    dff_resync rdy_resync (
        .clk    (clk),
        .rstb   (rstb),
        .in     (ms_rdy),
        .out    (rdy)
    );

    always @(*)
        if (!clk) cmp = ms_cmp;

    adc_sar_fsm #(
        .N          (N),
        .STATE_SIZE (STATE_SIZE)
    ) fsm (
        .clk            (clk),
        .rstb           (rstb),
        .enable         (enable),
        .extra_sample   (extra_sample),
        .soc            (soc),
        .rdy            (rdy),
        .current_state  (current_state),
        .eoc_it         (eoc_it)
    );

    adc_sar_reconstruction #(
        .N          (N),
        .STATE_SIZE (STATE_SIZE)
    ) reconstruction (
        .clk            (clk),
        .rstb           (rstb),
        .cmp            (cmp),
        .current_state  (current_state),
        .dout           (dout)
    );

    assign eoc = (current_state == S_IDLE);
    assign eoa = (current_state != S_SAMPLE) && (current_state != S_EXTRA_SAMPLE);

    aio_blk_latch #(
        .N  (N+2)
    ) blk_latch (
        .a  ({
            clk,
            ~(eoa & ~eoc),
            dout
        }),
        .en (~chain_scanen),
        .q  ({
            ms_clk,
            ms_sample,
            ms_dac
        })
    );

endmodule