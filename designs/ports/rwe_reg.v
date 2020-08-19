`default_nettype none

module rwe_reg (
    input   wire        clk,
    input   wire        rstb,
    input   wire        read,
    input   wire        write,
    input   wire        sel_ab,
    input   wire        init,
    input   wire        in_a,
    input   wire        in_b,
    output  wire        ro,
    output  reg         q
);

    always @(posedge clk)
    begin
        if (!rstb)
            q <= init;
        else if (write && sel_ab)
            q <= in_b;
        else if (write)
            q <= in_a;
    end

    and g_ro (ro, q, read);

endmodule