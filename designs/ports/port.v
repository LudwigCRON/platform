`default_nettype none

module port #(
    parameter [15:0] RO_MASK  = 16'h0000,
    parameter [15:0] RW_MASK  = 16'h0000,
    parameter [15:0] RWE_MASK = 16'h0000,
    parameter [15:0] WO1_MASK = 16'h0000,
    parameter [15:0] INIT     = 16'h0000
) (
    clk,
    rstb,
    read,
    write,
    wdata,
    rwe_write,
    rwe_data,
    ro_data,
    rdata,
    q
);
    `include "designs/ports/port_functions.vh"

    localparam [15:0]  Q_MASK    = RW_MASK | RW_MASK | WO1_MASK;
    localparam integer Q_WIDTH   = cones(Q_MASK);
    localparam integer RWE_WIDTH = cones(RWE_MASK);
    localparam integer RO_WIDTH  = cones(RO_MASK);

    input   wire                 clk;
    input   wire                 rstb;
    input   wire                 read;
    input   wire                 write;
    input   wire [15:0]          wdata;
    input   wire                 rwe_write;
    input   wire [RWE_WIDTH-1:0] rwe_data;
    input   wire [RO_WIDTH-1:0]  ro_data;
    output  wire [Q_WIDTH-1:0]   q;
    output  wire [15:0]          rdata;

    wire [15:0] internal_q;

    genvar gi;

    generate
        for(gi = 0; gi < 16; gi++)
        begin
            if (RO_MASK[gi])
            begin
                ro_reg ro_r (
                    .clk    (clk),
                    .rstb   (rstb),
                    .read   (read),
                    .in     (ro_data[gi]),
                    .ro     (rdata[gi])
                );
            end else if (RW_MASK[gi])
            begin
                rw_reg rw_r (
                    .clk    (clk),
                    .rstb   (rstb),
                    .read   (read),
                    .write  (write),
                    .init   (INIT[gi]),
                    .in     (wdata[gi]),
                    .ro     (rdata[gi]),
                    .q      (internal_q[gi])
                );
            end else if (RWE_MASK[gi])
            begin
                rwe_reg rwe_r (
                    .clk    (clk),
                    .rstb   (rstb),
                    .read   (read),
                    .write  (write | rwe_write),
                    .sel_ab (rwe_write),
                    .init   (INIT[gi]),
                    .in_a   (wdata[gi]),
                    .in_b   (rwe_data[gi]),
                    .ro     (rdata[gi]),
                    .q      (internal_q[gi])
                );
            end else if (WO1_MASK[gi])
            begin
                wo1_reg wo1_r (
                    .clk    (clk),
                    .rstb   (rstb),
                    .write  (write),
                    .ro     (rdata[gi]),
                    .q      (internal_q[gi])
                );
            end else
            begin
                assign rdata[gi] = 1'b0;
            end
        end
    endgenerate

    assign q = pick(Q_MASK, internal_q);

endmodule