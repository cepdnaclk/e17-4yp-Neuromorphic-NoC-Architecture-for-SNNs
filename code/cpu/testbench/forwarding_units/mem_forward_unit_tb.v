`include "forwarding_units/mem_forward_unit.v"
`timescale 1ns/100ps

module mem_forward_unit_tb;

    // Delay for signal generation
    parameter fwd_select_delay = 1;

    // Inputs
    reg [4:0] MEM_ADDR, WB_ADDR;
    reg MEM_DATA_MEM_WRITE, WB_DATA_MEM_READ;

    // Outputs
    wire PROD_MEM_FWD_SEL;  // Produced output
    reg EXP_MEM_FWD_SEL;     // Expected output

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;

    // Instantiate the forwarding unit module
    mem_forward_unit dut (MEM_ADDR, MEM_DATA_MEM_WRITE, WB_ADDR, WB_DATA_MEM_READ, PROD_MEM_FWD_SEL);

    // Test case definitions
    initial 
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        // No forwarding (Different addresses)
        MEM_ADDR = 5'b11000;
        WB_ADDR  = 5'b10011;
        MEM_DATA_MEM_WRITE = 1'b1;
        WB_DATA_MEM_READ = 1'b1;
        EXP_MEM_FWD_SEL = 1'b0;
        #(fwd_select_delay)
        run_testcase("DIFF ADDR");

        // No forwarding (No load)
        MEM_ADDR = 5'b11000;
        WB_ADDR  = 5'b11000;
        MEM_DATA_MEM_WRITE = 1'b1;
        WB_DATA_MEM_READ = 1'b0;
        EXP_MEM_FWD_SEL = 1'b0;
        #(fwd_select_delay)
        run_testcase("NO LOAD");

        // No forwarding (No store)
        MEM_ADDR = 5'b11000;
        WB_ADDR  = 5'b11000;
        MEM_DATA_MEM_WRITE = 1'b0;
        WB_DATA_MEM_READ = 1'b1;
        EXP_MEM_FWD_SEL = 1'b0;
        #(fwd_select_delay)
        run_testcase("NO STORE");

        // No forwarding (No store)
        MEM_ADDR = 5'b11000;
        WB_ADDR  = 5'b11000;
        MEM_DATA_MEM_WRITE = 1'b1;
        WB_DATA_MEM_READ = 1'b1;
        EXP_MEM_FWD_SEL = 1'b1;
        #(fwd_select_delay)
        run_testcase("FWD");

        
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
        if (PROD_MEM_FWD_SEL !== EXP_MEM_FWD_SEL)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_MEM_FWD_SEL = %b, EXP_MEM_FWD_SEL = %b", PROD_MEM_FWD_SEL, EXP_MEM_FWD_SEL);
        else
            pass_count = pass_count + 1;
    end
    endtask
    
endmodule
