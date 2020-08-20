`timescale 1ns/100ps

module tb;

    parameter integer TCLK = 32;
    parameter integer N    = 32;

    reg  [N-1:0]   a;
    reg  [N-1:0]   b;
    wire [2*N-1:0] m_ref;
    wire [2*N-1:0] m_dut;

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
    multipler_comb #(
        .N  (N)
    ) dut (
        .a  (a),
        .b  (b),
        .m  (m_dut)
    );

    //======== checker ========
    assign m_ref = a * b;

    always @(posedge run_check)
    begin: mul_check
        if (m_dut !== m_ref) `log_Error("Wrong multiplier comb result");
    end


endmodule