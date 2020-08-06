`timescale 1ns/100ps
`default_nettype none

module gsram #(
    parameter integer START_ADDR = 0,
    parameter integer SIZE       = 2**8,
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16,
    parameter integer WAIT_TIME  = 20
) (
    input   wire                        read,
    input   wire                        write,
    input   wire    [ADDR_WIDTH-1:0]    address,
    inout   wire    [DATA_WIDTH-1:0]    data
);

    localparam [1:0] S_IDLE  = 2'b00;
    localparam [1:0] S_WAIT  = 2'b01;
    localparam [1:0] S_WRITE = 2'b11;
    localparam [1:0] S_READ  = 2'b10;

    reg [DATA_WIDTH-1:0] mem [SIZE-1:0];
    reg [DATA_WIDTH-1:0] rdata;

    reg [1:0] current_state;
    wire      addr_in_range;

    reg [$clog2(WAIT_TIME+1):0] counter;
    wire transaction_start;
    wire transaction_startd;
    wire transaction_pulse;
    wire data_ready;

    assign        transaction_start = (read | write);
    assign #(1ns) transaction_startd = transaction_start;
    assign        transaction_pulse = transaction_start & ~transaction_startd;

    assign #(WAIT_TIME * 1ns + 1ns) data_ready = transaction_pulse;

    // ======== finite state machine ========
    always @(*)
    begin
        if (!read && !write)
            current_state <= S_IDLE;
        else if (transaction_pulse)
            current_state <= S_WAIT;
        else if (data_ready)
            current_state <= ( write && !read) ? S_WRITE :
                             (!write &&  read) ? S_READ  : current_state;
    end

    // ======== operation ========
    always @(*)
    begin
        case (current_state)
            S_WRITE: if (addr_in_range) mem[address - START_ADDR] = data;
            S_READ : rdata = (addr_in_range) ? mem[address - START_ADDR] : {DATA_WIDTH{1'bz}};
            default: ;
        endcase
    end

    assign data = (current_state == S_READ) ? rdata : {DATA_WIDTH{1'bz}};

    // ======== checks ========
    assign addr_in_range = (address >= START_ADDR) && (address < (START_ADDR + SIZE));

endmodule