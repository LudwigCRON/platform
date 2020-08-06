
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

    // ==== from bus_arbiter ====
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

    localparam integer CNT_SIZE = $clog2(WAIT_STATE+1);

    reg           [1:0] current_state;
    
    reg  [CNT_SIZE-1:0] counter;
    wire [CNT_SIZE-1:0] next_counter;
    wire                counter_eq0;
    wire                counter_init;

    wire [DATA_WIDTH-1:0] data;

    // ======== bus interface ========


    // ======== finite state machine ========
    sram_fsm fsm (
        .abus_clk           (abus_clk),
        .abus_rstb          (abus_rstb),
        .abus_swrite        (abus_swrite),
        .abus_sread         (abus_sread),
        .abus_sabort        (abus_sabort),
        .counter_eq0        (counter_eq0),
        .counter_init       (counter_init),
        .current_state      (current_state)
    );

    // ======== counter ========
    always @(posedge abus_clk)
    begin
        if (counter_init)
            counter <= WAIT_STATE;
        else if (~counter_eq0)
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

    assign counter_eq0 = ~|counter;

    // ======== memory bloc ========
    gsram #(
        .START_ADDR     (START_ADDR),
        .SIZE           (SIZE),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH),
        .WAIT_TIME      (20)
    ) ram (
        .read           (abus_sread),
        .write          (abus_swrite),
        .address        (abus_saddress),
        .data           (data)
    );

    assign data = (abus_swrite) ? abus_swdata : {DATA_WIDTH{1'bz}};
    assign abus_srdata =  (abus_sread) ? data : {DATA_WIDTH{1'bz}};

    assign abus_sack = counter_eq0;

    function automatic integer min(
        input integer a,
        input integer b
    );
        min = (a > b) ? b : a;
    endfunction

endmodule