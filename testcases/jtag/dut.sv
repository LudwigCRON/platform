`default_nettype none

module dut (
    input  wire tck,
    input  wire trstb,
    input  wire tdi,
    input  wire tms,
    output wire tdo,

    input  wire clk,
    input  wire rstb,
    
    input  wire ms_adc_cmp,
    input  wire ms_adc_rdy,
    output wire ms_adc_clk
);

    localparam integer N_CONF_ADC  = 4;
    localparam integer N_CONF_FCNT = 4;
    localparam integer N_CONF_DAC  = 8;
    localparam integer N_CONF_TMR  = 8;

    wire        shift;
    wire        update;
    wire        capture;
    wire [3:0]  select;

    // ======== test controller ========

    /*
        0   --> top
        1st --> adc to measure current and voltages
        2nd --> fcounter to measure frequency
        3rd --> dac to force analog voltage
        4th --> timer to allow variable settling time
    */

    wire top_sib_tdi;

    wire top_sib_tdo;
    wire adc_sib_tdo;
    wire fcnt_sib_tdo;
    wire dac_sib_tdo;
    wire tmr_sib_tdo;

    wire top_sib_cti;
    wire adc_tdr_cti;
    wire fcnt_tdr_cti;
    wire dac_tdr_cti;
    wire tmr_tdr_cti;

    wire adc_tdr_cto;
    wire fcnt_tdr_cto;
    wire dac_tdr_cto;
    wire tmr_tdr_cto;

    wire [N_CONF_ADC-1:0]  adc_conf;
    wire [N_CONF_FCNT-1:0] fcnt_conf;
    wire [N_CONF_DAC-1:0]  dac_conf;
    wire [N_CONF_TMR-1:0]  tmr_conf;

    jtag_sib top_sib (
        .tck    (tck),
        .trstb  (trstb),
        .shift  (shift),
        .update (update),
        .tdi    (tdi),
        .tdo    (tdo),
        .cti    (top_sib_cti),
        .cto    (tmr_sib_tdo),
        .select ()
    );

    jtag_sib adc_sib (
        .tck    (tck),
        .trstb  (trstb),
        .shift  (shift),
        .update (update),
        .tdi    (top_sib_cti),
        .tdo    (adc_sib_tdo),
        .cti    (adc_tdr_cti),
        .cto    (adc_tdr_cto),
        .select (select[0])
    );

    jtag_sib fcnt_sib (
        .tck    (tck),
        .trstb  (trstb),
        .shift  (shift),
        .update (update),
        .tdi    (adc_sib_tdo),
        .tdo    (fcnt_sib_tdo),
        .cti    (fcnt_tdr_cti),
        .cto    (fcnt_tdr_cto),
        .select (select[1])
    );

    jtag_sib dac_sib (
        .tck    (tck),
        .trstb  (trstb),
        .shift  (shift),
        .update (update),
        .tdi    (fcnt_sib_tdo),
        .tdo    (dac_sib_tdo),
        .cti    (dac_tdr_cti),
        .cto    (dac_tdr_cto),
        .select (select[2])
    );

    jtag_sib tmr_sib (
        .tck    (tck),
        .trstb  (trstb),
        .shift  (shift),
        .update (update),
        .tdi    (dac_sib_tdo),
        .tdo    (tmr_sib_tdo),
        .cti    (tmr_tdr_cti),
        .cto    (tmr_tdr_cto),
        .select (select[3])
    );

    jtag_tdr #(
        .N_CONF     (N_CONF_ADC),
        .N_SCOPE    (12),
        .INIT_VALUE (0)
    ) adc_tdr (
        .tck        (tck),
        .trstb      (trstb),
        .shift      (shift),
        .select     (select[0]),
        .capture    (capture),
        // ==== interface to sib ====
        .cti        (adc_tdr_cti),
        .cto        (adc_tdr_cto),
        // ==== interface instrument ====
        .cfi        ('d0),
        .sfi        (),
        .cfo        (adc_conf),
        .sfo        ()
    );

    jtag_tdr #(
        .N_CONF     (N_CONF_FCNT),
        .N_SCOPE    (8),
        .INIT_VALUE (0)
    ) fcnt_tdr (
        .tck        (tck),
        .trstb      (trstb),
        .shift      (shift),
        .select     (select[1]),
        .capture    (capture),
        // ==== interface to sib ====
        .cti        (fcnt_tdr_cti),
        .cto        (fcnt_tdr_cto),
        // ==== interface instrument ====
        .cfi        (),
        .sfi        (),
        .cfo        (),
        .sfo        ()
    );

    jtag_tdr #(
        .N_CONF     (N_CONF_DAC),
        .N_SCOPE    (0),
        .INIT_VALUE (0)
    ) dac_tdr (
        .tck        (tck),
        .trstb      (trstb),
        .shift      (shift),
        .select     (select[2]),
        .capture    (capture),
        // ==== interface to sib ====
        .cti        (dac_tdr_cti),
        .cto        (dac_tdr_cto),
        // ==== interface instrument ====
        .cfi        (),
        .sfi        (),
        .cfo        (),
        .sfo        ()
    );

    jtag_tdr #(
        .N_CONF     (N_CONF_TMR),
        .N_SCOPE    (0),
        .INIT_VALUE (0)
    ) tmr_tdr (
        .tck        (tck),
        .trstb      (trstb),
        .shift      (shift),
        .select     (select[3]),
        .capture    (capture),
        // ==== interface to sib ====
        .cti        (tmr_tdr_cti),
        .cto        (tmr_tdr_cto),
        // ==== interface instrument ====
        .cfi        (),
        .sfi        (),
        .cfo        (),
        .sfo        ()
    );

    // ======== instruments ========
    adc_sar #(
        .N  (12)
    ) adc (
        .clk            (clk),
        .rstb           (rstb),
        .enable         (adc_conf[0]),
        .extra_sample   (adc_conf[1]),
        .soc            (),
        .eoa            (),
        .eoc            (),
        .eoc_it         (),
        .dout           (),
        .ms_clk         (ms_adc_clk),
        .ms_rdy         (ms_adc_rdy),
        .ms_cmp         (ms_adc_cmp)
    );

endmodule