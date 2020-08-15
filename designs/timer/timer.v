`default_nettype none

module timer #(
    parameter integer A_WIDTH = 4,
    parameter integer B_WIDTH = 4
) (
    input   wire                clk,
    input   wire                rstb,
    input   wire                start,
    input   wire                enable,
    input   wire [A_WIDTH-1:0]  div_a,
    input   wire [B_WIDTH-1:0]  div_b,
    output  wire                timer_it
);
    reg  [A_WIDTH-1:0] cnt_a;
    reg  [B_WIDTH-1:0] cnt_b;
    wire [A_WIDTH-1:0] cnt_a_tmp;
    wire [B_WIDTH-1:0] cnt_b_tmp;

    wire         cnta_gt_zero;
    wire         cntb_gt_zero;

    reg  [1:0]   start_r;
    wire         start_p;

    reg  [1:0]   cnt_done;
    reg          running;

    // ======== resync ========
    always @(posedge clk)
        start_r <= {start_r[0], start};

    assign start_p = start_r[0] & ~start_r[1];

    // ======== counter A ========
    always @(posedge clk, negedge rstb)
    begin
        if (!rstb)
            cnt_a <= {A_WIDTH{1'b0}};
        else if (!enable || start_p || !cnta_gt_zero)
            cnt_a <= div_a;
        else if (running && !cnt_done[0])
            cnt_a <= cnt_a_tmp;
    end

    adder_cla #(
        .N  (A_WIDTH)
    ) cnt_a_next (
        .a      (cnt_a),
        .b      ({A_WIDTH{1'b1}}),
        .ci     (1'b0),
        .s      (cnt_a_tmp),
        .co     ()
    );

    comp_gt #(
        .N  (A_WIDTH)
    ) cnt_a_done (
        .a      (cnt_a),
        .b      ({{(A_WIDTH-1){1'b0}}, 1'b1}),
        .a_gt_b (cnta_gt_zero)
    );

    // ======== counter B ========
    always @(posedge clk, negedge rstb)
    begin
        if (!rstb)
            cnt_b <= {A_WIDTH{1'b0}};
        else if (!enable || start_p)
            cnt_b <= div_b;
        else if (enable && cntb_gt_zero && !cnta_gt_zero)
            cnt_b <= cnt_b_tmp;
    end

    adder_cla #(
        .N  (B_WIDTH)
    ) cnt_b_next (
        .a      (cnt_b),
        .b      ({B_WIDTH{1'b1}}),
        .ci     (1'b0),
        .s      (cnt_b_tmp),
        .co     ()
    );

    comp_gt #(
        .N  (B_WIDTH)
    ) cnt_b_done (
        .a      (cnt_b),
        .b      ({B_WIDTH{1'b0}}),
        .a_gt_b (cntb_gt_zero)
    );

    // ======== interrupt ========
    always @(*)
    begin
        if (start_p)
            running <= 1'b1;
        else if (!cntb_gt_zero)
            running <= 1'b0;
    end
            
    always @(posedge clk)
        cnt_done <= {cnt_done[0], ~running};
    
    assign timer_it = cnt_done[0] & ~cnt_done[1];

endmodule