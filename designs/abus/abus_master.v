`default_nettype none

module abus_master #(
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16,
    parameter [2:0]   MASTER_ID  =  0
) (
    input   wire                                abus_clk,
    input   wire                                abus_rstb,

    // ==== orders ====
    input   wire                                write,
    input   wire                                read,
    input   wire                                abort,
    input   wire    [$clog2(DATA_WIDTH+1)-1:0]  strb,
    input   wire    [$clog2(DATA_WIDTH+1)-1:0]  keep,
    input   wire    [DATA_WIDTH-1:0]            wdata,
    input   wire    [ADDR_WIDTH-1:0]            address,

    output  reg     [DATA_WIDTH-1:0]            rdata,
    output  wire                                new_rdata,
    output  reg                                 done,
    output  reg                                 err,

    // ==== handshake mechanism ====
    input   wire                                abus_mack,
    output  wire                                abus_mreq,

    // ==== arbitration ====
    output  wire    [2:0]                       abus_mid,
    input   wire                                abus_mgrant,

    // ==== data transmission ====
    output  wire                                abus_mwrite,
    output  wire                                abus_mread,
    output  wire                                abus_mabort,
    input   wire    [DATA_WIDTH-1:0]            abus_mrdata,
    output  reg     [$clog2(DATA_WIDTH+1)-1:0]  abus_mstrb,
    output  reg     [$clog2(DATA_WIDTH+1)-1:0]  abus_mkeep,
    output  reg     [DATA_WIDTH-1:0]            abus_mwdata,
    output  reg     [ADDR_WIDTH-1:0]            abus_maddress
);

    `include "designs/abus/abus_encoding.vh"

    reg [1:0] current_state;
    reg [1:0] next_state;

    // ======== finite state machine ========
    always @(*)
    begin
        case (current_state)
            S_IDLE : next_state = (write) ? S_WRITE : (read)  ? S_READ  : S_IDLE;
            S_WRITE: next_state = (done)  ? S_IDLE  : (abort) ? S_ABORT : S_WRITE;
            S_READ : next_state = (done)  ? S_IDLE  : (abort) ? S_ABORT : S_READ;
            S_ABORT: next_state = (done)  ? S_IDLE  : S_ABORT;
        endcase
    end

    always @(posedge abus_clk, negedge abus_rstb)
    begin
        if (!abus_rstb)
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    // ======== bus driver ========
    buf g_id[2:0] (abus_mid, MASTER_ID);
    not g_rq (abus_mreq  , current_state == S_IDLE);
    buf g_we (abus_mwrite, current_state == S_WRITE);
    buf g_re (abus_mread , current_state == S_READ);
    buf g_ab (abus_mabort, current_state == S_ABORT);

    // latches to borrow time on crowded bus
    always @(*)
        if (!abus_clk && abus_mgrant)
            abus_maddress <= address;
        else if (!abus_clk)
            abus_maddress <= {ADDR_WIDTH{1'b0}};
    
    always @(*)
        if (!abus_clk && abus_mgrant && current_state == S_WRITE)
            abus_mwdata <= wdata;
        else if (!abus_clk)
            abus_mwdata <= {DATA_WIDTH{1'b0}};

    // ======== flags to driver ========
    always @(posedge abus_clk)
        done <= abus_mreq && abus_mack && abus_mgrant && (current_state != S_IDLE);

    always @(posedge abus_clk)
        err <= 1'b0; //abus_mreq && ~abus_mack && abus_mgrant && (current_state != S_IDLE);

    and g_nr (new_rdata, done, current_state == S_READ);

    always @(posedge abus_clk)
        if (~abus_mreq && abus_mack && current_state == S_READ)
            rdata <= abus_mrdata;

    `include "designs/abus/abus_helper.vh"

endmodule