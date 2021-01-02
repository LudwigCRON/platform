`timescale 1ns/100ps

`include "log.svh"

module tb;

    parameter integer TCLK = 32;
    parameter integer N    = 32;

    reg  [N-1:0] a;
    reg  [N-1:0] b;
    wire [N-1:0] s_ref;
    wire [N-1:0] s_rca;
    wire [N-1:0] s_cla;

    reg run_check;

    //======== stimuli ========
    initial
    begin: test
        $dumpvars();

        for(int i = 0; i < 512; i = i + 1)
        begin
            run_check = 1'b0;
            a = $urandom();// % 2**32;
            b = $urandom();// % 2**32;
            #((TCLK-1) * 1ns);
            run_check = 1'b1;
            #(1ns);
        end
        `log_Terminate;
    end

    //======== adders ========
    adder_rca #(
        .N(N)
    ) rca (
        .a  (a),
        .b  (b),
        .ci (1'b0),
        .s  (s_rca),
        .co ()
    );

    adder_cla #(
        .N(N)
    ) cla (
        .a  (a),
        .b  (b),
        .ci (1'b0),
        .s  (s_cla),
        .co ()
    );

    //======== checker ========
    assign s_ref = a + b;

    always @(posedge run_check)
    begin: sum_check
        if (s_rca != s_ref) `log_Error("Wrong ripple-carry-adder sum result");
        if (s_cla != s_ref) `log_Error("Wrong carry-lookahead-adder sum result");
    end


endmodule