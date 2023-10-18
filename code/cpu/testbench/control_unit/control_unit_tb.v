`include "control_unit/control_unit.v"
`timescale 1ns/100ps

module control_unit_tb;

    parameter decode_delay = 4;

    // Instruction input
    reg [31:0] INSTRUCTION;

    // Produced outputs
    wire PROD_REG_WRITE_EN, PROD_FREG_WRITE_EN, 
         PROD_OPERAND1_SELECT, PROD_OPERAND2_SELECT, 
         PROD_DATA_MEM_WRITE_DATA_SELECT;
    wire [5:0] PROD_ALU_SELECT;
    wire [4:0] PROD_FPU_SELECT;
    wire [2:0] PROD_DATA_MEM_WRITE, PROD_IMMEDIATE_SELECT;
    wire [3:0] PROD_DATA_MEM_READ;
    wire [3:0] PROD_BRANCH_CTRL;
    wire [1:0] PROD_WRITEBACK_VALUE_SELECT, PROD_REG_TYPE;

    // Expected outputs
    reg EXP_REG_WRITE_EN, EXP_FREG_WRITE_EN, 
        EXP_OPERAND1_SELECT, EXP_OPERAND2_SELECT,
        EXP_DATA_MEM_WRITE_DATA_SELECT;
    reg [5:0] EXP_ALU_SELECT;
    reg [4:0] EXP_FPU_SELECT;
    reg [2:0] EXP_DATA_MEM_WRITE, EXP_IMMEDIATE_SELECT;
    reg [3:0] EXP_DATA_MEM_READ;
    reg [3:0] EXP_BRANCH_CTRL;
    reg [1:0] EXP_WRITEBACK_VALUE_SELECT, EXP_REG_TYPE;

    // Counters for passing and total testcases
    integer pass_count;
    integer testcase_count;
    integer fails;

    // Instantiate the control unit module
    control_unit dut (INSTRUCTION, PROD_ALU_SELECT, PROD_REG_WRITE_EN, 
                        PROD_DATA_MEM_WRITE, PROD_DATA_MEM_READ, PROD_BRANCH_CTRL, 
                        PROD_IMMEDIATE_SELECT, PROD_OPERAND1_SELECT, PROD_OPERAND2_SELECT, 
                        PROD_WRITEBACK_VALUE_SELECT, PROD_REG_TYPE, PROD_FREG_WRITE_EN,
                        PROD_FPU_SELECT, PROD_DATA_MEM_WRITE_DATA_SELECT);

    // Test case definitions
    initial 
    begin
        // Initialize test cases
        pass_count = 0;
        testcase_count = 0;

        // LUI
        // [imm] [rd] [opcode]
        INSTRUCTION = { 20'b0, 5'b0, 7'b0110111 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz11000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b000;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("LUI");

        // AUIPC
        // [imm] [rd] [opcode]
        INSTRUCTION = { 20'b0, 5'b0, 7'b0010111 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b000;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("AUIPC");

        // JAL
        // [imm] [rd] [opcode]
        INSTRUCTION = { 20'b0, 5'b0, 7'b1101111 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1010;
        EXP_IMMEDIATE_SELECT = 3'b001;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b00;
        #(decode_delay)
        run_testcase("JAL");

        // JALR
        // [imm] [rs1] [000] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b000, 5'b0, 7'b1100111 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1010;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b00;
        #(decode_delay)
        run_testcase("JALR");

        // BEQ
        // [imm] [rs2] [rs1] [000] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b000, 5'b0, 7'b1100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1000;
        EXP_IMMEDIATE_SELECT = 3'b011;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("BEQ");

        // BNE
        // [imm] [rs2] [rs1] [001] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b001, 5'b0, 7'b1100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1001;
        EXP_IMMEDIATE_SELECT = 3'b011;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("BNE");

        // BLT
        // [imm] [rs2] [rs1] [100] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b100, 5'b0, 7'b1100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1100;
        EXP_IMMEDIATE_SELECT = 3'b011;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("BLT");

        // BGE
        // [imm] [rs2] [rs1] [101] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b101, 5'b0, 7'b1100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1101;
        EXP_IMMEDIATE_SELECT = 3'b011;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("BGE");

        // BLTU
        // [imm] [rs2] [rs1] [110] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b110, 5'b0, 7'b1100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1110;
        EXP_IMMEDIATE_SELECT = 3'b011;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("BLTU");

        // BGEU
        // [imm] [rs2] [rs1] [111] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b111, 5'b0, 7'b1100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b1111;
        EXP_IMMEDIATE_SELECT = 3'b011;
        EXP_OPERAND1_SELECT = 1'b1;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("BGEU");

        // LB
        // [imm] [rs1] [000] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b000, 5'b0, 7'b0000011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b1000;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b01;
        #(decode_delay)
        run_testcase("LB");

        // LH
        // [imm] [rs1] [001] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b001, 5'b0, 7'b0000011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b1001;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b01;
        #(decode_delay)
        run_testcase("LH");

        // LW
        // [imm] [rs1] [010] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b010, 5'b0, 7'b0000011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b1010;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b01;
        #(decode_delay)
        run_testcase("LW");

        // LBU
        // [imm] [rs1] [100] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b100, 5'b0, 7'b0000011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b1100;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b01;
        #(decode_delay)
        run_testcase("LBU");

        // LHU
        // [imm] [rs1] [101] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b101, 5'b0, 7'b0000011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b1101;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b01;
        #(decode_delay)
        run_testcase("LHU");

        // SB
        // [imm] [rs2] [rs1] [000] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b000, 5'b0, 7'b0100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b100;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b100;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SB");

        // SH
        // [imm] [rs2] [rs1] [001] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b001, 5'b0, 7'b0100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b101;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b100;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SH");

        // SW
        // [imm] [rs2] [rs1] [010] [imm] [opcode]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b010, 5'b0, 7'b0100011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b110;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b100;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SW");

        // ADDI
        // [imm [rs1] [000] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b000, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("ADDI");

        // SLTI
        // [imm [rs1] [010] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b010, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00010;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SLTI");

        // SLTIU
        // [imm [rs1] [011] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b011, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00011;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SLTIU");

        // XORI
        // [imm [rs1] [100] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b100, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00100;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("XORI");

        // ORI
        // [imm [rs1] [110] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b110, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00110;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("ORI");

        // ANDI
        // [imm [rs1] [111] [rd] [opcode]
        INSTRUCTION = { 12'b0, 5'b0, 3'b111, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00111;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("ANDI");

        // SLLI
        // [0000000] [shamt] [rs1] [001] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b001, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00001;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SLLI");

        // SRLI
        // [0000000] [shamt] [rs1] [101] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b101, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00101;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SRLI");

        // SRAI
        // [0100000] [shamt] [rs1] [101] [rd] [opcode]
        INSTRUCTION = { 7'b0100000, 5'b0, 5'b0, 3'b101, 5'b0, 7'b0010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz10101;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'b010;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SRAI");

        // ADD
        // [0000000] [rs2] [rs1] [000] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b000, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("ADD");

        // SUB
        // [0100000] [rs2] [rs1] [000] [rd] [opcode]
        INSTRUCTION = { 7'b0100000, 5'b0, 5'b0, 3'b000, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz10000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SUB");

        // SLL
        // [0000000] [rs2] [rs1] [001] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b001, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00001;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SLL");

        // SLT
        // [0000000] [rs2] [rs1] [010] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b010, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00010;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SLT");

        // SLTU
        // [0000000] [rs2] [rs1] [011] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b011, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00011;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SLTU");

        // XOR
        // [0000000] [rs2] [rs1] [100] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b100, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00100;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("XOR");

        // SRL
        // [0000000] [rs2] [rs1] [101] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b101, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00101;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SRL");

        // SRA
        // [0100000] [rs2] [rs1] [101] [rd] [opcode]
        INSTRUCTION = { 7'b0100000, 5'b0, 5'b0, 3'b101, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz10101;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("SRA");

        // OR
        // [0000000] [rs2] [rs1] [110] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b110, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00110;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("OR");

        // AND
        // [0000000] [rs2] [rs1] [111] [rd] [opcode]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b111, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00111;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("OR");

        // MUL
        // [0000001] [rs2] [rs1] [000] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b000, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("MUL");

        // MULH
        // [0000001] [rs2] [rs1] [001] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b001, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01001;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("MULH");

        // MULHSU
        // [0000001] [rs2] [rs1] [010] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b010, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01010;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("MULHSU");

        // MULHU
        // [0000001] [rs2] [rs1] [011] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b011, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01011;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("MULHU");

        // DIV
        // [0000001] [rs2] [rs1] [100] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b100, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01100;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("DIV");

        // DIVU
        // [0000001] [rs2] [rs1] [101] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b101, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01101;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("DIVU");

        // REM
        // [0000001] [rs2] [rs1] [110] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b110, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01110;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("REM");

        // REMU
        // [0000001] [rs2] [rs1] [111] [rd] [opcode]
        INSTRUCTION = { 7'b0000001, 5'b0, 5'b0, 3'b111, 5'b0, 7'b0110011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz01111;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("REMU");

        // FLW
        // [imm] [rs1] [010] [rd] [0000111]
        INSTRUCTION = { 12'b0, 5'b0, 3'b010, 5'b0, 7'b0000111 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b1010;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b01;
        #(decode_delay)
        run_testcase("FLW");

        // FSW
        // [imm] [rs2] [rs1] [010] [imm] [0100111]
        INSTRUCTION = { 7'b0, 5'b0, 5'b0, 3'b010, 5'b0, 7'b0100111 };
        EXP_REG_TYPE = 2'b01;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b1;
        EXP_DATA_MEM_WRITE = 3'b110;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b1;
        EXP_WRITEBACK_VALUE_SELECT = 2'b10;
        #(decode_delay)
        run_testcase("FSW");

        // FMADD
        // [rs3] [00] [rs2] [rs1] [rm] [rd] [1000011]
        INSTRUCTION = { 5'b0, 2'b00, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1000011 };
        EXP_REG_TYPE = 2'b11;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01110;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FMADD");

        // FMSUB
        // [rs3] [00] [rs2] [rs1] [rm] [rd] [1000011]
        INSTRUCTION = { 5'b0, 2'b00, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1000111 };
        EXP_REG_TYPE = 2'b11;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01111;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FMSUB");

        // FNMSUB
        // [rs3] [00] [rs2] [rs1] [rm] [rd] [1001011]
        INSTRUCTION = { 5'b0, 2'b00, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1001011 };
        EXP_REG_TYPE = 2'b11;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b10001;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FNMSUB");


        // FNMADD
        // [rs3] [00] [rs2] [rs1] [rm] [rd] [1001111]
        INSTRUCTION = { 5'b0, 2'b00, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1001111 };
        EXP_REG_TYPE = 2'b11;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b10000;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FNMADD");

        // FADD
        // [0000000] [rs2] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b0000000, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00001;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FADD");

        // FSUB
        // [0000100] [rs2] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b0000100, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00010;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FSUB");

        // FMUL
        // [0001000] [rs2] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b0001000, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00011;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FMUL");

        // FDIV
        // [0001100] [rs2] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b0001100, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00100;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FDIV");

        // FSQRT
        // [0101100] [00000] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b0101100, 5'b0, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01101;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FSQRT");

        // FSGNJ
        // [0010000] [rs2] [rs1] [000] [rd] [1010011]
        INSTRUCTION = { 7'b0010000, 5'b0, 5'b0, 3'b000, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00111;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FSGNJ");

        // FSGNJN
        // [0010000] [rs2] [rs1] [001] [rd] [1010011]
        INSTRUCTION = { 7'b0010000, 5'b0, 5'b0, 3'b001, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01000;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FSGNJN");

        // FSGNJX
        // [0010000] [rs2] [rs1] [010] [rd] [1010011]
        INSTRUCTION = { 7'b0010000, 5'b0, 5'b0, 3'b010, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01001;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FSGNJX");

        // FMIN
        // [0010100] [rs2] [rs1] [000] [rd] [1010011]
        INSTRUCTION = { 7'b0010100, 5'b0, 5'b0, 3'b000, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00101;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FMIN");

        // FMAX
        // [0010100] [rs2] [rs1] [001] [rd] [1010011]
        INSTRUCTION = { 7'b0010100, 5'b0, 5'b0, 3'b001, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00110;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FMAX");

        // FCVTWS
        // [1100000] [00000] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b1100000, 5'b00000, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b10010;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FCVTWS");

        // FCVTWUS
        // [1100000] [00001] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b1100000, 5'b00001, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b10011;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FCVTWUS");

        // FMVXW
        // [1110000] [00000] [rs1] [000] [rd] [1010011]
        INSTRUCTION = { 7'b1110000, 5'b00000, 5'b0, 3'b000, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b00000;
        EXP_REG_WRITE_EN = 1'b1;
        EXP_FREG_WRITE_EN = 1'b0;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FMVXW");

        // FEQ
        // [1010000] [rs2] [rs1] [010] [rd] [1010011]
        INSTRUCTION = { 7'b1010000, 5'b0, 5'b0, 3'b010, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01010;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FEQ");

        // FLT
        // [1010000] [rs2] [rs1] [001] [rd] [1010011]
        INSTRUCTION = { 7'b1010000, 5'b0, 5'b0, 3'b001, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01011;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FLT");

        // FLE
        // [1010000] [rs2] [rs1] [000] [rd] [1010011]
        INSTRUCTION = { 7'b1010000, 5'b0, 5'b0, 3'b000, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b01100;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FLE");

        /* // FCLASS
        // [1110000] [00000] [rs1] [001] [rd] [1010011]
        INSTRUCTION = { 7'b1110000, 5'b00000, 5'b0, 3'b001, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b10;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'b10100;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FCLASS"); */

        // FCVTSW
        // [1101000] [00000] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b1101000, 5'b00000, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FCVTSW");

        // FCVTSWU
        // [1101000] [00001] [rs1] [rm] [rd] [1010011]
        INSTRUCTION = { 7'b1101000, 5'b00001, 5'b0, 3'b0, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FCVTSWU");

        // FMVWX
        // [1111000] [00000] [rs1] [000] [rd] [1010011]
        INSTRUCTION = { 7'b1111000, 5'b00000, 5'b0, 3'b000, 5'b0, 7'b1010011 };
        EXP_REG_TYPE = 2'b00;
        EXP_ALU_SELECT = 6'bz00000;
        EXP_FPU_SELECT = 5'bxxxxx;
        EXP_REG_WRITE_EN = 1'b0;
        EXP_FREG_WRITE_EN = 1'b1;
        EXP_DATA_MEM_WRITE_DATA_SELECT = 1'b0;
        EXP_DATA_MEM_WRITE = 3'b0??;
        EXP_DATA_MEM_READ = 4'b0???;
        EXP_BRANCH_CTRL = 4'b0???;
        EXP_IMMEDIATE_SELECT = 3'bxxx;
        EXP_OPERAND1_SELECT = 1'b0;
        EXP_OPERAND2_SELECT = 1'b0;
        EXP_WRITEBACK_VALUE_SELECT = 2'b11;
        #(decode_delay)
        run_testcase("FMVWX");

        // Display test results
        $display("%t - Testbench completed.", $time);
        $display("%t - \033[1;32m%0d out of %0d testcase(s) passing.\033[0m", $time, pass_count, testcase_count);
        
        // End simulation
        $finish;
    end
    
    // Helper task to run a single testcase
    task run_testcase (input reg[63:0] instruction_name);
    begin
        testcase_count = testcase_count + 1;
        fails = 0;

        // Display instruction being tested
        $display("\033[1m[ %0s ]\033[0m", instruction_name);

        // Compare produced and expected values
        if (PROD_REG_TYPE !== EXP_REG_TYPE)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_REG_TYPE = %b, EXP_REG_TYPE = %b", PROD_REG_TYPE, EXP_REG_TYPE);
            fails = fails + 1;
        end

        if (PROD_ALU_SELECT !== EXP_ALU_SELECT)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_ALU_SELECT = %b, EXP_ALU_SELECT = %b", PROD_ALU_SELECT, EXP_ALU_SELECT);
            fails = fails + 1;
        end

        if (PROD_FPU_SELECT !== EXP_FPU_SELECT)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_FPU_SELECT = %b, EXP_FPU_SELECT = %b", PROD_FPU_SELECT, EXP_FPU_SELECT);
            fails = fails + 1;
        end

        if (PROD_REG_WRITE_EN !== EXP_REG_WRITE_EN)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_REG_WRITE_EN = %b, EXP_REG_WRITE_EN = %b", PROD_REG_WRITE_EN, EXP_REG_WRITE_EN);
            fails = fails + 1;
        end

        if (PROD_FREG_WRITE_EN !== EXP_FREG_WRITE_EN)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_FREG_WRITE_EN = %b, EXP_FREG_WRITE_EN = %b", PROD_FREG_WRITE_EN, EXP_FREG_WRITE_EN);
            fails = fails + 1;
        end

        // If MSB doesn't match, fail
        // If MSB matches, check LSBs only if MSB=1
        if ((PROD_DATA_MEM_WRITE[2] !== EXP_DATA_MEM_WRITE[2]) ||
            ((PROD_DATA_MEM_WRITE[2] === 1'b1) && (PROD_DATA_MEM_WRITE[1:0] !== EXP_DATA_MEM_WRITE[1:0])))
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_DATA_MEM_WRITE = %b, EXP_DATA_MEM_WRITE = %b", PROD_DATA_MEM_WRITE, EXP_DATA_MEM_WRITE);
            fails = fails + 1;
        end

        if (PROD_DATA_MEM_WRITE_DATA_SELECT !== EXP_DATA_MEM_WRITE_DATA_SELECT)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_DATA_MEM_WRITE_DATA_SELECT = %b, EXP_DATA_MEM_WRITE_DATA_SELECT = %b",
                PROD_DATA_MEM_WRITE_DATA_SELECT, EXP_DATA_MEM_WRITE_DATA_SELECT);
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

        // If MSB doesn't match, fail
        // If MSB matches, check LSBs only if MSB=1
        if ((PROD_BRANCH_CTRL[3] !== EXP_BRANCH_CTRL[3]) ||
            ((PROD_BRANCH_CTRL[3] === 1'b1) && (PROD_BRANCH_CTRL[2:0] !== EXP_BRANCH_CTRL[2:0])))
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_BRANCH_CTRL = %b, EXP_BRANCH_CTRL = %b", PROD_BRANCH_CTRL, EXP_BRANCH_CTRL);
            fails = fails + 1;
        end

        if (PROD_IMMEDIATE_SELECT !== EXP_IMMEDIATE_SELECT)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_IMMEDIATE_SELECT = %b, EXP_IMMEDIATE_SELECT = %b", PROD_IMMEDIATE_SELECT, EXP_IMMEDIATE_SELECT);
            fails = fails + 1;
        end

        if (PROD_OPERAND1_SELECT !== EXP_OPERAND1_SELECT)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_OPERAND1_SELECT = %b, EXP_OPERAND1_SELECT = %b", PROD_OPERAND1_SELECT, EXP_OPERAND1_SELECT);
            fails = fails + 1;
        end

        if (PROD_OPERAND2_SELECT !== EXP_OPERAND2_SELECT)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_OPERAND2_SELECT = %b, EXP_OPERAND2_SELECT = %b", PROD_OPERAND2_SELECT, EXP_OPERAND2_SELECT);
            fails = fails + 1;
        end

        if (PROD_WRITEBACK_VALUE_SELECT !== EXP_WRITEBACK_VALUE_SELECT)
        begin
            $display("\t\033[1;31m[FAILED]\033[0m PROD_WRITEBACK_VALUE_SELECT = %b, EXP_WRITEBACK_VALUE_SELECT = %b", PROD_WRITEBACK_VALUE_SELECT, EXP_WRITEBACK_VALUE_SELECT);
            fails = fails + 1;
        end

        // Check if testcase passed
        if (fails === 0) 
            pass_count = pass_count + 1;
    end
    endtask
    
endmodule
