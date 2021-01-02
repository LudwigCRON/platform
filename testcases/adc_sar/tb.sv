
`timescale 1ns/100ps

`include "log.svh"

module tb;

    parameter integer N      = 12;
    parameter integer PERIOD = 40;

    reg          clk;
    reg          rstb;
    reg          enable;
    reg          chain_scanen;
    reg          extra_sample;

    reg          soc;
    wire         eoa;
    wire         eoc;
    wire         eoc_it;
    wire [N-1:0] dout;

    wire         ms_adc_clk;
    wire         ms_adc_rdy;
    wire         ms_adc_cmp;
    wire         ms_adc_sample;
    wire [N-1:0] ms_adc_dac;

    real        vind;
    real        vinc;
    real        vinp;
    real        vinn;

    `include "models/real_helper.svh"

    // ======== stimuli ========
    initial begin
        $dumpvars();
        clk          = 1'b0;
        rstb         = 1'b0;
        chain_scanen = 1'b0;
        enable       = 1'b0;
        extra_sample = 1'b0;
        soc          = 1'b0;
        vind         = 0.0;
        #(50ns);
        rstb = 1'b1;
        @(posedge clk) enable = 1'b1;
        #(100ns);
        for (int i = 0; i < 64; i += 1)
        begin
            run_convert();
            wait (eoc_it);
        end
        #(1us);
        `log_Terminate;
    end

    always forever begin
        #(PERIOD/2) clk = !clk;
    end

    initial begin
        #(64us);
        `log_Fatal("Unexpected timeout");
    end

    assign vinp = clip(0.0, vinc + vind/2.0, 1.5);
    assign vinn = clip(0.0, vinc - vind/2.0, 1.5);
    assign vinc = 0.75;

    always @(posedge eoc_it)
        vind = ($urandom() % 2**N) * 1.0/2**N;

    task run_convert;
        wait (eoc);
        @(negedge clk) soc = 1'b1;
        wait (!eoc);
        @(negedge clk) soc = 1'b0;
    endtask

    // ======== dut ========
    adc_sar #(
        .N  (N)
    ) dig (
        .clk            (clk),
        .rstb           (rstb),
        .chain_scanen   (chain_scanen),
        .enable         (enable),
        .extra_sample   (extra_sample),
        .soc            (soc),
        .eoa            (eoa),
        .eoc            (eoc),
        .eoc_it         (eoc_it),
        .dout           (dout),
        .ms_clk         (ms_adc_clk),
        .ms_sample      (ms_adc_sample),
        .ms_rdy         (ms_adc_rdy),
        .ms_dac         (ms_adc_dac),
        .ms_cmp         (ms_adc_cmp)
    );

    adc_sar_ana #(
        .N (N)
    ) ana (
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
    reg [N-1:0] expected_dout;
    wire        inr;

    always @(negedge ms_adc_sample)
    begin
        expected_dout = int'((vinp-vinn) * 2**N);
    end
    
    assign inr = in_range(real'(dout), real'(expected_dout) - 1, real'(expected_dout) + 1);
    
    always @(posedge clk)
    begin
        if (eoc_it && !inr)
            `log_ErrorF2("Wrong conversion result get [%x] expected [%x]", dout, expected_dout);
    end

endmodule
