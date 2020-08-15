
`timescale 1ns/100ps

module tb;

    parameter integer PERIOD = 40;

    reg          clk;
    reg          rstb;
    reg          start;
    reg          enable;
    reg [7:0]    div_a;
    reg [3:0]    div_b;
    wire         timer_it;

    // ======== stimuli ========
    initial begin
        $dumpvars;
        clk          = 1'b0;
        rstb         = 1'b0;
        enable       = 1'b0;
        start        = 1'b0;
        #(50ns);
        rstb = 1'b1;
        div_a = 'd33;
        div_b = 'd5;
        @(posedge clk) enable = 1'b1;
        #(100ns);
        for(int i = 0; i < 64; i += 1)
        begin
            run_timer();
            @(negedge timer_it);
            div_a = $urandom() % 2**8;
            div_b = $urandom() % 2**4;
        end
        div_a = 'd0;
        div_b = 'd0;
        run_timer();
        wait(timer_it);
        #(1us);
        `log_Terminate;
    end

    always forever begin
        #(PERIOD/2) clk = !clk;
    end

    initial begin
        #(4ms);
        `log_Fatal("Unexpected timeout");
    end

    task run_timer;
        @(negedge clk) start = 1'b1;
        @(negedge clk);
        @(negedge clk) start = 1'b0;
    endtask

    // ======== dut ========
    timer #(
        .A_WIDTH    (8),
        .B_WIDTH    (4)
    ) dut (
        .clk        (clk),
        .rstb       (rstb),
        .start      (start),
        .enable     (enable),
        .div_a      (div_a),
        .div_b      (div_b),
        .timer_it   (timer_it)
    );

    // ======== checkers ========
    real tstart;
    real elapsed;
    real expected;

    wire wrong_timing;

    always @(posedge start)
        tstart = $realtime;
    
    always @(posedge timer_it)
        elapsed = $realtime - tstart;
    
    always @(negedge clk)
    begin
        if (timer_it && wrong_timing)
            `log_ErrorF2("Wrong delay expected [%f] get [%f]", expected, elapsed);
    end

    // 2 clock cycle for resync. + div_b * div_a
    // + half a period with start on negedge
    assign expected = (div_a * div_b + 2) * PERIOD + PERIOD/2;
    assign wrong_timing = (elapsed < expected - PERIOD/2) ||
                          (elapsed > expected + PERIOD/2);


endmodule
