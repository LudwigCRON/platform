
`ifndef NO_HELPER

    logic verbose;
    logic [DATA_WIDTH-1:0] bkp_rdata;

    initial begin
        verbose = 1'b1;
    end

    // ======== word ========

    task WriteWord(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] data
    );
        force write   = 1'b1;
        force address = address;
        force wdata   = data;
        @(posedge abus_clk);
        wait (done || err);
        if (err && verbose)
            `log_ErrorF2("Failed to write [%x] at [%x]", data, address);
        release write;
        release address;
        release wdata;
    endtask

    task ReadWord(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] data
    );
        force read = 1'b1;
        force address = address;
        @(posedge abus_clk);
        wait (new_rdata || err);
        if (err && verbose)
            `log_ErrorF2("Failed to write [%x] at [%x]", data, address);
        release read;
        release address;
        bkp_rdata = rdata;
    endtask

    function [DATA_WIDTH-1:0] GetReadWord();
        GetReadWord = bkp_rdata;
    endfunction

    // ======== byte ========

    // ======== bits ========

`endif