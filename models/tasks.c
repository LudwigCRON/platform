#include <vpi_user.h>

int getbit(PLI_INT32 word, int i) {
    return (word & (1 << i)) ? 1 : 0;
}

static int onehot_calltf(char* user_data) {
    (void)user_data; // prevent unused warning
    /* useful variables */
    PLI_INT32 dword;
    /* connector to simulator */
    s_vpi_value val;
    vpiHandle argv = 0;
    vpiHandle callh = vpi_handle(vpiSysTfCall, 0);
    /* read arguments */
    argv = vpi_iterate(vpiArgument, callh);
    val.format = vpiIntVal;
    if (argv) {
        vpi_free_object(argv);
        vpi_get_value(vpi_scan(argv), &val);
        dword = val.value.integer;
    }
    /* function to detect onehot */
    int ans = 0;
    for(int i = 0; i < 32; i++) {
        ans += getbit(dword, i);
    }
    /* send the value back */
    val.value.integer = (ans < 2) ? 1 : 0;
    vpi_put_value(callh, &val, 0, vpiNoDelay);
    return 0;
}

static int onehot_sizetf(char* user_data) {
    (void)user_data; // prevent unused warning
    return 32;
}

void onehot_register() {
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname      = "$onehot";
    tf_data.calltf      = onehot_calltf;
    tf_data.compiletf   = NULL;
    tf_data.sizetf      = onehot_sizetf;
    tf_data.user_data   = NULL;
    vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])(void) = {
    onehot_register,
    0
};