`default_nettype none

module fcounter #(
    parameter integer N = 8
) (
    input   wire            clk,
    input   wire            rstb,
    input   wire            ms_clk,
    input   wire            ref_clk,

    input   wire            fcounter_ce,
    input   wire            fcounter_som,

    output  reg             fcounter_eom,
    output  wire            fcounter_rdy,
    output  reg   [N-1:0]   fcounter_adata
); 
    reg  [2:0]  measure_done;
    reg  [2:0]  measure_done_ref;
    reg         measure_ref;
    reg  [1:0]  som_ref;
    wire        measure_done_p;
    wire        measure_done_ref_p;
    wire        pulse_ref;

    reg  [2:0]  ms_clk_ref;

    assign fcounter_rdy = rstb;

    // ======== instruments handshake ========
    always @(posedge clk)
    begin
        if (!rstb)
            fcounter_eom <= 1'b1;
        else if (fcounter_som && fcounter_ce)
            fcounter_eom <= 1'b0;
        else if (measure_done_p)
            fcounter_eom <= 1'b1;
    end

    assign pulse_ref = (som_ref[1] | measure_ref) & fcounter_ce;

    always @(posedge ref_clk, negedge rstb)
    begin
        if (!rstb)
            measure_done_ref <= 3'h0;
        else
            measure_done_ref <= {measure_done_ref[1:0], pulse_ref};
    end

    assign measure_done_ref_p = measure_done_ref[1] & ~measure_done_ref[2];

    always @(posedge ref_clk, negedge rstb)
    begin
        if (!rstb)
            measure_ref <= 4'h0;
        else if (measure_done_ref_p)
            measure_ref <= ~measure_ref;
    end

    always @(posedge ref_clk, negedge rstb)
    begin
        if (!rstb)
            som_ref <= 2'b00;
        else
            som_ref <= {som_ref[0], fcounter_som};
    end

    // ======== resync clock signal ========
    always @(posedge ref_clk)
        ms_clk_ref <= {ms_clk_ref[1:0], ms_clk};

    // ======== gray counter ========
    // prefered gray over johnson counter for
    // for reduced area without glitches
    // in the ref_clk domain and does not
    // change when measurement is done 
    // => recirculation mux for CDC
    localparam [N-1:0] INIT_COUNTER = 0;

    wire [N-1:0] counter;
    wire         counter_init;
    reg          counter_incr;

    assign counter_init = (pulse_ref & ~measure_ref) | ~rstb;
    always @(ref_clk)
        if (!ref_clk) counter_incr <= measure_ref & ms_clk_ref[1] & ~ms_clk_ref[2];

    gray_counter #(
        .N          (N)
    ) gray_counter (
        .clk        (ref_clk),
        .load       (counter_init),
        .load_value (INIT_COUNTER),
        .enable     (counter_incr),
        .q          (counter)
    );

    // ======== gray code --> binary ========
    wire [N-1:0] fcounter_adata_tmp;

    always @(posedge clk, negedge rstb)
    begin
        if (!rstb)
            measure_done <= 3'b000;
        else
            measure_done <= {measure_done[1:0], measure_ref};
    end

    assign measure_done_p = measure_done[2] & ~measure_done[1];

    always @(measure_done[1:0], fcounter_adata_tmp)
    begin
        if (measure_done[1] & ~measure_done[0])
            fcounter_adata = fcounter_adata_tmp;
    end

    assign fcounter_adata_tmp = counter ^ {1'b0, fcounter_adata_tmp[N-1:1]};

endmodule