`default_nettype none

module abus_master #(
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16
) (
    input   wire                        abus_clk,
    input   wire                        abus_rstb,

    // ==== orders ====
    input   wire                        write,
    input   wire                        read,
    input   wire                        abort,
    input   wire    [ADDR_WIDTH-1:0]    address,
    input   wire    [DATA_WIDTH-1:0]    wdata,

    output  reg     [DATA_WIDTH-1:0]    rdata,
    output  wire                        new_rdata,
    output  reg                         done,
    output  reg                         err,

    // ==== handshake mechanism ====
    input   wire                        abus_ack,
    output  wire                        abus_req,

    // ==== arbitration ====
    output  wire    [2:0]               abus_mid,
    input   wire                        abus_mgrant,

    // ==== data transmission ====
    output  wire                        abus_write,
    output  wire                        abus_read,
    output  wire                        abus_abort,
    input   wire    [DATA_WIDTH-1:0]    abus_mrdata,
    output  reg     [ADDR_WIDTH-1:0]    abus_maddress,
    output  reg     [DATA_WIDTH-1:0]    abus_mwdata
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
    not g_rq (abus_req  , current_state == S_IDLE);
    buf g_we (abus_write, current_state == S_WRITE);
    buf g_re (abus_read , current_state == S_READ);
    buf g_ab (abus_abort, current_state == S_ABORT);

    // latches to borrow time on crowded bus
    always @(*)
        if (!abus_clk && abus_mgrant)
            abus_maddress <= address;
    
    always @(*)
        if (!abus_clk && abus_mgrant && current_state == S_WRITE)
            abus_mwdata <= wdata;

    // ======== flags to driver ========
    always @(posedge abus_clk)
        done <= ~abus_req && abus_ack && (current_state != S_IDLE);

    always @(posedge abus_clk)
        err <= abus_req && ~abus_ack && (current_state != S_IDLE);

    and g_nr (new_rdata, done, current_state == S_READ);

    always @(posedge abus_clk)
        if (~abus_req && abus_ack && current_state == S_READ)
            rdata <= abus_mrdata;

    `include "designs/abus/abus_helper.vh"

endmodule