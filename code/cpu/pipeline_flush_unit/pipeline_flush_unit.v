`timescale 1ns/100ps

module pipeline_flush_unit (BJ_SIG, LU_HAZ_SIG, PR_IF_ID_RESET, PR_IF_ID_HOLD, PR_ID_EX_RESET);
    
    input BJ_SIG, LU_HAZ_SIG;
    output PR_IF_ID_RESET, PR_IF_ID_HOLD, PR_ID_EX_RESET;

    // In case of a branch/jump, IF/ID PR must be reset
    // In case of a load-use hazard, IF/ID PR must hold its value
    assign PR_IF_ID_RESET = BJ_SIG;
    assign PR_IF_ID_HOLD = !BJ_SIG && LU_HAZ_SIG;

    // In case either a branch/jump or load-use hazard occurs,
    // ID/EX PR must be reset
    assign PR_ID_EX_RESET = BJ_SIG || LU_HAZ_SIG;

endmodule