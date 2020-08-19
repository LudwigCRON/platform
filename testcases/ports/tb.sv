
`timescale 1ns/100ps

module tb;

    parameter integer PERIOD = 40;

    reg         clk;
    reg         rstb;
    reg [11:0]  read;
    reg [11:0]  write;
    reg [11:0]  rwe_write;
    reg [15:0]  wdata;
    reg [15:0]  rwe_data;
    reg [15:0]  ro_data;

    wire [15:0] q_none;
    wire [15:0] q_ro1;
    wire [15:0] q_ro2;
    wire [15:0] q_rw1;
    wire [15:0] q_rw2;
    wire [15:0] q_rw3;
    wire [15:0] q_rwe1;
    wire [15:0] q_rwe2;
    wire [15:0] q_rwe3;
    wire [15:0] q_wo1;
    wire [15:0] q_mix1;
    wire [15:0] q_mix2;

    `include "testcases/ports/dut.svh"
    `include "testcases/ports/scenarii/check_ro.svh"
    `include "testcases/ports/scenarii/check_rw.svh"
    `include "testcases/ports/scenarii/check_rwe.svh"
    `include "testcases/ports/scenarii/check_wo1.svh"
    `include "testcases/ports/scenarii/check_mix.svh"
    
    // ======== stimuli ========
    initial begin
        clk = 1'b0;
        rstb = 1'b0;
        #(50ns);
        rstb = 1'b1;
    end

    always forever begin
        #(PERIOD/2) clk = !clk;
    end

    // ======== dut ========
    dut dut (
        .clk        (clk),
        .rstb       (rstb),
        .read       (read),
        .write      (write),
        .rwe_write  (rwe_write),
        .wdata      (wdata),
        .rwe_data   (rwe_data),
        .ro_data    (ro_data),
        .q_none     (q_none),
        .q_ro1      (q_ro1),
        .q_ro2      (q_ro2),
        .q_rw1      (q_rw1),
        .q_rw2      (q_rw2),
        .q_rw3      (q_rw3),
        .q_rwe1     (q_rwe1),
        .q_rwe2     (q_rwe2),
        .q_rwe3     (q_rwe3),
        .q_wo1      (q_wo1),
        .q_mix1     (q_mix1),
        .q_mix2     (q_mix2)
    );

    // ======== checks ========

endmodule