
`ifndef NO_HELPER

`define BUS_MASTER abus_master

module abus_master_helper #(
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16
) (
    input   wire            abus_clk,
    input   wire            abus_rstb
);

    logic verbose;
    logic [DATA_WIDTH-1:0] rdata;

    initial begin
        verbose = 1'b1;
    end

    // ======== word ========

    task WriteWord(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] data
    );
        `BUS_MASTER.write   = 1'b1;
        `BUS_MASTER.address = address;
        `BUS_MASTER.wdata   = data;
        @(posedge abus_clk);
        wait (`BUS_MASTER.done || `BUS_MASTER.err);
        if (`BUS_MASTER.err && verbose)
            `log_Error($sformatf("Failed to write [%x] at [%x]", data, address));
        `BUS_MASTER.write   = 1'b0;
    endtask

    task ReadWord(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] data
    );
        `BUS_MASTER.read    = 1'b1;
        `BUS_MASTER.address = address;
        @(posedge abus_clk);
        wait (`BUS_MASTER.new_rdata || `BUS_MASTER.err);
        if (`BUS_MASTER.err && verbose)
            `log_Error($sformatf("Failed to write [%x] at [%x]", data, address));
        `BUS_MASTER.read    = 1'b0;
        rdata = `BUS_MASTER.rdata;
    endtask

    function [DATA_WIDTH-1:0] GetReadWord();
        GetReadWord = rdata;
    endfunction

    // ======== byte ========

    // ======== bits ========

endmodule

bind abus_master abus_master_helper _helper (

);

`endif