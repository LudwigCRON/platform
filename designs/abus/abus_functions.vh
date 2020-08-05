
// ======== big muxes ========
function automatic pick_nbm(
    input [NB_MASTER-1:0] selector,
    input [NB_MASTER-1:0] data
);
    pick_nbm = |(data & selector);
endfunction

function automatic [2:0] pick_3nbm(
    input [NB_MASTER-1:0]   selector,
    input [3*NB_MASTER-1:0] data
);
    integer i = 0;
    for(i = 0; i < NB_MASTER; i = i + 1)
    begin
        if (selector[i]) pick_3nbm = data[3*i +: 3];
    end
endfunction

function automatic [DATA_WIDTH-1:0] pick_dnbm(
    input [NB_MASTER-1:0]            selector,
    input [DATA_WIDTH*NB_MASTER-1:0] data
);
    integer i = 0;
    for(i = 0; i < NB_MASTER; i = i + 1)
    begin
        if (selector[i]) pick_dnbm = data[DATA_WIDTH*i +: DATA_WIDTH];
    end
endfunction

function automatic [DATA_WIDTH-1:0] pick_dnbs(
    input [NB_SLAVE-1:0]            selector,
    input [DATA_WIDTH*NB_SLAVE-1:0] data
);
    integer i = 0;
    for(i = 0; i < NB_SLAVE; i = i + 1)
    begin
        if (selector[i]) pick_dnbs = data[DATA_WIDTH*i +: DATA_WIDTH];
    end
endfunction

function automatic [ADDR_WIDTH-1:0] pick_anbm(
    input [NB_MASTER-1:0]            selector,
    input [ADDR_WIDTH*NB_MASTER-1:0] data
);
    integer i = 0;
    for(i = 0; i < NB_MASTER; i = i + 1)
    begin
        if (selector[i]) pick_anbm = data[ADDR_WIDTH*i +: ADDR_WIDTH];
    end
endfunction