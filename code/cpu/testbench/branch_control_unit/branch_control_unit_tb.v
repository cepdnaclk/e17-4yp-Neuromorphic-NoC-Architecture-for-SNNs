`include "branch_control_unit/branch_control_unit.v"
`timescale 1ns/100ps

module branch_control_unit_tb;

    parameter branch_select_delay = 3;

    // Inputs
    reg [31:0] DATA1, DATA2;
    reg [3:0] SELECT;

    // Outputs
    wire PROD_PC_MUX_OUT;    // Produced output
    reg EXP_PC_MUX_OUT;      // Expected output

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;

    // Instantiate the immediate select unit module
    branch_control_unit dut (DATA1, DATA2, SELECT, PROD_PC_MUX_OUT);

    // Test case definitions
    initial 
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        // JAL / JALR
        DATA1 = 5;
        DATA2 = 7;
        SELECT = 4'b1010;
        EXP_PC_MUX_OUT = 1'b1;
        #(branch_select_delay)
        run_testcase("JAL / JALR");

        // BEQ not taken
        DATA1 = 5;
        DATA2 = 7;
        SELECT = 4'b1000;
        EXP_PC_MUX_OUT = 1'b0;
        #(branch_select_delay)
        run_testcase("BEQ - 0");

        // BEQ taken
        DATA1 = 214;
        DATA2 = 214;
        SELECT = 4'b1000;
        EXP_PC_MUX_OUT = 1'b1;
        #(branch_select_delay)
        run_testcase("BEQ - 1");

        // BNE not taken
        DATA1 = 689;
        DATA2 = 689;
        SELECT = 4'b1001;
        EXP_PC_MUX_OUT = 1'b0;
        #(branch_select_delay)
        run_testcase("BNE - 0");

        // BNE taken
        DATA1 = 43543;
        DATA2 = 6566;
        SELECT = 4'b1001;
        EXP_PC_MUX_OUT = 1'b1;
        #(branch_select_delay)
        run_testcase("BNE - 1");

        // BLT not taken
        DATA1 = 32'h00000001;   // 1
        DATA2 = 32'hffffffff;   // -1
        SELECT = 4'b1100;
        EXP_PC_MUX_OUT = 1'b0;
        #(branch_select_delay)
        run_testcase("BLT - 0");

        // BLT taken
        DATA1 = 32'hffffffff;   // -1
        DATA2 = 32'h00000001;   // 1
        SELECT = 4'b1100;
        EXP_PC_MUX_OUT = 1'b1;
        #(branch_select_delay)
        run_testcase("BLT - 1");

        // BGE not taken
        DATA1 = 32'hffffffff;   // -1
        DATA2 = 32'h00000001;   // 1
        SELECT = 4'b1101;
        EXP_PC_MUX_OUT = 1'b0;
        #(branch_select_delay)
        run_testcase("BGE - 0");

        // BGE taken
        DATA1 = 32'h00000001;   // 1
        DATA2 = 32'hffffffff;   // -1
        SELECT = 4'b1101;
        EXP_PC_MUX_OUT = 1'b1;
        #(branch_select_delay)
        run_testcase("BGE - 1");

        // BLTU not taken
        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        SELECT = 4'b1110;
        EXP_PC_MUX_OUT = 1'b0;
        #(branch_select_delay)
        run_testcase("BLTU - 0");

        // BLTU taken
        DATA1 = 32'h00000001;
        DATA2 = 32'hffffffff;
        SELECT = 4'b1110;
        EXP_PC_MUX_OUT = 1'b1;
        #(branch_select_delay)
        run_testcase("BLTU - 1");

        // BGEU not taken
        DATA1 = 32'h00000001;
        DATA2 = 32'hffffffff;
        SELECT = 4'b1111;
        EXP_PC_MUX_OUT = 1'b0;
        #(branch_select_delay)
        run_testcase("BGEU - 0");

        // BGEU taken
        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        SELECT = 4'b1111;
        EXP_PC_MUX_OUT = 1'b1;
        #(branch_select_delay)
        run_testcase("BGEU - 1");
        
        // Display test results
        $display("%t - Testbench completed.", $time);
        $display("%t - \033[1;32m%0d out of %0d testcase(s) passing.\033[0m", $time, pass_count, testcase_count);
        
        // End simulation
        $finish;
    end
    
    // Helper task to run a single testcase
    task run_testcase (input reg[127:0] immediate_type);
    begin
        testcase_count = testcase_count + 1;

        // Display immediate type being tested
        $display("\033[1m[ %0s ]\033[0m", immediate_type);

        // Check if testcase passed
        if (PROD_PC_MUX_OUT !== EXP_PC_MUX_OUT)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_PC_MUX_OUT = %x, EXP_PC_MUX_OUT = %x", PROD_PC_MUX_OUT, EXP_PC_MUX_OUT);
        else 
            pass_count = pass_count + 1;
    end
    endtask
    
endmodule
