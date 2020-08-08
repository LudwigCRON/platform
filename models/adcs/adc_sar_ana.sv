
module adc_sar_ana #(
    parameter integer N = 12
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
    
    always @(*)
        if (ms_sample)
            vin = VINP-VINN;

    // resisitive divider or switched cap
    always @(ms_dac, VREF, VSSA)
        vdac = ms_dac * (VREF-VSSA)/2**N;

    // comparator
    always @(negedge ms_clk)
    begin
        ms_cmp <= (vin > vdac);
    end

endmodule