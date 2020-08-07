`default_nettype none

module adc_sar_reconstruction #(
    parameter integer N          = 8,
    parameter integer STATE_SIZE = 4
) (
    input   wire                    clk,
    input   wire                    rstb,
    input   wire                    cmp,
    input   wire [STATE_SIZE-1:0]   current_state,
    output  reg  [N-1:0]            dout
);

    `include "designs/adc_sar/adc_sar_encoding.vh"

    localparam [N-1:0] IDEAL_WEIGHT = 2**(N-1);

    wire         reset;
    reg  [N-1:0] weight;
    wire [N-1:0] sweight;
    reg  [N-1:0] next_dout;

    assign reset =  (current_state == S_IDLE)   ||
                    (current_state == S_SAMPLE) ||
                    (current_state == S_EXTRA_SAMPLE);

    always @(posedge clk, negedge rstb)
    begin
        if (!rstb)
            weight <= IDEAL_WEIGHT;
        else if (reset)
            weight <= IDEAL_WEIGHT;
        else
            weight <= {1'b0, weight[N-1:1]};
    end

    always @(posedge clk, negedge rstb)
    begin
        if (!rstb)
            dout <= {N{1'b0}};
        else if (reset)
            dout <= IDEAL_WEIGHT;
        else
            dout <= next_dout;
    end

    assign sweight = (cmp) ? ~weight : weight;

    adder_cla #(
        .N  (N)
    ) next (
        .a  (dout),
        .b  (sweight),
        .ci (cmp),
        .s  (next_dout),
        .co ()
    );

endmodule