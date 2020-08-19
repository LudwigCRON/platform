
function automatic integer cones(
    input logic [15:0] mask
);
    integer i, j;
    i = 0;
    for(j = 0; j < 16; j++)
        if (mask[i] == 1'b1) i++;
    cones = i;
endfunction

function automatic integer pick(
    input logic [15:0] mask,
    input logic [15:0] data
);
    integer i, j;
    for(j = 0; j < 16; j++)
    begin
        if (mask[j] == 1'b1)
        begin
            pick += 2**i;
            i++;
        end
    end
endfunction