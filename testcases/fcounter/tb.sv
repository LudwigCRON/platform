
`timescale 1ns/100ps

`include "log.svh"

module tb;

    parameter integer PERIOD       = 31;
    parameter integer XTAL_PERIOD  = 100;
    parameter integer FAST_PERIOD  = 13;
    parameter integer N            = $clog2(2000/FAST_PERIOD+1);
    parameter integer SAFETY_LEVEL = 0;

    reg             ms_clk;
    reg             ms_clk_div_2;
    reg             clk;
    reg             ref_clk;
    reg             rstb;

    reg             div_2;
    reg             change_ref_clk;

    reg             fcounter_ce;
    reg             fcounter_som;
    wire            fcounter_eom;
    wire            fcounter_rdy;
    wire [N-1:0]    fcounter_adata;

    integer      i;

    task reset;
        rstb   = 1'b0;
        repeat(2) @(posedge clk);
        rstb   = 1'b1;
    endtask

    task ce_pulse;
        @(negedge clk) fcounter_ce = 1'b1;
        @(negedge clk) fcounter_ce = 1'b0;
    endtask

    // ======== stimuli ========
    initial begin
        $dumpvars();
        ms_clk          = 1'b0;
        ms_clk_div_2    = 1'b0;
        clk             = 1'b0;
        ref_clk         = 1'b0;
        rstb            = 1'b0;
        div_2           = 1'b0;
        change_ref_clk  = 1'b0;
        fcounter_som    = 1'b0;
        fcounter_ce     = 1'b0;

        #(50ns);
        rstb   = 1'b1;

        `log_Note("==== check frequency measurement (ms_clk with ref_clk) \t====");
        #(100ns) fcounter_som = 1'b1;
        #(100ns) ce_pulse();
        wait (fcounter_eom == 1'b0);
        #(1ns) fcounter_som = 1'b0;
        #(10us) ce_pulse();
        @(posedge fcounter_eom);
        if ((fcounter_adata < (10000/XTAL_PERIOD)-1) || (fcounter_adata > (10000/XTAL_PERIOD)+1))
            `log_Error("unexpected measurement result");
        #(1us) ce_pulse();

        `log_Note("==== check frequency measurement (ms_clk/2 with ref_clk)====");
        div_2 = 1'b1;
        #(100ns) fcounter_som = 1'b1;
        #(100ns) ce_pulse();
        wait (fcounter_eom == 1'b0);
        #(1ns) fcounter_som = 1'b0;
        #(10us) ce_pulse();
        @(posedge fcounter_eom);
        if ((fcounter_adata < (5000/XTAL_PERIOD)-1) || (fcounter_adata > (5000/XTAL_PERIOD)+1))
            `log_Error("unexpected measurement result");
        #(1us) ce_pulse();

        change_ref_clk = 1'b1;
        div_2 = 1'b0;

        `log_Note("==== check frequency measurement (ms_clk with clk) \t====");
        #(100ns) fcounter_som = 1'b1;
        #(100ns) ce_pulse();
        wait (fcounter_eom == 1'b0);
        #(1ns) fcounter_som = 1'b0;
        #(10us) ce_pulse();
        @(posedge fcounter_eom);
        if ((fcounter_adata < (10000/XTAL_PERIOD)-1) || (fcounter_adata > (10000/XTAL_PERIOD)+1))
            `log_Error("unexpected measurement result");
        #(1us) ce_pulse();

        `log_Note("==== check frequency measurement (ms_clk/2 with clk) \t====");
        div_2 = 1'b1;
        #(100ns) fcounter_som = 1'b1;
        #(100ns) ce_pulse();
        wait (fcounter_eom == 1'b0);
        #(1ns) fcounter_som = 1'b0;
        #(10us) ce_pulse();
        @(posedge fcounter_eom);
        if ((fcounter_adata < (5000/XTAL_PERIOD)-1) || (fcounter_adata > (5000/XTAL_PERIOD)+1))
            `log_Error("unexpected measurement result");
        #(1us) ce_pulse();

        repeat(8) @(posedge clk);
        `log_Terminate;
    end

    always forever begin
        #(PERIOD/2) clk = !clk;
    end

    always forever begin
        #(FAST_PERIOD/2) ref_clk = !ref_clk;
    end

    always forever begin
        #(XTAL_PERIOD/2) ms_clk = !ms_clk;
    end

    always @(posedge ms_clk)
        ms_clk_div_2 <= ~ms_clk_div_2;

    initial begin
        #(50us);
        `log_Fatal("Unpected Timeout!");
    end

    // ======== update trim ========
    fcounter #(
        .N  (N)
    ) dut (
        .clk                (clk),
        .rstb               (rstb),
        .ms_clk             ((div_2) ? ms_clk_div_2 : ms_clk),
        .ref_clk            ((change_ref_clk) ? clk : ref_clk),
        .fcounter_ce        (fcounter_ce),
        .fcounter_som       (fcounter_som),
        .fcounter_eom       (fcounter_eom),
        .fcounter_rdy       (fcounter_rdy),
        .fcounter_adata     (fcounter_adata)
    );

    // ======== checkers ========

endmodule