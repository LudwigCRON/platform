
`timescale 1ns/100ps

module tb;

    parameter integer TCLK = 32;
    parameter integer N    = 32;

    reg  [N-1:0] a;
    reg  [N-1:0] b;
    wire         eq_ref;
    wire         gt_ref;
    wire         lt_ref;
    wire         eq;
    wire         gt;
    wire         lt;

    reg run_check;

    //======== stimuli ========
    initial
    begin: test
        $dumpvars();

        for(int i = 0; i < 512; i = i + 1)
        begin
            run_check = 1'b0;
            a = $urandom();
            b = (i % 32 > 0) ? $urandom() : a;
            #((TCLK-1) * 1ns);
            run_check = 1'b1;
            #(1ns);
        end
        `log_Terminate;
    end

    //======== comp_* ========
    comp_eq #(
        .N  (N)
    ) ceq (
        .a      (a),
        .b      (b),
        .a_eq_b (eq)
    );

    comp_gt #(
        .N  (N)
    ) cgt (
        .a      (a),
        .b      (b),
        .a_gt_b (gt)
    );

    comp_lt #(
        .N  (N)
    ) clt (
        .a      (a),
        .b      (b),
        .a_lt_b (lt)
    );

    //======== checker ========
    assign eq_ref = a == b;
    assign gt_ref = a > b;
    assign lt_ref = a < b;

    always @(posedge run_check)
    begin: sum_check
        if (eq_ref != eq) `log_Error("wrong comp_eq behaviour");
        if (gt_ref != gt) `log_Error("wrong comp_gt behaviour");
        if (lt_ref != lt) `log_Error("wrong comp_lt behaviour");
    end


endmodule