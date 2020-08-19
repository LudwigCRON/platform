`default_nettype none

module rw_reg (
    input   wire        clk,
    input   wire        rstb,
    input   wire        read,
    input   wire        write,
    input   wire        init,
    input   wire        in,
    output  wire        ro,
    output  reg         q
);

    always @(posedge clk)
    begin
        if (!rstb)
            q <= init;
        else if (write)
            q <= in;
    end

    and g_ro (ro, q, read);

endmodule