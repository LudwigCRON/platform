`timescale 1ns/100ps

`include "log.svh"

module tb;

    parameter integer N      = 4;
    parameter integer PERIOD = 10;

    reg [N-1:0] clk;
    reg [N-1:0] rstb;
    reg [N-1:0] sel;
    wire        q;

    event sel_changed;

    // ======== stimuli ========
    initial begin
        $dumpvars();
        clk  = 0;
        rstb = 0;
        sel  = 0;
        #(50ns);
        rstb = 2**N - 1;
        for (int i = 0; i < 2**N; i = i+1)
        begin
            sel = i;
            -> sel_changed;
        #(1us);
        end
        `log_Terminate;
    end

    genvar gi;
    for (gi = 0; gi < N; gi = gi + 1)
    begin
        always forever
        begin
            #(PERIOD * (gi + 1) + gi) clk[gi] = !clk[gi];
        end
    end

    initial begin
        #(256us);
        `log_Fatal("Unexpected timeout");
    end

    // ======== clock switch ========
    clock_mux #(
        .N      (N),
        .STAGES (2)
    ) clksw (
        .clk    (clk),
        .rstb   (rstb),
        .select (sel),
        .q      (q)
    );

    // ======== checker ========
    realtime trise;
    realtime tfall;
    realtime check_noglitches_start;
    realtime transition_window;

    real period;
    real duty_cycle;
    real expected_period;

    reg [4:0] transition_ongoing;
    wire      transition;

    always @(posedge q)
    begin
        period = $realtime() - trise;
        trise = $realtime();
    end

    always @(negedge q)
        tfall = $realtime();
    
    always @(sel_changed)
    begin
        transition_ongoing = 5'b00001;
        check_noglitches_start = $realtime();
    end

    always @(posedge q)
        transition_ongoing = {transition_ongoing[4:0], 1'b0};

    assign transition = |transition_ongoing[3:0];
    
    // ==== measure ====
    always @(posedge q)
        if (~transition) duty_cycle = 100*$abs(tfall - trise)/expected_period;

    always @(negedge transition)
        transition_window = $realtime() - check_noglitches_start;

    // ==== checks ====
    wire [2:0] err;

    assign err[0] = (period < expected_period - PERIOD/4) || (period > expected_period + PERIOD/4);
    assign err[1] = (duty_cycle < 48.0) || (duty_cycle > 52.0);
    assign err[2] = transition_window < (transition_size(sel) - PERIOD/4);

    always @(sel)
    begin
        if (sel > 0 && ~transition && err[0]) `log_Error("wrong clock selection");
        expected_period = get_ideal_period(sel);
    end
    
    always @(negedge transition_ongoing[4])
    begin
        if (sel > 0 && err[2])
            `log_ErrorF1("glitch detected during transition with sel=%d", sel);
    end

    always @(negedge q)
    begin
        if (~|transition_ongoing[4:0] && err[1])
            `log_ErrorF1("unexpected duty cycle get %.2f outside of ]48,52[", duty_cycle);
    end
    
    function automatic real get_ideal_period(
        input [N-1:0] sel
    );
        int s;
        s = (sel > 0) ? $clog2(sel+1) : -1;
        get_ideal_period = 2 * (PERIOD * s + s - 1);
    endfunction

    function automatic real transition_size(
        input [N-1:0] sel
    );
        real a;
        real b;
        a = get_ideal_period(sel-1);
        b = get_ideal_period(sel);
        transition_size = 1.5 * (b + a);
    endfunction

endmodule