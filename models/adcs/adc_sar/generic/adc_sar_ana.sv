
module adc_sar_ana #(
    parameter integer N  = 12,
    parameter real    fc = 50e6
) (
    input   real            VDDA,
    input   real            VSSA,
    input   real            VREF,
    input   real            VINP,
    input   real            VINN,
    input   wire            ms_clk,
    input   wire            ms_sample,
    input   wire [N-1:0]    ms_dac,
    output  wire            ms_rdy,
    output  reg             ms_cmp
);

    real vin;
    real vdac;
    real vdac_rc;
    real rdy;
    
    always @(*)
        if (ms_sample)
            vin = VINP-VINN;

    // resisitive divider or switched cap
    always @(ms_dac, VREF, VSSA)
        vdac = ms_dac * (VREF-VSSA)/2**N;
    
    rc_filter #(
        .fc     (fc),
        .gain   (1.0),
        .dt     (1e-9)
    ) dac (
        .vin    (vdac),
        .vout   (vdac_rc)
    );

    // comparator
    always @(negedge ms_clk)
    begin
        ms_cmp <= (vin > vdac_rc);
    end

    rc_filter #(
        .fc     (10e6),
        .gain   (1.0),
        .dt     (8e-9)
    ) ready (
        .vin    (VDDA-VSSA),
        .vout   (rdy)
    );

    assign ms_rdy = (rdy > (VDDA+VSSA) * 0.7) ? 1'b1 : 1'b0;

endmodule