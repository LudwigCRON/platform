
`timescale 1ns/100ps

module tb;

    parameter integer N = 8;

    reg          clk;
    reg  [N-1:0] req;
    wire [N-1:0] grant;

    event   check_stats;
    integer step = 0;

    // ======== stimuli ========
    initial begin
        $dumpvars(-1, tb);
        clk = 1'b0;
        #(48us);
        `log_Fatal("Unexpected timeout");
    end

    always forever begin
        #(10ns) clk = !clk;
    end

    initial begin
        `log_Note("==== check lower first ====");
        for (int j = 0; j < 2**N; j += 1)
        begin
            @(posedge clk) req = j;
            @(negedge clk);
            `log_InfoF2("\treq = %x\tgrant = %x", req, grant);
        end
        -> check_stats;
        #(10ns);
        `log_Terminate;
    end

    // ======== round robin ========
    abus_lf #(
        .N (N)
    ) dut (
        .req    (req),
        .grant  (grant)
    );

    // ======== checkers ========
    int counters [N-1:0];
    int max_idx;
    int max_val;
    
    always @(negedge clk)
    begin
        max_val = 0;
        for (int i = 0; i < N; i += 1)
        begin
            counters[i] += grant[i];
            max_idx = (counters[i] > max_val) ? i : max_idx;
            max_val = (counters[i] > max_val) ? counters[i] : max_val;
        end
    end

    always @(check_stats)
    begin
        for (int i = 0; i < N; i += 1)
        begin
            $display("grant[%d] = %d", i[N-1:0], counters[i][N-1:0]);
            if (counters[i] < 1) `log_Error("starvation detected");
            counters[i] = 0;
        end
        if (max_idx != step) `log_Error("wrong priority");
    end

    always @(negedge clk)
    begin
        `ifdef FORMAL
        assert ($onehot(grant)) else `log_Error("only one master shall be granted at a time");
        `else
        if (!$onehot(grant)) `log_Error("only one master shall be granted at a time");
        `endif
    end

endmodule