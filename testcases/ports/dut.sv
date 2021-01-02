
module dut (
    input   wire        clk,
    input   wire        rstb,
    
    input   wire [11:0] read,
    input   wire [11:0] write,
    input   wire [11:0] rwe_write,

    input   wire [15:0] wdata,
    input   wire [15:0] rwe_data,
    input   wire [15:0] ro_data,
    input   wor  [15:0] rdata,

    output  wire [15:0] q_none,
    output  wire [15:0] q_ro1,
    output  wire [15:0] q_ro2,
    output  wire [15:0] q_rw1,
    output  wire [15:0] q_rw2,
    output  wire [15:0] q_rw3,
    output  wire [15:0] q_rwe1,
    output  wire [15:0] q_rwe2,
    output  wire [15:0] q_rwe3,
    output  wire [15:0] q_wo1,
    output  wire [15:0] q_mix1,
    output  wire [15:0] q_mix2
);

    port port_none (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[0]),
        .write      (write[0]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[0]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_none)
    );

    port #(
        .RO_MASK    (16'hF421)
    ) port_ro_1 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[1]),
        .write      (write[1]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[1]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_ro1)
    );

    port #(
        .RO_MASK    (16'h0BDE)
    ) port_ro_2 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[2]),
        .write      (write[2]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[2]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_ro2)
    );

    port #(
        .RW_MASK    (16'h5500),
        .INIT       (16'hEDCB)
    ) port_rw_1 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[3]),
        .write      (write[3]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[3]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_rw1)
    );

    port #(
        .RW_MASK    (16'h00AA),
        .INIT       (16'h1234)
    ) port_rw_2 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[4]),
        .write      (write[4]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[4]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_rw2)
    );

    port #(
        .RW_MASK    (16'h00AA)
    ) port_rw_3 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[5]),
        .write      (write[5]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[5]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_rw3)
    );

        port #(
        .RWE_MASK   (16'h5500),
        .INIT       (16'hEDCB)
    ) port_rwe_1 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[6]),
        .write      (write[6]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[6]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_rwe1)
    );

    port #(
        .RWE_MASK   (16'h00AA),
        .INIT       (16'h1234)
    ) port_rwe_2 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[7]),
        .write      (write[7]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[7]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_rwe2)
    );

    port #(
        .RWE_MASK   (16'h00AA)
    ) port_rwe_3 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[8]),
        .write      (write[8]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[8]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_rwe3)
    );

    port #(
        .WO1_MASK   (16'h1111),
        .INIT       (16'hFFFF)
    ) port_wo_1 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[9]),
        .write      (write[9]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[9]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_wo1)
    );

    port #(
        .RO_MASK    (16'h000F),
        .RW_MASK    (16'h00F0),
        .RWE_MASK   (16'h0F00),
        .WO1_MASK   (16'hF000),
        .INIT       (16'h9876)
    ) port_mix_1 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[10]),
        .write      (write[10]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[10]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_mix1)
    );

    port #(
        .RO_MASK    (16'hF000),
        .RW_MASK    (16'h0F00),
        .RWE_MASK   (16'h00F0),
        .WO1_MASK   (16'h000F),
        .INIT       (16'h5432)
    ) port_mix_2 (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read[11]),
        .write      (write[11]),
        .wdata      (wdata),
        .rwe_write  (rwe_write[11]),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .rdata      (rdata),
        .q          (q_mix2)
    );

endmodule