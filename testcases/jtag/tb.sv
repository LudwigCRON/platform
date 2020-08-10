
`timescale 1ns/100ps

module tb;

    reg         tck;
    reg         trstb;
    reg         tdi;
    reg         tms;
    wire        tdo;

    reg         clk;
    reg         rstb;

    wire        ms_adc_clk;
    wire        ms_adc_rdy;
    wire        ms_adc_cmp;
    wire        ms_adc_sample;
    wire [11:0] ms_adc_dac;

    real        vinp;
    real        vinn;

    // ======== stimuli ========
    initial begin
        tck   = 1'b0;
        trstb = 1'b0;
        #(50ns);
        trstb = 1'b0;
        repeat(8) @(posedge tck);
        #(10us);
        `log_Terminate;
    end
    
    always forever begin
        #(500ns) tck = !tck;
    end
    
    initial begin
        #(200us);
        `log_Fatal("Unexpected timeout");
    end

    // ======== dut ========
    dut dut (
        // jtag interface
        .tck            (tck),
        .trstb          (trstb),
        .tdi            (tdi),
        .tms            (tms),
        .tdo            (tdo),
        // chip main signal
        .clk            (clk),
        .rstb           (rstb),
        // analog instruments
        .ms_adc_clk     (ms_adc_clk),
        .ms_adc_rdy     (ms_adc_rdy),
        .ms_adc_cmp     (ms_adc_cmp),
        .ms_adc_sample  (ms_adc_sample),
        .ms_adc_dac     (ms_adc_dac)
    );

    adc_sar_ana #(
        .N (12)
    ) adc_sar (
        .VDDA       (1.5),
        .VSSA       (0.0),
        .VREF       (1.0),
        .VINP       (vinp),
        .VINN       (vinn),
        .ms_clk     (ms_adc_clk),
        .ms_sample  (ms_adc_sample),
        .ms_dac     (ms_adc_dac),
        .ms_rdy     (ms_adc_rdy),
        .ms_cmp     (ms_adc_cmp)
    );

    // ======== checkers ========

endmodule
