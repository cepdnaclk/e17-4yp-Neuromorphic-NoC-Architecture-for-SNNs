`include "immediate_select_unit/immediate_select_unit.v"
`timescale 1ns/100ps

module immediate_select_unit_tb;

    parameter imm_select_delay = 1;

    // Inputs
    reg [31:0] INSTRUCTION;
    reg [2:0] SELECT;

    // Outputs
    wire [31:0] PROD_OUTPUT;    // Produced output
    reg [31:0] EXP_OUTPUT;  // Expected output

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;

    // Instantiate the immediate select unit module
    immediate_select_unit dut (INSTRUCTION, SELECT, PROD_OUTPUT);

    // Test case definitions
    initial 
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        // TYPE U
        // [imm 31:12] [rd] [opcode]
        INSTRUCTION = { 20'h53a4c, 5'b0, 7'b1100011 };    // lui
        SELECT = 3'b000;
        EXP_OUTPUT = 32'h53a4c000;
        #(imm_select_delay)
        run_testcase("TYPE U");

        // TYPE J
        // [imm 20] [imm 10:1] [imm 11] [imm 19:12] [rd] [opcode]
        INSTRUCTION = { 1'b1, 10'b1011010111, 1'b0, 8'b11100011, 5'b0, 7'b1100011 };    // jal
        SELECT = 3'b001;
        EXP_OUTPUT = 32'hfffe35ae;
        #(imm_select_delay)
        run_testcase("TYPE J");

        // TYPE I
        // [imm 11:0] [rs1] [funct3] [rd] [opcode]
        INSTRUCTION = { 12'hfe8, 5'b0, 3'b000, 5'b0, 7'b0010011 };    // addi
        SELECT = 3'b010;
        EXP_OUTPUT = 32'hffffffe8;
        #(imm_select_delay)
        run_testcase("TYPE I");

        // TYPE B
        // [imm 12] [imm 10:5] [rs2] [rs1] [funct3] [imm 4:1] [imm 11] [opcode]
        INSTRUCTION = { 1'b1, 6'b001010, 5'b0, 5'b0, 3'b000, 4'b1101, 1'b1, 7'b1100011 };    // beq
        SELECT = 3'b011;
        EXP_OUTPUT = 32'hfffff95a;
        #(imm_select_delay)
        run_testcase("TYPE B");
        
        // TYPE S
        // [imm 11:5] [rs2] [rs1] [funct3] [imm 4:0] [opcode]
        INSTRUCTION = { 7'b1001010, 5'b0, 5'b0, 3'b000, 5'b01010, 7'b0100011 };    // sb
        SELECT = 3'b100;
        EXP_OUTPUT = 32'hfffff94a;
        #(imm_select_delay)
        run_testcase("TYPE S");

        // No Immediate
        INSTRUCTION = { 7'b0100000, 5'b0, 5'b0, 3'b000, 5'b0, 7'b0110011 };     // sub
        SELECT = 3'bxxx;
        EXP_OUTPUT = 32'h0;
        #(imm_select_delay);
        run_testcase("NO IMM");
        
        // Display test results
        $display("%t - Testbench completed.", $time);
        $display("%t - \033[1;32m%0d out of %0d testcase(s) passing.\033[0m", $time, pass_count, testcase_count);
        
        // End simulation
        $finish;
    end
    
    // Helper task to run a single testcase
    task run_testcase (input reg[63:0] immediate_type);
    begin
        testcase_count = testcase_count + 1;

        // Display immediate type being tested
        $display("\033[1m[ %0s ]\033[0m", immediate_type);

        // Check if testcase passed
        if (PROD_OUTPUT !== EXP_OUTPUT)
            $display("\t\033[1;31m[FAILED]\033[0m PROD_OUTPUT = %x, EXP_OUTPUT = %x", PROD_OUTPUT, EXP_OUTPUT);
        else 
            pass_count = pass_count + 1;
    end
    endtask
    
endmodule
