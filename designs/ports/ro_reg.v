`default_nettype none

module ro_reg (
    input   wire        clk,
    input   wire        rstb,
    input   wire        read,
    input   wire        in,
    output  reg         ro
);

    always @(*)
    begin
        if (!clk)
            ro <= in & read;
    end

endmodule