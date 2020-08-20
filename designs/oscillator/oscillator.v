`default_nettype none

module oscillator #(
    parameter integer N     = 8,
    parameter integer SHIFT = 6,
    parameter integer MULT  = 1,
    parameter integer START = 2**(N-1) * 0.9
) (
    input  wire                 clk,
    input  wire                 rstb,
    output reg signed [N-1:0]   cos,
    output reg signed [N-1:0]   sin
);

always @(posedge clk)
begin 
    if (rstb) begin
        cos <= START;
        sin <= {N{1'b0}};
    end else begin
        cos <= cos - ((sin + (cos*MULT >>> SHIFT))*MULT >>> SHIFT);
        sin <= sin + (cos*MULT >>> SHIFT);
    end
end

endmodule