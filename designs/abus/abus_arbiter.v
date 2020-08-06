`default_nettype none

module abus_arbiter #(
    parameter integer NB_MASTER  =  2,
    parameter integer NB_SLAVE   =  1,
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16,
    parameter integer SCHEDULER  =  0
) (
    input   wire                                            abus_clk,
    input   wire                                            abus_rstb,

    // ==== from bus masters ====
    input   wire    [3*NB_MASTER-1:0]                       abus_mid,
    input   wire    [NB_MASTER-1:0]                         abus_mreq,
    input   wire    [NB_MASTER-1:0]                         abus_mwrite,
    input   wire    [NB_MASTER-1:0]                         abus_mread,
    input   wire    [NB_MASTER-1:0]                         abus_mabort,
    input   wire    [NB_MASTER*$clog2(DATA_WIDTH+1)-1:0]    abus_mstrb,
    input   wire    [NB_MASTER*$clog2(DATA_WIDTH+1)-1:0]    abus_mkeep,
    input   wire    [NB_MASTER*DATA_WIDTH-1:0]              abus_mwdata,
    input   wire    [NB_MASTER*ADDR_WIDTH-1:0]              abus_maddress,

    // ==== to bus masters ====
    output  wire                                            abus_mack,
    output  wire    [NB_MASTER-1:0]                         abus_mgrant,
    output  wire    [DATA_WIDTH-1:0]                        abus_mrdata, 

    // ==== from bus slaves ====
    input   wire    [NB_SLAVE-1:0]                          abus_sack,
    input   wire    [NB_SLAVE*DATA_WIDTH-1:0]               abus_srdata,

    // ==== to bus slaves ====
    output  wire    [2:0]                                   abus_smid,
    output  wire                                            abus_sreq,
    output  wire                                            abus_swrite,
    output  wire                                            abus_sread,
    output  wire                                            abus_sabort,
    output  wire    [$clog2(DATA_WIDTH+1)-1:0]              abus_sstrb,
    output  wire    [$clog2(DATA_WIDTH+1)-1:0]              abus_skeep,
    output  wire    [ADDR_WIDTH-1:0]                        abus_saddress,
    output  wire    [DATA_WIDTH-1:0]                        abus_swdata
);

    `include "designs/abus/abus_functions.vh"

    // ======== scheduler selection ========
    generate
        // ==== round robin ====
        if (SCHEDULER == 0)
        begin
            reg [NB_MASTER-1:0] prio;

            abus_rr #(
                .N      (NB_MASTER)
            ) prio_resolver (
                .prio   (prio),
                .req    (abus_mreq),
                .grant  (abus_mgrant)
            );

            always @(posedge abus_clk, negedge abus_rstb)
            begin
                if (!abus_rstb)
                    prio <= {NB_MASTER{1'b1}};
                else if (~abus_sreq & (|abus_sack))
                    prio <= {abus_mgrant[NB_MASTER-2:0], 1'b0};
            end
        // ==== lowest first ==== 
        end else if (SCHEDULER == 1)
        begin
            abus_lf #(
                .N      (NB_MASTER)
            ) prio_resolver (
                .req    (abus_mreq),
                .grant  (abus_mgrant)
            );
        end
    endgenerate

    // ======== selection master -> slave ========
    assign abus_sreq     = |abus_mreq;
    assign abus_smid     = pick_3nbm(abus_mgrant, abus_mid);
    assign abus_sread    = pick_nbm( abus_mgrant, abus_mread);
    assign abus_swrite   = pick_nbm( abus_mgrant, abus_mwrite);
    assign abus_sabort   = pick_nbm( abus_mgrant, abus_mabort);
    assign abus_swdata   = pick_dnbm(abus_mgrant, abus_mwdata);
    assign abus_saddress = pick_anbm(abus_mgrant, abus_maddress);

    // ======== selection master <- slave ========
    assign abus_mack     = |abus_sack;
    assign abus_mrdata   = pick_dnbs(abus_sack, abus_srdata);


    // ======== arbitration on mid ========

endmodule