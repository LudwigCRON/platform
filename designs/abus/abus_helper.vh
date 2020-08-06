
`ifndef NO_HELPER

    logic verbose;
    logic [DATA_WIDTH-1:0] bkp_rdata;

    initial begin
        verbose = 1'b1;
    end

    // ======== word ========

    task WriteWord(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
        force write   = 1'b1;
        force address = addr;
        force wdata   = data;
        @(posedge abus_clk);
        wait (done || err);
        if (err && verbose)
            `log_ErrorF2("Failed to write [%x] at [%x]", data, addr);
        release write;
        release address;
        release wdata;
        @(posedge abus_clk);
    endtask

    task ReadWord(
        input logic [ADDR_WIDTH-1:0] addr
    );
        force read = 1'b1;
        force address = addr;
        @(posedge abus_clk);
        wait (new_rdata || err);
        if (err && verbose)
            `log_ErrorF1("Failed to read at [%x]", addr);
        release read;
        release address;
        bkp_rdata = rdata;
        @(posedge abus_clk);
    endtask

    function [DATA_WIDTH-1:0] GetReadWord();
        GetReadWord = bkp_rdata;
    endfunction

    // ======== byte ========

    // ======== bits ========

`endif