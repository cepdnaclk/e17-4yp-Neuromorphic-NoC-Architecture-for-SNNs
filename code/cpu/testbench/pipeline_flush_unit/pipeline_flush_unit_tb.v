`include "pipeline_flush_unit/pipeline_flush_unit.v"
`timescale 1ns/100ps

module pipeline_flush_unit_tb;

// Delay for signal generation
    parameter sig_gen_delay = 1;

    // Inputs
    reg BJ_SIG, LU_HAZ_SIG;

    // Outputs
    wire PROD_PR_IF_ID_RESET, PROD_PR_IF_ID_HOLD, PROD_PR_ID_EX_RESET;  // Produced outputs
    reg  EXP_PR_IF_ID_RESET, EXP_PR_IF_ID_HOLD, EXP_PR_ID_EX_RESET;     // Expected outputs

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;

    // Instantiate the pipeline flush unit module
    pipeline_flush_unit dut (BJ_SIG, LU_HAZ_SIG, PROD_PR_IF_ID_RESET, PROD_PR_IF_ID_HOLD, PROD_PR_ID_EX_RESET);

    // Test case definitions
    initial 
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        // Normal operation
        BJ_SIG = 1'b0;
        LU_HAZ_SIG = 1'b0;
        EXP_PR_IF_ID_RESET = 1'b0;
        EXP_PR_IF_ID_HOLD = 1'b0;
        EXP_PR_ID_EX_RESET = 1'b0;
        #(sig_gen_delay)
        run_testcase("NORMAL");

        // Branch/Jump Instruction
        BJ_SIG = 1'b1;
        LU_HAZ_SIG = 1'b0;
        EXP_PR_IF_ID_RESET = 1'b1;
        EXP_PR_IF_ID_HOLD = 1'b0;
        EXP_PR_ID_EX_RESET = 1'b1;
        #(sig_gen_delay)
        run_testcase("B/J");

        // Load-Use Hazard
        BJ_SIG = 1'b0;
        LU_HAZ_SIG = 1'b1;
        EXP_PR_IF_ID_RESET = 1'b0;
        EXP_PR_IF_ID_HOLD = 1'b1;
        EXP_PR_ID_EX_RESET = 1'b1;
        #(sig_gen_delay)
        run_testcase("LU HAZ");

        // B/J + Load-Use Hazard (Should never occur under normal operation)
        BJ_SIG = 1'b1;
        LU_HAZ_SIG = 1'b1;
        EXP_PR_IF_ID_RESET = 1'b1;
        EXP_PR_IF_ID_HOLD = 1'b0;
        EXP_PR_ID_EX_RESET = 1'b1;
        #(sig_gen_delay)
        run_testcase("B/J + LU HAZ");
        
        // Display test results
        $display("%t - Testbench completed.", $time);
        $display("%t - \033[1;32m%0d out of %0d testcase(s) passing.\033[0m", $time, pass_count, testcase_count);
        
        // End simulation
        $finish;
    end
    
    // Helper task to run a single testcase
    task run_testcase (input reg[255:0] testcase_name);
    begin
        testcase_count = testcase_count + 1;

        // Display immediate type being tested
        $display("\033[1m[ %0s ]\033[0m", testcase_name);

        // Check IF/ID RESET signal
        if (PROD_PR_IF_ID_RESET !== EXP_PR_IF_ID_RESET)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_PR_IF_ID_RESET = %b, EXP_PR_IF_ID_RESET = %b", PROD_PR_IF_ID_RESET, EXP_PR_IF_ID_RESET);

        // Check IF/ID HOLD signal
        if (PROD_PR_IF_ID_HOLD !== EXP_PR_IF_ID_HOLD)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_PR_IF_ID_HOLD = %b, EXP_PR_IF_ID_HOLD = %b", PROD_PR_IF_ID_HOLD, EXP_PR_IF_ID_HOLD);

        // Check ID/EX RESET signal
        if (PROD_PR_ID_EX_RESET !== EXP_PR_ID_EX_RESET)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_PR_ID_EX_RESET = %b, EXP_PR_ID_EX_RESET = %b", PROD_PR_ID_EX_RESET, EXP_PR_ID_EX_RESET);

        // Check if testcase passed
        if (
            (PROD_PR_IF_ID_RESET === EXP_PR_IF_ID_RESET) &&
            (PROD_PR_IF_ID_HOLD === EXP_PR_IF_ID_HOLD) &&
            (PROD_PR_ID_EX_RESET === EXP_PR_ID_EX_RESET)
        )
            pass_count = pass_count + 1;
    end
    endtask

endmodule