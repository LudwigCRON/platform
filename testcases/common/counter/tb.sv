`timescale 1ns/100ps

module tb;

    parameter integer N = 4;
    parameter integer PERIOD = 40;

    reg         clk;
    reg         load;
    reg         enable;
    reg [N-1:0] load_value;
    reg [N-1:0] q;
    reg [N-1:0] qref;

    // ======== stimuli ========
    initial begin
        $dumpvars();
        clk    = 1'b0;
        load   = 1'b0;
        enable = 1'b0;
        for (int i = 0; i < 16; i += 1)
        begin
            #(50ns);
            load_value = $urandom() % 2**N;
            @(negedge clk) #1 load = 1'b1;
            @(negedge clk) #1 load = 1'b0;
            #(100ns);
            enable = 1'b1;
            #(1us);
            @(posedge clk); #1 load = 1'b1;
            repeat(3) @(posedge clk); #1;
            load   = 1'b0;
            #(1us);
            enable = 1'b0;
        end
        `log_Terminate;
    end

    always forever begin
        #(PERIOD/2) clk = !clk;
    end

    initial begin
        #(48us);
        `log_Fatal("Unexpected timeout");
    end

    // ======== dut ========
    gray_counter #(
        .N  (N)
    ) dut (
        .clk        (clk),
        .load       (load),
        .load_value (load_value),
        .enable     (enable),
        .q          (q)
    );

    // ======== checker ========
    wire err;

    assign err = q ^ qref;

    // formal behaviour checks
    always @(posedge clk) begin
        #1;
    `ifdef FORMAL
        assert (load |->#1 (q != load_value)) else `log_Error("counter loading failed");
        assert (enable |->#1 (q != qref)) else `log_Error("wrong counter behaviour");
    `endif
    end

    // comparison to another block
    /* 
        for the sake of comparison compare
        with the one found below
            https://www.intel.com/content/www/us/en/programmable/support/support-resources/design-examples/design-software/verilog/ver-gray-counter.html
    */
    gray_count #(
        .N  (N)
    ) iref (
        .clk        (clk),
        .enable     (enable),
        .reset      (load),
        .gray_count (qref)
    );

    wire [N-1:-1] init_value;

    assign init_value = {load_value, ~^load_value};

    always @(posedge clk)
    begin
        #1;
        if (enable && !load && err)
            `log_Error("wrong value generated");
        if (load && q != load_value)
            `log_Error("init value not loaded");
    end

    always @(*)
    begin
        if (load && clk)
            $deposit(iref.q, init_value);
    end

endmodule