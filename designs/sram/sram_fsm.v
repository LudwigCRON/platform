
`default_nettype none

module sram_fsm (
    input   wire        abus_clk,
    input   wire        abus_rstb,
    input   wire        abus_swrite,
    input   wire        abus_sread,
    input   wire        abus_sabort,
    input   wire        counter_eq0,
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
            S_IDLE   : next_state = (abus_swrite || abus_sread) ? S_WAIT : S_IDLE;
            S_WAIT   : next_state = (counter_eq0) ? S_SAMPLE : S_IDLE;
            default  : next_state = S_IDLE ;
        endcase
    end

    assign counter_init = (current_state == S_IDLE);

endmodule