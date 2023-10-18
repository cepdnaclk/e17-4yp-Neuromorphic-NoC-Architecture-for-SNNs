`include "hazard_detection_unit/hazard_detection_unit.v"
`timescale 1ns/100ps

module hazard_detection_unit_tb;

    // Delay for signal generation
    parameter sig_gen_delay = 1;

    // Inputs
    reg [4:0] ID_ADDR1, ID_ADDR2, EX_REG_WRITE_ADDR;
    reg ID_OPERAND1_SELECT, ID_OPERAND2_SELECT, EX_DATA_MEM_READ;

    // Outputs
    wire PROD_LU_HAZ_SIG;  // Produced output
    reg EXP_LU_HAZ_SIG;     // Expected output

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;

    // Instantiate the hazard detection unit module
    hazard_detection_unit dut (
        ID_ADDR1, ID_ADDR2,
        ID_OPERAND1_SELECT, ID_OPERAND2_SELECT,
        EX_REG_WRITE_ADDR, EX_DATA_MEM_READ,
        PROD_LU_HAZ_SIG
    );

    // Test case definitions
    initial 
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        // No hazard (Different addresses)
        ID_ADDR1          = 5'b01011;
        ID_ADDR2          = 5'b10111;
        EX_REG_WRITE_ADDR = 5'b11000;
        ID_OPERAND1_SELECT = 1'b0;
        ID_OPERAND2_SELECT = 1'b0;
        EX_DATA_MEM_READ = 1'b1;
        EXP_LU_HAZ_SIG = 1'b0;
        #(sig_gen_delay)
        run_testcase("DIFF ADDR");

        // No hazard (No load)
        ID_ADDR1          = 5'b01011;
        ID_ADDR2          = 5'b10111;
        EX_REG_WRITE_ADDR = 5'b10111;
        ID_OPERAND1_SELECT = 1'b0;
        ID_OPERAND2_SELECT = 1'b0;
        EX_DATA_MEM_READ = 1'b0;
        EXP_LU_HAZ_SIG = 1'b0;
        #(sig_gen_delay)
        run_testcase("NO LOAD");

        // No hazard (OP1 = PC)
        ID_ADDR1          = 5'b01011;
        ID_ADDR2          = 5'b10111;
        EX_REG_WRITE_ADDR = 5'b01011;
        ID_OPERAND1_SELECT = 1'b1;
        ID_OPERAND2_SELECT = 1'b0;
        EX_DATA_MEM_READ = 1'b1;
        EXP_LU_HAZ_SIG = 1'b0;
        #(sig_gen_delay)
        run_testcase("OP1 = PC");

        // No hazard (OP2 = IMM)
        ID_ADDR1          = 5'b01011;
        ID_ADDR2          = 5'b10111;
        EX_REG_WRITE_ADDR = 5'b10111;
        ID_OPERAND1_SELECT = 1'b0;
        ID_OPERAND2_SELECT = 1'b1;
        EX_DATA_MEM_READ = 1'b1;
        EXP_LU_HAZ_SIG = 1'b0;
        #(sig_gen_delay)
        run_testcase("OP2 = IMM");

        // Hazard present for OP1
        ID_ADDR1          = 5'b01011;
        ID_ADDR2          = 5'b10111;
        EX_REG_WRITE_ADDR = 5'b01011;
        ID_OPERAND1_SELECT = 1'b0;
        ID_OPERAND2_SELECT = 1'b1;
        EX_DATA_MEM_READ = 1'b1;
        EXP_LU_HAZ_SIG = 1'b1;
        #(sig_gen_delay)
        run_testcase("OP1 HAZ");

        // Hazard present for OP2
        ID_ADDR1          = 5'b01011;
        ID_ADDR2          = 5'b10111;
        EX_REG_WRITE_ADDR = 5'b10111;
        ID_OPERAND1_SELECT = 1'b1;
        ID_OPERAND2_SELECT = 1'b0;
        EX_DATA_MEM_READ = 1'b1;
        EXP_LU_HAZ_SIG = 1'b1;
        #(sig_gen_delay)
        run_testcase("OP2 HAZ");

        // Hazard present for both OP1 and OP2
        ID_ADDR1          = 5'b10111;
        ID_ADDR2          = 5'b10111;
        EX_REG_WRITE_ADDR = 5'b10111;
        ID_OPERAND1_SELECT = 1'b0;
        ID_OPERAND2_SELECT = 1'b0;
        EX_DATA_MEM_READ = 1'b1;
        EXP_LU_HAZ_SIG = 1'b1;
        #(sig_gen_delay)
        run_testcase("OP1+OP2 HAZ");
        
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

        // Check if testcase passed
        if (PROD_LU_HAZ_SIG !== EXP_LU_HAZ_SIG)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_LU_HAZ_SIG = %b, EXP_LU_HAZ_SIG = %b", PROD_LU_HAZ_SIG, EXP_LU_HAZ_SIG);
        else
            pass_count = pass_count + 1;
    end
    endtask

endmodule