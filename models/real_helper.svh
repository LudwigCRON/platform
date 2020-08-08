
/* ==== analog / mixed simulation ==== */

// equivalent of 1'bz in the analog domain is NaN
`define NAN_VALUE 64'b1111111111111000000000000000000000000000000000000000000000000000
`define NaN $bitstoreal(`NAN_VALUE)

function automatic is_nan(
    input real a
);
    is_nan = $realtobits(a) == `NAN_VALUE;
endfunction

// ==== comparison functions ====
function automatic real abs(
    input real a
);
    if (is_nan(a)) abs = `NaN;
    else abs = (a > 0.0) ? a : -a;
endfunction

function automatic real clip(
    input real min,
    input real a,
    input real max
);
    if (is_nan(a)) clip = `NaN;
    else if (min < a && a < max) clip = a;
    else if (a < min) clip = min;
    else clip = max;
endfunction