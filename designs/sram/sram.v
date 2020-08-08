
`default_nettype none

module sram #(
    parameter integer START_ADDR = 0,
    parameter integer SIZE       = 2**8,
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 16,
    parameter integer WAIT_STATE = 2
) (
    input  wire                             abus_clk,
    input  wire                             abus_rstb, 
    input  wire                             chain_scanen,

    // ==== from bus_arbiter ====
    input  wire                             abus_sreq,
    input  wire                             abus_swrite,
    input  wire                             abus_sread,
    input  wire                             abus_sabort,
    input  wire    [ADDR_WIDTH-1:0]         abus_saddress,
    input  wire    [DATA_WIDTH-1:0]         abus_swdata,
    input  wire [$clog2(DATA_WIDTH+1)-1:0]  abus_sstrb,
    input  wire [$clog2(DATA_WIDTH+1)-1:0]  abus_skeep,

    // ==== to bus_arbiter ====
    output wire                             abus_sack,
    output wire    [DATA_WIDTH-1:0]         abus_srdata
);

    `include "designs/sram/sram_encoding.vh"

    localparam integer CNT_SIZE    = $clog2(WAIT_STATE+1);
    localparam integer CNT_ONE     = 1;
    localparam integer FINAL_ADDR  = START_ADDR + SIZE;
    localparam integer START_ADDRB = ~START_ADDR;

    reg           [1:0] current_state;
    
    reg  [CNT_SIZE-1:0] counter;
    wire [CNT_SIZE-1:0] next_counter;
    wire                counter_le1;
    wire                counter_gt1;
    wire                counter_init;

    wire [1:0]            addr_range;
    wire                  addr_in_range;
    wire [ADDR_WIDTH-1:0] phy_address;

    wire                  read;
    wire                  write;
    wire [DATA_WIDTH-1:0] data;
    wire [ADDR_WIDTH-1:0] address;

    // ======== bus interface ========
    comp_lt #(
        .N      (ADDR_WIDTH)
    ) addr_low (
        .a      (abus_saddress),
        .b      (START_ADDR[ADDR_WIDTH-1:0]),
        .a_lt_b (addr_range[0])
    );

    comp_lt #(
        .N      (ADDR_WIDTH)
    ) addr_high (
        .a      (abus_saddress),
        .b      (FINAL_ADDR[ADDR_WIDTH-1:0]),
        .a_lt_b (addr_range[1])
    );

    assign addr_in_range = addr_range[1] & ~addr_range[0];

    adder_cla #(
        .N      (ADDR_WIDTH)
    ) phy_addr (
        .a      (abus_saddress),
        .b      (START_ADDRB[ADDR_WIDTH-1:0]),
        .ci     (1'b1),
        .s      (phy_address),
        .co     ()
    );

    // ======== finite state machine ========
    sram_fsm #(
        .WAIT_STATE         (WAIT_STATE)    
    ) fsm (
        .abus_clk           (abus_clk),
        .abus_rstb          (abus_rstb),
        .abus_sreq          (abus_sreq),
        .addr_in_range      (addr_in_range),
        .counter_le1        (counter_le1),
        .counter_init       (counter_init),
        .current_state      (current_state)
    );

    // ======== counter ========
    generate
        if (CNT_SIZE > 1)
        begin
            always @(posedge abus_clk)
            begin
                if (counter_init)
                    counter <= WAIT_STATE;
                else if (counter_gt1)
                    counter <= next_counter;
            end

            adder_cla #(
                .N  (CNT_SIZE)
            ) sub (
                .a  (counter),
                .b  ({CNT_SIZE{1'b1}}),
                .ci (1'b0),
                .s  (next_counter),
                .co ()
            );

            comp_gt #(
                .N      (CNT_SIZE)
            ) limit (
                .a      (counter),
                .b      (CNT_ONE[CNT_SIZE-1:0]),
                .a_gt_b (counter_gt1)
            );

            assign counter_le1 = ~counter_gt1 & abus_sreq;
        end else if (CNT_SIZE == 1)
        begin
            always @(posedge abus_clk)
                counter <= counter_init && (current_state == S_IDLE);
            
            assign counter_gt1 = ~counter;
            assign counter_le1 =  counter;
        end else
        begin
            assign counter_gt1 = 1'b0;
            assign counter_le1 = 1'b1;
        end
    endgenerate

    // ======== memory bloc ========
    gsram #(
        .SIZE           (SIZE),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH),
        .WAIT_TIME      (30)
    ) ram (
        .read           (abus_sread & addr_in_range),
        .write          (abus_swrite & addr_in_range),
        .address        (address),
        .data           (data)
    );

    aio_blk_latch #(
        .N  (ADDR_WIDTH+DATA_WIDTH+2)
    ) blk_latch (
        .a  ({
            abus_sread & addr_in_range,
            abus_swrite & addr_in_range,
            (abus_swrite) ? abus_swdata : {DATA_WIDTH{1'bz}},
            phy_address
        }),
        .en (~chain_scanen),
        .q  ({
            read,
            write,
            data,
            address
        })
    );

    assign abus_srdata =  (abus_sread) ? data : {DATA_WIDTH{1'bz}};
    assign abus_sack = (current_state == S_SAMPLE);

    function automatic integer min(
        input integer a,
        input integer b
    );
        min = (a > b) ? b : a;
    endfunction

endmodule