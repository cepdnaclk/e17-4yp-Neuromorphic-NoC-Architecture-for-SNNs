`include "cpu/cpu.v"
`timescale 1ns/100ps

module cpu_tb;
    parameter CLOCK_PERIOD = 10;

    // Inputs
    reg CLK, RESET;
    reg [31:0] PROD_DATA_MEM_READ_DATA, INSTRUCTION;
    wire INSTR_MEM_BUSYWAIT, DATA_MEM_BUSYWAIT;

    // Produced Outputs
    wire [2:0] PROD_DATA_MEM_WRITE;
    wire [3:0] PROD_DATA_MEM_READ;
    wire [31:0] PC, PROD_DATA_MEM_ADDR, PROD_DATA_MEM_WRITE_DATA;

    // Expected Outputs
    reg [2:0] EXP_DATA_MEM_WRITE;
    reg [3:0] EXP_DATA_MEM_READ;
    reg [31:0] EXP_DATA_MEM_ADDR, EXP_DATA_MEM_WRITE_DATA;
    reg [31:0] EXP_REG_VALUES [31:0];

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;
    integer fails;
    integer i, j, k;
    

    // Instantiate the CPU
    cpu dut (
        CLK, RESET, PC, INSTRUCTION, PROD_DATA_MEM_READ, PROD_DATA_MEM_WRITE,
        PROD_DATA_MEM_ADDR, PROD_DATA_MEM_WRITE_DATA, PROD_DATA_MEM_READ_DATA,
        DATA_MEM_BUSYWAIT, INSTR_MEM_BUSYWAIT
    );

    // Tie busywait signals to LOW
    assign INSTR_MEM_BUSYWAIT = 0;
    assign DATA_MEM_BUSYWAIT = 0;
    
    // Dump wavedata to vcd file
    initial 
    begin
        $dumpfile("build/cpu/cpu_tb.vcd");
        $dumpvars(0, dut);
        for (k = 0; k < 32; k = k + 1)
            $dumpvars(1, dut.ID_REG_FILE.REGISTERS[k]);
    end

    // Clock pulse
    initial CLK = 1'b1;
    always #(CLOCK_PERIOD / 2) CLK = ~CLK;

    initial
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        reset_values();
        INSTRUCTION = 32'b00000000000000000001000010110111;
        EXP_REG_VALUES[1] = 32'd4096;
        EXP_DATA_MEM_WRITE = 3'b000;
        EXP_DATA_MEM_READ = 4'b0000;
        EXP_DATA_MEM_ADDR = 32'dx;
        EXP_DATA_MEM_WRITE_DATA = 32'dx;
        #(CLOCK_PERIOD*4)           // Wait for WB
        run_testcase("LUI");

        reset_values();
        INSTRUCTION = 32'b0000000011100000000000110010011;
        EXP_REG_VALUES[3] = 32'd7;
        EXP_DATA_MEM_WRITE = 3'b000;
        EXP_DATA_MEM_READ = 4'b0000;
        EXP_DATA_MEM_ADDR = 32'dx;
        EXP_DATA_MEM_WRITE_DATA = 32'dx;
        #(CLOCK_PERIOD*4)
        run_testcase("ADDI");


        // Display test results
        $display("%t - Testbench completed.", $time);
        $display("%t - \033[1;32m%0d out of %0d testcase(s) passing.\033[0m", $time, pass_count, testcase_count);
        
        // End simulation
        $finish;
    end


    // Helper task to run a single testcase
    task run_testcase (input reg[127:0] instruction_name);
    begin
        testcase_count = testcase_count + 1;
        fails = 0;

        // Display instruction being tested
        $display("\033[1m[ %0s ]\033[0m", instruction_name);

        // Compare register values
        for (i = 0; i < 32; i = i + 1) 
        begin
            if (dut.ID_REG_FILE.REGISTERS[i] !== EXP_REG_VALUES[i])
            begin
                $display("\t\033[1;31m[FAILED]\033[0m REGISTERS[%0d] = %0x, EXP_REG_VALUES[%0d] = %0x", i, dut.ID_REG_FILE.REGISTERS[i], i, EXP_REG_VALUES[i]);
                fails = fails + 1;
            end
        end

        // If MSB doesn't match, fail
        // If MSB matches, check LSBs only if MSB=1
        if ((PROD_DATA_MEM_WRITE[2] !== EXP_DATA_MEM_WRITE[2]) ||
            ((PROD_DATA_MEM_WRITE[2] === 1'b1) && (PROD_DATA_MEM_WRITE[1:0] !== EXP_DATA_MEM_WRITE[1:0])))
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_DATA_MEM_WRITE = %b, EXP_DATA_MEM_WRITE = %b", PROD_DATA_MEM_WRITE, EXP_DATA_MEM_WRITE);
            fails = fails + 1;
        end
        
        // If MSB doesn't match, fail
        // If MSB matches, check LSBs only if MSB=1
        if ((PROD_DATA_MEM_READ[3] !== EXP_DATA_MEM_READ[3]) ||
            ((PROD_DATA_MEM_READ[3] === 1'b1) && (PROD_DATA_MEM_READ[2:0] !== EXP_DATA_MEM_READ[2:0])))
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_DATA_MEM_READ = %b, EXP_DATA_MEM_READ = %b", PROD_DATA_MEM_READ, EXP_DATA_MEM_READ);
            fails = fails + 1;
        end

        // Only compare in case of data memory read/write
        if ((EXP_DATA_MEM_READ[3] || EXP_DATA_MEM_WRITE[2]) && (PROD_DATA_MEM_ADDR !== EXP_DATA_MEM_ADDR))
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_DATA_MEM_ADDR = %0x, EXP_DATA_MEM_ADDR = %0x", PROD_DATA_MEM_ADDR, EXP_DATA_MEM_ADDR);
            fails = fails + 1;
        end

    // Only compare in case of data memory write
        if ((EXP_DATA_MEM_WRITE) && (PROD_DATA_MEM_WRITE_DATA !== EXP_DATA_MEM_WRITE_DATA))
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_DATA_MEM_WRITE_DATA = %0x, EXP_DATA_MEM_WRITE_DATA = %0x", PROD_DATA_MEM_WRITE_DATA, EXP_DATA_MEM_WRITE_DATA);
            fails = fails + 1;
        end
        
        // Check if testcase passed
        if (fails === 0) 
        begin
            pass_count = pass_count + 1;
        end
    end
    endtask

    task reset_values;
    begin
        for (j = 0; j < 32; j = j + 1)
        begin
            EXP_REG_VALUES[j] <= 0;       // Write zero to all registers
        end

        RESET = 1;
        #(CLOCK_PERIOD)
        RESET = 0;
    end
    endtask


endmodule