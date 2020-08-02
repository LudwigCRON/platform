`default_nettype none

module abus_arbiter #(
    parameter integer NB_MASTER  =  1,
    parameter integer NB_SLAVE   =  1,
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16,
    parameter integer SCHEDULER  =  0
) (
    input   wire                                bus_clk,
    input   wire                                bus_rstb,

    // ==== from bus masters ====
    input   wire    [NB_MASTER-1:0]             bus_mvalid,
    input   wire    [3*NB_MASTER-1:0]           bus_mid,
    input   wire    [NB_MASTER*ADDR_WIDTH-1:0]  bus_maddress,
    input   wire    [NB_MASTER*DATA_WIDTH-1:0]  bus_mwdata,

    // ==== to bus masters ====
    output  wire    [3*NB_MASTER-1:0]           bus_mbid,
    output  wire    [DATA_WIDTH-1:0]            bus_mrdata, 

    // ==== to bus slaves ====
    output   wire                               bus_svalid,
    output   wire    [ADDR_WIDTH-1:0]           bus_saddress,
    output   wire    [DATA_WIDTH-1:0]           bus_swdata,

    // ==== from bus slaves ====
    input   wire    [NB_SLAVE-1:0]              bus_sready,
    input   wire    [$clog2(DATA_WIDTH+1)-1:0]  bus_sstrb,
    input   wire    [$clog2(DATA_WIDTH+1)-1:0]  bus_skeep
);

    // ======== scheduler selection ========
    generate
        // ==== round robin ====
        if (SCHEDULER == 0)
        begin
            
        end
    endgenerate

    localparam [3*NB_MASTER-1:0] id_selector = {(NB_MASTER){3'b001}};

    // ======== arbitration on mid ========
    assign bus_mbid[0] = &pick_3nbm(id_selector, bus_mid);
    assign bus_mbid[1] = &pick_3nbm(id_selector << 1, bus_mid);
    assign bus_mbid[2] = &pick_3nbm(id_selector << 2, bus_mid);

    function automatic [NB_MASTER-1:0] pick_3nbm(
        input [3*NB_MASTER-1:0] selector,
        input [3*NB_MASTER-1:0] data
    );
        integer i = 0;
        integer j = 0;
        for(i = 0; i < 3*NB_MASTER; i = i + 1)
        begin
            if (selector[i])
            begin
                pick_3nbm[j] = data[i];
                j = j + 1;
            end
        end
    endfunction

endmodule