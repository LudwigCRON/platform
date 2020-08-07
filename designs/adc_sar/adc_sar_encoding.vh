
localparam [STATE_SIZE-1:0] S_IDLE         = 'd0;
localparam [STATE_SIZE-1:0] S_SAMPLE       = 'd1;
localparam [STATE_SIZE-1:0] S_EXTRA_SAMPLE = 'd2;
localparam [STATE_SIZE-1:0] S_CONVERT_0    = 'd3;
localparam [STATE_SIZE-1:0] S_MAX          = N + 3;