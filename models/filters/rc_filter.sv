
module rc_filter #(
    parameter real fc    = 314159.0,
    parameter real gain  = 1.0,
    parameter real dt    = 1e-9
) (
    input  real vin,
    output real vout
);
    `include "models/real_helper.svh"

    localparam real T  = dt * 1e9;
    localparam real wc = 6.283185307 * fc;

    real vin_r;
    real vout_r;
    real vo;

    always forever begin
        #(T * 1ns);
        vo     = is_nan(vin) ? `NaN : gain * (vin + vin_r) * wc*dt/(wc*dt+2) - (wc*dt-2)/(wc*dt+2) * vout_r;
        vin_r  = is_nan(vin) ? vin_r : vin;
        vout_r = is_nan(vout) ? vout_r : vo;
    end

    assign vout = vo;
endmodule