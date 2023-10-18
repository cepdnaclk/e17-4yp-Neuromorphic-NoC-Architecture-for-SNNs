`include "forwarding_units/ex_forward_unit.v"
`timescale 1ns/100ps

module ex_forward_unit_tb;

    // Delay for signal generation
    parameter fwd_select_delay = 1;

    // Inputs
    reg [4:0] ADDR1, ADDR2, MEM_ADDR, WB_ADDR;
    reg MEM_WRITE_EN, WB_WRITE_EN;

    // Outputs
    wire [1:0] PROD_OP1_FWD_SEL, PROD_OP2_FWD_SEL;  // Produced outputs
    reg [1:0] EXP_OP1_FWD_SEL, EXP_OP2_FWD_SEL;     // Expected outputs

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;

    // Instantiate the forwarding unit module
    ex_forward_unit dut (ADDR1, ADDR2, MEM_ADDR, MEM_WRITE_EN, WB_ADDR, WB_WRITE_EN, PROD_OP1_FWD_SEL, PROD_OP2_FWD_SEL);

    // Test case definitions
    initial 
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        // No forwarding (Different addresses)
        ADDR1    = 5'b01011;
        ADDR2    = 5'b10111;
        MEM_ADDR = 5'b11000;
        WB_ADDR  = 5'b10011;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b00;
        EXP_OP2_FWD_SEL = 2'b00;
        #(fwd_select_delay)
        run_testcase("NO FWD #1");

        // No forwarding (No write enable)
        ADDR1    = 5'b01011;
        ADDR2    = 5'b10111;
        MEM_ADDR = 5'b10111;
        WB_ADDR  = 5'b01011;
        MEM_WRITE_EN = 1'b0;
        WB_WRITE_EN = 1'b0;
        EXP_OP1_FWD_SEL = 2'b00;
        EXP_OP2_FWD_SEL = 2'b00;
        #(fwd_select_delay)
        run_testcase("NO FWD #2");

        // OP1 forwarding from MEM
        ADDR1    = 5'b01011;
        ADDR2    = 5'b10001;
        MEM_ADDR = 5'b01011;
        WB_ADDR  = 5'b11111;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b0;
        EXP_OP1_FWD_SEL = 2'b01;
        EXP_OP2_FWD_SEL = 2'b00;
        #(fwd_select_delay)
        run_testcase("OP1 FWD - MEM");

        // OP1 forwarding from WB
        ADDR1    = 5'b01011;
        ADDR2    = 5'b10001;
        MEM_ADDR = 5'b11111;
        WB_ADDR  = 5'b01011;
        MEM_WRITE_EN = 1'b0;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b10;
        EXP_OP2_FWD_SEL = 2'b00;
        #(fwd_select_delay)
        run_testcase("OP1 FWD - WB");

        // OP1 forwarding from MEM & WB (MEM should take precedence)
        ADDR1    = 5'b01011;
        ADDR2    = 5'b10001;
        MEM_ADDR = 5'b01011;
        WB_ADDR  = 5'b01011;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b01;
        EXP_OP2_FWD_SEL = 2'b00;
        #(fwd_select_delay)
        run_testcase("OP1 FWD - MEM&WB");

        // OP2 forwarding from MEM
        ADDR1    = 5'b10110;
        ADDR2    = 5'b10111;
        MEM_ADDR = 5'b10111;
        WB_ADDR  = 5'b01011;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b00;
        EXP_OP2_FWD_SEL = 2'b01;
        #(fwd_select_delay)
        run_testcase("OP2 FWD - MEM");

        // OP2 forwarding from WB
        ADDR1    = 5'b10110;
        ADDR2    = 5'b10111;
        MEM_ADDR = 5'b10111;
        WB_ADDR  = 5'b10111;
        MEM_WRITE_EN = 1'b0;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b00;
        EXP_OP2_FWD_SEL = 2'b10;
        #(fwd_select_delay)
        run_testcase("OP2 FWD - WB");

        // OP2 forwarding from MEM & WB (MEM should take precedence)
        ADDR1    = 5'b10110;
        ADDR2    = 5'b10111;
        MEM_ADDR = 5'b10111;
        WB_ADDR  = 5'b10111;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b00;
        EXP_OP2_FWD_SEL = 2'b01;
        #(fwd_select_delay)
        run_testcase("OP2 FWD - MEM&WB");

        // OP1 forwarding from MEM and OP2 forwarding from WB
        ADDR1    = 5'b10101;
        ADDR2    = 5'b00011;
        MEM_ADDR = 5'b10101;
        WB_ADDR  = 5'b00011;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b01;
        EXP_OP2_FWD_SEL = 2'b10;
        #(fwd_select_delay)
        run_testcase("OP1 - MEM / OP2 - WB");

        // OP1 forwarding from WB and OP2 forwarding from MEM
        ADDR1    = 5'b10101;
        ADDR2    = 5'b00011;
        MEM_ADDR = 5'b00011;
        WB_ADDR  = 5'b10101;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b10;
        EXP_OP2_FWD_SEL = 2'b01;
        #(fwd_select_delay)
        run_testcase("OP1 - WB / OP2 - MEM");

        // OP1 & OP2 both forwarding from MEM
        ADDR1    = 5'b00011;
        ADDR2    = 5'b00011;
        MEM_ADDR = 5'b00011;
        WB_ADDR  = 5'b10101;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b01;
        EXP_OP2_FWD_SEL = 2'b01;
        #(fwd_select_delay)
        run_testcase("OP1 - MEM / OP2 - MEM");

        // OP1 & OP2 both forwarding from WB
        ADDR1    = 5'b11000;
        ADDR2    = 5'b11000;
        MEM_ADDR = 5'b00011;
        WB_ADDR  = 5'b11000;
        MEM_WRITE_EN = 1'b1;
        WB_WRITE_EN = 1'b1;
        EXP_OP1_FWD_SEL = 2'b10;
        EXP_OP2_FWD_SEL = 2'b10;
        #(fwd_select_delay)
        run_testcase("OP1 - WB / OP2 - WB");

        
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

        // Check operand 1
        if (PROD_OP1_FWD_SEL !== EXP_OP1_FWD_SEL)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_OP1_FWD_SEL = %b, EXP_OP1_FWD_SEL = %b", PROD_OP1_FWD_SEL, EXP_OP1_FWD_SEL);
        
        // Check operand 2
        if (PROD_OP2_FWD_SEL !== EXP_OP2_FWD_SEL)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_OP2_FWD_SEL = %b, EXP_OP2_FWD_SEL = %b", PROD_OP2_FWD_SEL, EXP_OP2_FWD_SEL);

        // Check if testcase passed
        if ((PROD_OP1_FWD_SEL === EXP_OP1_FWD_SEL) && (PROD_OP2_FWD_SEL === EXP_OP2_FWD_SEL))
            pass_count = pass_count + 1;
    end
    endtask
    
endmodule
