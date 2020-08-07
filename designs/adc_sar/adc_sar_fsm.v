`default_nettype none

module adc_sar_fsm #(
    parameter integer N          = 8,
    parameter integer STATE_SIZE = 4
) (
    input   wire                  clk,
    input   wire                  rstb,
    input   wire                  enable,
    input   wire                  extra_sample,
    input   wire                  soc,
    input   wire                  rdy,
    output  reg  [STATE_SIZE-1:0] current_state,
    output  reg                   eoc_it
);

    `include "designs/adc_sar/adc_sar_encoding.vh"

    reg  [STATE_SIZE-1:0] next_state;
    wire [STATE_SIZE-1:0] cnt_state;
    wire                  cnt_ovf;
    wire                  not_last_step;
    wire                  stop;

    always @(posedge clk, negedge rstb)
    begin
        if (!rstb)
            current_state <= S_IDLE;
        else if (enable)
            current_state <= next_state;
    end

    always @(*)
    begin
        case (current_state)
            S_IDLE        : next_state = (soc && rdy)   ? S_SAMPLE       : S_IDLE;
            S_SAMPLE      : next_state = (extra_sample) ? S_EXTRA_SAMPLE : S_CONVERT_0;
            S_EXTRA_SAMPLE: next_state = S_CONVERT_0;
            default       : next_state = (stop) ? S_IDLE : cnt_state;
        endcase
    end

    adder_cla #(
        .N  (STATE_SIZE)
    ) incr_state (
        .a  (current_state),
        .b  ({STATE_SIZE{1'b0}}),
        .ci (1'b1),
        .s  (cnt_state),
        .co (cnt_ovf)
    );

    comp_lt #(
        .N      (STATE_SIZE)
    ) limit (
        .a      (current_state),
        .b      (S_MAX),
        .a_lt_b (not_last_step)
    );

    assign stop = cnt_ovf | ~not_last_step;

    always @(posedge clk)
        eoc_it <= stop;

endmodule