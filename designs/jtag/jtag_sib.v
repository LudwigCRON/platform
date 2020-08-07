`default_nettype none

module jtag_sib (
    input   wire        tck,
    input   wire        trstb,
    input   wire        shift,
    input   wire        update,
    // ==== interface to parent sib ====
    input   wire        tdi,
    output  wire        tdo,
    // ==== interface to tdr/child sib ====
    input   wire        cto,
    output  wire        cti,
    output  wire        select
);

    // ==== shift register ====
    reg [1:0] shiftreg;

    always @(posedge tck, negedge trstb)
    begin
        if (!trstb)
            shiftreg <= 2'b00;
        else if (shift && update)
            shiftreg <= {shiftreg[0], tdi};
        else if (shift)
            shiftreg <= {shiftreg[1], tdi};
    end

    // ==== buffers/mux ====
    buf g_cti(cti, shiftreg[0]);
    buf g_sel(select, shiftreg[1]);
    assign tdo    = (select) ? cto : shiftreg[0];

endmodule