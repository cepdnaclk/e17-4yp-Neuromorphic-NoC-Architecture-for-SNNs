`include "alu/alu.v"
`timescale 1ns/100ps

module alu_tb;
    reg [31:0] DATA1, DATA2, EXPECTED;
    wire [31:0] RESULT;
    reg [5:0] SELECT;

    wire [1023:0] operation;
    integer testcase_count, pass_count;
  
    // Instantiate the ALU module
    alu dut (DATA1, DATA2, RESULT,SELECT);

    // Operation display workaround
    assign operation = (SELECT === 6'b000000) ? "ADD" :
                        (SELECT === 6'b000001) ? "SLL" :
                        (SELECT === 6'b000010) ? "SLT" :
                        (SELECT === 6'b000011) ? "SLTU" :
                        (SELECT === 6'b000100) ? "XOR" :
                        (SELECT === 6'b000101) ? "SRL" :
                        (SELECT === 6'b000110) ? "OR" :
                        (SELECT === 6'b000111) ? "AND" :
                        (SELECT === 6'b001000) ? "MUL" :
                        (SELECT === 6'b001001) ? "MULH" :
                        (SELECT === 6'b001010) ? "MULHSU" :
                        (SELECT === 6'b001011) ? "MULHU" :
                        (SELECT === 6'b001100) ? "DIV" :
                        (SELECT === 6'b001101) ? "DIVU" :
                        (SELECT === 6'b001110) ? "REM" :
                        (SELECT === 6'b001111) ? "REMU" :
                        (SELECT === 6'b010000) ? "SUB" :
                        (SELECT === 6'b010101) ? "SRA" :
                        (SELECT === 6'b011???) ? "FWD" :
                        "???";

    // Dump wavedata to vcd file
    initial 
    begin
        $dumpfile("build/alu/alu_tb.vcd");
        $dumpvars(0, dut);
    end
  
    // Test case definitions
    initial 
    begin
        // Initialize test cases
        testcase_count = 0;
        pass_count = 0;

        // Display operation type
        $monitor("\033[1m[ %0s ]\033[0m", operation);
        
        /*** ADD ***/
        DATA1 = 32'h00000001;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000003;
        SELECT = 6'b000000;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000000;
        SELECT = 6'b000000;
        run_testcase();

        /*** SLL ***/
        DATA1 = 32'h00000001;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000004;
        SELECT = 6'b000001;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000002;
        EXPECTED = 32'hfffffffc;
        SELECT = 6'b000001;
        run_testcase();

        /*** SLT ***/
        DATA1 = 32'h00000001;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000001;
        SELECT = 6'b000010;
        run_testcase();

        DATA1 = 32'hffffffff;       // -1
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000001;
        SELECT = 6'b000010;
        run_testcase();

        /*** SLTU ***/
        DATA1 = 32'h00000001;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000001;
        SELECT = 6'b000011;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000000;
        SELECT = 6'b000011;
        run_testcase();

        /*** XOR ***/
        DATA1 = 32'h00000001;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000003;
        SELECT = 6'b000100;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'hfffffffe;
        SELECT = 6'b000100;
        run_testcase();

        /*** SRL ***/
        DATA1 = 32'h00000002;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000001;
        SELECT = 6'b000101;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h7fffffff;
        SELECT = 6'b000101;
        run_testcase();

        /*** OR ***/
        DATA1 = 32'h00000001;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000003;
        SELECT = 6'b000110;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000000;
        EXPECTED = 32'hffffffff;
        SELECT = 6'b000110;
        run_testcase();

        /*** AND ***/
        DATA1 = 32'h00000001;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000000;
        SELECT = 6'b000111;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000001;
        SELECT = 6'b000111;
        run_testcase();

        /*** MUL ***/
        DATA1 = 32'h00007e00;
        DATA2 = 32'hb6db6db7;
        EXPECTED = 32'h00001200;
        SELECT = 6'b001000;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'hffffffff;
        EXPECTED = 32'h00000001;
        SELECT = 6'b001000;
        run_testcase();

        /*** MULH ***/
        DATA1 = 32'haaaaaaab;
        DATA2 = 32'h0002fe7d;
        EXPECTED = 32'hffff0081;
        SELECT = 6'b001001;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 =    32'hffffffff;
        EXPECTED = 32'h00000000;
        SELECT = 6'b001001;
        run_testcase();

        /*** MULHSU ***/
        DATA1 = 32'h80000000;       // -2147483648 (signed)
        DATA2 = 32'hffff8000;       // 4294934528 (unsigned)
        EXPECTED = 32'h80004000;
        SELECT = 6'b001010;
        run_testcase();

        DATA1 = 32'haaaaaaab;       // -1431655765 (signed)
        DATA2 = 32'h0002fe7d;       // 196221 (unsigned)
        EXPECTED = 32'hffff0081;
        SELECT = 6'b001010;
        run_testcase();

        DATA1 = 32'h0002fe7d;
        DATA2 = 32'haaaaaaab;
        EXPECTED = 32'h0001fefe;
        SELECT = 6'b001010;
        run_testcase();

        /*** MULHU ***/
        DATA1 = 32'haaaaaaab;
        DATA2 = 32'h0002fe7d;
        EXPECTED = 32'h0001fefe;
        SELECT = 6'b001011;
        run_testcase();

        DATA1 = 32'h80000000;
        DATA2 = 32'hffff8000;
        EXPECTED = 32'h7fffc000;
        SELECT = 6'b001011;
        run_testcase();

        /*** DIV ***/
        DATA1 = 32'h00000003;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000001;
        SELECT = 6'b001100;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'hffffffff;
        SELECT = 6'b001100;
        run_testcase();

        /*** DIVU ***/
        DATA1 = 32'h00000003;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000001;
        SELECT = 6'b001101;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'hffffffff;
        SELECT = 6'b001101;
        run_testcase();

        /*** REM ***/
        DATA1 = 32'h00000003;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000001;
        SELECT = 6'b001110;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000000;
        SELECT = 6'b001110;
        run_testcase();

        /*** REMU ***/
        DATA1 = 32'h00000003;
        DATA2 = 32'h00000002;
        EXPECTED = 32'h00000001;
        SELECT = 6'b001111;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000000;
        SELECT = 6'b001111;
        run_testcase();

        /*** SUB ***/
        DATA1 = 32'h00000002;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000001;
        SELECT = 6'b010000;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'hfffffffE;
        SELECT = 6'b010000;
        run_testcase();

        /*** SRA ***/
        DATA1 = 32'h00000002;
        DATA2 = 32'h00000001;
        EXPECTED = 32'h00000001;
        SELECT = 6'b010101;
        run_testcase();

        DATA1 = 32'hffffffff;
        DATA2 = 32'h00000001;
        EXPECTED = 32'hffffffff;
        SELECT = 6'b010101;
        run_testcase();

        /*** FWD ***/
        DATA1 = 32'h00000000;
        DATA2 = 32'h00000000;
        EXPECTED = 32'h00000000;
        SELECT = 6'b011???;
        run_testcase();

        DATA1 = 32'hFFFFFFFF;
        DATA2 = 32'hFFFFFFFF;
        EXPECTED = 32'hFFFFFFFF;
        SELECT = 6'b011???;
        run_testcase();
        
        // Display test results
        $display("%t - Testbench completed.", $time);
        $display("%t - \033[1;32m%0d out of %0d testcase(s) passing.\033[0m", $time, pass_count, testcase_count);
    end
    
    // Test case execution
    task run_testcase;
    begin
        #10;  // Allow some time for the ALU to compute the result
        
        // Check the result and update pass/fail counts
        if (RESULT !== EXPECTED) 
        begin
            $display("\t\033[1;31m[FAILED]\033[0m DATA1=%x, DATA2=%x, RESULT=%x, EXPECTED=%x",
                    DATA1, DATA2, RESULT, EXPECTED);
        end 
        else 
        begin
            pass_count = pass_count + 1;
        end
        
        testcase_count = testcase_count + 1;
    end
    endtask

endmodule