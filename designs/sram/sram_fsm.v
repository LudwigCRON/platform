
`default_nettype none

module sram_fsm #(
    parameter integer WAIT_STATE = 2
) (
    input   wire        abus_clk,
    input   wire        abus_rstb,
    input   wire        abus_sreq,
    input   wire        addr_in_range,
    input   wire        counter_le1,
    output  wire        counter_init,
    output  reg  [1:0]  current_state
);

    `include "designs/sram/sram_encoding.vh"

    reg [1:0] next_state;

    always @(posedge abus_clk, negedge abus_rstb)
    begin
        if (!abus_rstb)
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    always @(*)
    begin
        case (current_state)
            S_IDLE   : next_state = (abus_sreq && addr_in_range && WAIT_STATE > 0)  ? S_WAIT   :
                                    (abus_sreq && addr_in_range && WAIT_STATE == 0) ? S_SAMPLE : S_IDLE;
            S_WAIT   : next_state = (counter_le1) ? S_SAMPLE : S_WAIT;
            default  : next_state = S_IDLE ;
        endcase
    end

    assign counter_init = (current_state == S_IDLE);

endmodule