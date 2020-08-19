`default_nettype none

module wo1_reg (
    input   wire        clk,
    input   wire        rstb,
    input   wire        write,
    output  wire        ro,
    output  reg         q
);

    always @(posedge clk)
    begin
        if (!rstb)
            q <= 1'b0;
        else if (write)
            q <= 1'b1;
        else
            q <= 1'b0;
    end

    assign ro = 1'b0;

endmodule