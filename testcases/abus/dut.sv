`timescale 1ns/100ps

module dut #(
    parameter integer NB_MASTER  = 1,
    parameter integer NB_SLAVE   = 1,
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16,
    parameter integer PERIOD     = 40
) ();

    // ======== masters ========
    reg                         abus_clk;
    reg                         abus_rstb;
    wire                        write;
    wire                        read;
    wire                        abort;
    wire    [ADDR_WIDTH-1:0]    address;
    wire    [DATA_WIDTH-1:0]    wdata;
    reg     [DATA_WIDTH-1:0]    rdata;
    wire                        new_rdata;
    reg                         done;
    reg                         err;

    // ==== handshake mechanism ====
    wire                        abus_ack;
    wire                        abus_req;

    // ==== arbitration ====
    wire    [2:0]               abus_mid;
    wire                        abus_mgrant;

    // ==== data transmission ====
    wire                        abus_write;
    wire                        abus_read;
    wire                        abus_abort;
    wire    [DATA_WIDTH-1:0]    abus_mrdata;
    reg     [ADDR_WIDTH-1:0]    abus_maddress;
    reg     [DATA_WIDTH-1:0]    abus_mwdata;

    abus_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master (
        .abus_clk       (abus_clk),
        .abus_rstb      (abus_rstb),
        .write          (write),
        .read           (read),
        .abort          (abort),
        .address        (address),
        .wdata          (wdata),
        .rdata          (rdata),
        .new_rdata      (new_rdata),
        .done           (done),
        .err            (err),
        .abus_ack       (abus_ack),
        .abus_req       (abus_req),
        .abus_mid       (abus_mid),
        .abus_mgrant    (abus_mgrant),
        .abus_write     (abus_write),
        .abus_read      (abus_read),
        .abus_abort     (abus_abort),
        .abus_mrdata    (abus_mrdata),
        .abus_maddress  (abus_maddress),
        .abus_mwdata    (abus_mwdata)
    );

    initial begin
        $dumpvars();
        abus_clk = 1'b0;
        #(50ns);
        master.WriteWord(16'h0100, 16'hCAFE);
    end

    always forever begin
        #(PERIOD/2) abus_clk = !abus_clk;
    end

    initial begin
        #(1us);
        `log_Fatal("Unexpected timeout");
    end

endmodule