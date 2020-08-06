`timescale 1ns/100ps

module dut #(
    parameter integer NB_MASTER  =  2,
    parameter integer NB_SLAVE   =  1,
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16,
    parameter integer SCHEDULER  =  0,
    parameter integer PERIOD     = 40
) ();

    localparam integer SK_SIZE = $clog2(DATA_WIDTH+1);

    // ======== masters ========
    reg                                 abus_clk;
    reg                                 abus_rstb;
    wire    [NB_MASTER-1:0]             write       = 0;
    wire    [NB_MASTER-1:0]             read        = 0;
    wire    [NB_MASTER-1:0]             abort       = 0;
    wire    [NB_MASTER*ADDR_WIDTH-1:0]  address     = 0;
    wire    [NB_MASTER*DATA_WIDTH-1:0]  wdata       = 0;
    wire    [NB_MASTER*DATA_WIDTH-1:0]  rdata;
    wire    [NB_MASTER*SK_SIZE-1:0]     strb        = 0;
    wire    [NB_MASTER*SK_SIZE-1:0]     keep        = 2**(NB_MASTER*SK_SIZE)-1;
    wire    [NB_MASTER-1:0]             new_rdata;
    wire    [NB_MASTER-1:0]             done;
    wire    [NB_MASTER-1:0]             err;

    // ==== handshake mechanism ====
    wire                                abus_mack;
    wire    [NB_MASTER-1:0]             abus_mreq;

    // ==== arbitration ====
    wire    [3*NB_MASTER-1:0]           abus_mid;
    wire    [NB_MASTER-1:0]             abus_mgrant;

    // ==== data transmission ====
    wire    [NB_MASTER-1:0]             abus_mwrite;
    wire    [NB_MASTER-1:0]             abus_mread;
    wire    [NB_MASTER-1:0]             abus_mabort;
    wire    [DATA_WIDTH-1:0]            abus_mrdata;
    wire    [NB_MASTER*SK_SIZE-1:0]     abus_mstrb;
    wire    [NB_MASTER*SK_SIZE-1:0]     abus_mkeep;
    wire    [NB_MASTER*DATA_WIDTH-1:0]  abus_mwdata;
    wire    [NB_MASTER*ADDR_WIDTH-1:0]  abus_maddress;

    wire    [NB_SLAVE-1:0]              abus_sack;
    wire    [NB_SLAVE*DATA_WIDTH-1:0]   abus_srdata;

    wire    [2:0]                       abus_smid;
    wire                                abus_sreq;
    wire                                abus_swrite;
    wire                                abus_sread;
    wire                                abus_sabort;
    wire    [SK_SIZE-1:0]               abus_sstrb;
    wire    [SK_SIZE-1:0]               abus_skeep;
    wire    [DATA_WIDTH-1:0]            abus_swdata;
    wire    [ADDR_WIDTH-1:0]            abus_saddress;

    abus_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MASTER_ID ({3'h2, 3'h1})
    ) masters[NB_MASTER-1:0] (
        .abus_clk       (abus_clk),
        .abus_rstb      (abus_rstb),
        // ==== orders ====
        .write          (write),
        .read           (read),
        .abort          (abort),
        .address        (address),
        .wdata          (wdata),
        .rdata          (rdata),
        .strb           (strb),
        .keep           (keep),
        .new_rdata      (new_rdata),
        .done           (done),
        .err            (err),
        // ==== to bus_arbiter ====
        .abus_mack      (abus_mack),
        .abus_mreq      (abus_mreq),
        .abus_mid       (abus_mid),
        .abus_mgrant    (abus_mgrant),
        .abus_mwrite    (abus_mwrite),
        .abus_mread     (abus_mread),
        .abus_mabort    (abus_mabort),
        .abus_mrdata    (abus_mrdata),
        .abus_mstrb     (abus_mstrb),
        .abus_mkeep     (abus_mkeep),
        .abus_mwdata    (abus_mwdata),
        .abus_maddress  (abus_maddress)
    );

    abus_arbiter #(
        .NB_MASTER  (NB_MASTER),
        .NB_SLAVE   (NB_SLAVE),
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .SCHEDULER  (SCHEDULER)
    ) arbiter (
        .abus_clk       (abus_clk),
        .abus_rstb      (abus_rstb),
        // ==== from bus masters ====
        .abus_mid       (abus_mid),
        .abus_mreq      (abus_mreq),
        .abus_mwrite    (abus_mwrite),
        .abus_mread     (abus_mread),
        .abus_mabort    (abus_mabort),
        .abus_mstrb     (abus_mstrb),
        .abus_mkeep     (abus_mkeep),
        .abus_mwdata    (abus_mwdata),
        .abus_maddress  (abus_maddress),
        // ==== to bus masters ====
        .abus_mack      (abus_mack),
        .abus_mgrant    (abus_mgrant),
        .abus_mrdata    (abus_mrdata), 
        // ==== from bus slaves ====
        .abus_sack      (abus_sack),
        .abus_srdata    (abus_srdata),
        // ==== to bus slaves ====
        .abus_smid      (abus_smid),
        .abus_sreq      (abus_sreq),
        .abus_swrite    (abus_swrite),
        .abus_sread     (abus_sread),
        .abus_sabort    (abus_sabort),
        .abus_sstrb     (abus_sstrb),
        .abus_skeep     (abus_skeep),
        .abus_swdata    (abus_swdata),
        .abus_saddress  (abus_saddress)
    );

    sram #(
        .START_ADDR (0),
        .SIZE       (512),
        .ADDR_WIDTH (16),
        .DATA_WIDTH (16),
        .WAIT_STATE (1)
    ) sram (
        .abus_clk       (abus_clk),
        .abus_rstb      (abus_rstb), 
        // ==== from bus_arbiter ====
        .abus_swrite    (abus_swrite),
        .abus_sread     (abus_sread),
        .abus_sabort    (abus_sabort),
        .abus_saddress  (abus_saddress),
        .abus_swdata    (abus_swdata),
        .abus_sstrb     (abus_sstrb),
        .abus_skeep     (abus_skeep),
        // ==== to bus_arbiter ====
        .abus_sack      (abus_sack),
        .abus_srdata    (abus_srdata)
    );

    initial begin
        $dumpvars();
        abus_clk = 1'b0;
        abus_rstb = 1'b0;
        #(50ns);
        abus_rstb = 1'b1;
        masters[0].WriteWord(16'h0100, 16'hCAFE);
    end

    always forever begin
        #(PERIOD/2) abus_clk = !abus_clk;
    end

    initial begin
        #(1us);
        `log_Fatal("Unexpected timeout");
    end

endmodule