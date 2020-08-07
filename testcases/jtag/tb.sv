
`timescale 1ns/100ps

module tb;

    reg  tck;
    reg  trstb;
    reg  tdi;
    reg  tms;
    wire tdo;

    reg  clk;
    reg  rstb;

    wire ms_adc_clk;
    wire ms_adc_rdy;
    wire ms_adc_cmp;

    // ======== stimuli ========

    // ======== dut ========
    dut dut (
        // jtag interface
        .tck    (tck),
        .trstb  (trstb),
        .tdi    (tdi),
        .tms    (tms),
        .tdo    (tdo),
        // chip main signal
        .clk    (clk),
        .rstb   (rstb),
        // analog instruments
        .ms_adc_clk (ms_adc_clk),
        .ms_adc_rdy (ms_adc_rdy),
        .ms_adc_cmp (ms_adc_cmp)
    );

    // ======== checkers ========

endmodule