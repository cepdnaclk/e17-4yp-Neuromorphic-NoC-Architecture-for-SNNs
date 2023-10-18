`include "alu/alu.v"
`include "fpu/fpu.v"
`include "reg_file/reg_file.v"
`include "f_reg_file/f_reg_file.v"

`include "immediate_generation_unit/immediate_generation_unit.v"
`include "control_unit/control_unit.v"
`include "branch_control_unit/branch_control_unit.v"

`include "forwarding_units/ex_forward_unit.v"
`include "forwarding_units/mem_forward_unit.v"
`include "hazard_detection_unit/hazard_detection_unit.v"
`include "pipeline_flush_unit/pipeline_flush_unit.v"

`include "pipeline_registers/pr_if_id.v"
`include "pipeline_registers/pr_id_ex.v"
`include "pipeline_registers/pr_ex_mem.v"
`include "pipeline_registers/pr_mem_wb.v"

`include "support_modules/plus_4_adder.v"
`include "support_modules/mux_4to1_32bit.v"
`include "support_modules/mux_2to1_32bit.v"

`timescale 1ns/100ps

module cpu (
    CLK, RESET, PC, INSTRUCTION, DATA_MEM_READ, DATA_MEM_WRITE,
    DATA_MEM_ADDR, DATA_MEM_WRITE_DATA, DATA_MEM_READ_DATA,
    DATA_MEM_BUSYWAIT, INSTR_MEM_BUSYWAIT
);

    input CLK, RESET;                               // Clock and reset pins
    input DATA_MEM_BUSYWAIT, INSTR_MEM_BUSYWAIT;    // Busywait signals
    input [31:0] INSTRUCTION;           // Instruction fetched from instruction memory
    input [31:0] DATA_MEM_READ_DATA;    // Data fetched from data memory

    output [2:0] DATA_MEM_WRITE;    // Write control signal for data memory
    output [3:0] DATA_MEM_READ;     // Read control signal for data memory
    output [31:0] DATA_MEM_ADDR, DATA_MEM_WRITE_DATA;   // Address line and data out to data memory
    output reg [31:0] PC;               // Program Counter

    /******************* Connection wires *******************/
    // IF
    wire [31:0] PC_PLUS_4, PC_SELECT_OUT, PC_NEXT;

    // ID
    wire [31:0] ID_PC, ID_INSTRUCTION, ID_REG_DATA1, ID_REG_DATA2, 
                ID_FREG_DATA1, ID_FREG_DATA2, ID_FREG_DATA3, ID_IMMEDIATE;
    wire [5:0] ID_ALU_SELECT;
    wire [4:0] ID_FPU_SELECT;
    wire [3:0] ID_DATA_MEM_READ, ID_BRANCH_CTRL;
    wire [2:0] ID_DATA_MEM_WRITE, ID_IMMEDIATE_SELECT;
    wire [1:0] ID_WB_VALUE_SELECT, ID_REG_TYPE;
    wire ID_REG_WRITE_EN, ID_FREG_WRITE_EN, ID_OPERAND1_SELECT, ID_OPERAND2_SELECT, ID_DATA_MEM_WRITE_DATA_SELECT,
         ID_LU_HAZ_SIG, ID_PR_IF_ID_RESET, ID_PR_IF_ID_HOLD, ID_PR_ID_EX_RESET;

    // EX
    wire [31:0] EX_PC, EX_IMMEDIATE, EX_REG_DATA1, EX_REG_DATA2,
                EX_FREG_DATA1, EX_FREG_DATA2, EX_FREG_DATA3,
                EX_OP1_FWD_MUX_OUT, EX_OP2_FWD_MUX_OUT, 
                EX_ALU_DATA1, EX_ALU_DATA2, EX_ALU_OUT;
    wire [5:0] EX_ALU_SELECT;
    wire [4:0] EX_FPU_SELECT;
    wire [4:0] EX_REG_WRITE_ADDR, EX_REG_READ_ADDR1, EX_REG_READ_ADDR2, EX_REG_READ_ADDR3;
    wire [3:0] EX_DATA_MEM_READ, EX_BRANCH_CTRL;
    wire [2:0] EX_DATA_MEM_WRITE;
    wire [1:0] EX_OP1_FWD_SEL, EX_OP2_FWD_SEL, EX_OP3_FWD_SEL, EX_WB_VALUE_SELECT, EX_REG_TYPE;
    wire EX_REG_WRITE_EN, EX_FREG_WRITE_EN, EX_OPERAND1_SELECT, EX_OPERAND2_SELECT, 
         EX_DATA_MEM_WRITE_DATA_SELECT, EX_BJ_SIG;

    // MEM
    wire [31:0] MEM_PC, MEM_PC_PLUS_4, MEM_ALU_OUT, MEM_FPU_OUT, 
                MEM_REG_DATA2, MEM_FREG_DATA2, MEM_WRITE_DATA;
    wire [4:0] MEM_REG_WRITE_ADDR, MEM_REG_READ_ADDR2;
    wire [3:0] MEM_DATA_MEM_READ;
    wire [2:0] MEM_DATA_MEM_WRITE;
    wire [1:0] MEM_WB_VALUE_SELECT, MEM_REG_TYPE;
    wire MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN, 
         MEM_WRITE_DATA_FWD_SEL, MEM_DATA_MEM_WRITE_DATA_SELECT;

    // WB
    wire [31:0] WB_PC, WB_ALU_OUT, WB_FPU_OUT, WB_DATA_MEM_READ_DATA, WB_WRITEBACK_VALUE;
    wire [4:0] WB_REG_WRITE_ADDR; 
    wire [1:0] WB_WB_VALUE_SELECT;
    wire WB_DATA_MEM_READ, WB_REG_WRITE_EN, WB_FREG_WRITE_EN;


    /****************************************** IF stage ******************************************/
    // Calculate PC+4
    plus_4_adder IF_PC_PLUS_4_ADDER (PC, PC_PLUS_4);  

    // Select between PC and PC+4 (for load-use hazard handling)
    mux_2to1_32bit PC_SELECT_MUX (PC_PLUS_4, PC, PC_SELECT_OUT, ID_LU_HAZ_SIG);

    // Select between PC+4 and branch target
    mux_2to1_32bit BRANCH_SELECT_MUX (PC_SELECT_OUT, EX_ALU_OUT, PC_NEXT, EX_BJ_SIG);


    /****************************************** IF / ID ******************************************/
    pr_if_id PIPE_REG_IF_ID (CLK, (RESET || ID_PR_IF_ID_RESET), ID_PR_IF_ID_HOLD, PC, INSTRUCTION, ID_PC, ID_INSTRUCTION);


    /****************************************** ID stage ******************************************/
    control_unit ID_CONTROL_UNIT (
        ID_INSTRUCTION, ID_ALU_SELECT, ID_REG_WRITE_EN, 
        ID_DATA_MEM_WRITE, ID_DATA_MEM_READ,
        ID_BRANCH_CTRL, ID_IMMEDIATE_SELECT, 
        ID_OPERAND1_SELECT, ID_OPERAND2_SELECT, 
        ID_WB_VALUE_SELECT, ID_REG_TYPE, ID_FREG_WRITE_EN,
        ID_FPU_SELECT, ID_DATA_MEM_WRITE_DATA_SELECT
    );

    reg_file ID_REG_FILE (
        WB_WRITEBACK_VALUE, ID_REG_DATA1, ID_REG_DATA2, 
        WB_REG_WRITE_ADDR, ID_INSTRUCTION[19:15], ID_INSTRUCTION[24:20], 
        WB_REG_WRITE_EN, CLK, RESET
    );

    f_reg_file ID_FREG_FILE (
        WB_WRITEBACK_VALUE, ID_FREG_DATA1, ID_FREG_DATA2, ID_FREG_DATA3,
        WB_REG_WRITE_ADDR, ID_INSTRUCTION[19:15], ID_INSTRUCTION[24:20], ID_INSTRUCTION[31:27],
        WB_FREG_WRITE_EN, CLK, RESET
    );

    immediate_generation_unit ID_IMMEDIATE_GENERATION_UNIT (
        ID_INSTRUCTION, ID_IMMEDIATE_SELECT, ID_IMMEDIATE
    );

    hazard_detection_unit ID_HAZ_DETECT_UNIT (
        ID_INSTRUCTION[19:15], ID_INSTRUCTION[24:20], ID_INSTRUCTION[31:27],
        ID_REG_TYPE, ID_OPERAND1_SELECT, ID_OPERAND2_SELECT,
        EX_REG_WRITE_ADDR, EX_DATA_MEM_READ[3], EX_REG_WRITE_EN, EX_FREG_WRITE_EN,
        ID_LU_HAZ_SIG
    );

    pipeline_flush_unit ID_PR_FLUSH_UNIT (
        EX_BJ_SIG, ID_LU_HAZ_SIG,
        ID_PR_IF_ID_RESET, ID_PR_IF_ID_HOLD, ID_PR_ID_EX_RESET
    );


    /****************************************** ID / EX ******************************************/
    pr_id_ex PIPE_REG_ID_EX (
        CLK, (RESET || ID_PR_ID_EX_RESET),

        ID_PC, ID_REG_DATA1, ID_REG_DATA2, ID_IMMEDIATE,
        ID_FREG_DATA1, ID_FREG_DATA2, ID_FREG_DATA3,
        ID_INSTRUCTION[11:7], ID_INSTRUCTION[19:15], ID_INSTRUCTION[24:20], ID_INSTRUCTION[31:27],
        ID_ALU_SELECT, ID_OPERAND1_SELECT, ID_OPERAND2_SELECT,
        ID_FPU_SELECT, ID_REG_TYPE, ID_REG_WRITE_EN, ID_FREG_WRITE_EN,
        ID_DATA_MEM_WRITE_DATA_SELECT, ID_DATA_MEM_WRITE, ID_DATA_MEM_READ, 
        ID_BRANCH_CTRL, ID_WB_VALUE_SELECT,

        EX_PC, EX_REG_DATA1, EX_REG_DATA2, EX_IMMEDIATE,
        EX_FREG_DATA1, EX_FREG_DATA2, EX_FREG_DATA3,
        EX_REG_WRITE_ADDR, EX_REG_READ_ADDR1, EX_REG_READ_ADDR2, EX_REG_READ_ADDR3,
        EX_ALU_SELECT, EX_OPERAND1_SELECT, EX_OPERAND2_SELECT,
        EX_FPU_SELECT, EX_REG_TYPE, EX_REG_WRITE_EN, EX_FREG_WRITE_EN,
        EX_DATA_MEM_WRITE_DATA_SELECT, EX_DATA_MEM_WRITE, EX_DATA_MEM_READ,
        EX_BRANCH_CTRL, EX_WB_VALUE_SELECT
    );


    /****************************************** EX stage ******************************************/
    // ALU operand forwarding muxes
    mux_4to1_32bit EX_OP1_FWD_MUX (EX_REG_DATA1, MEM_ALU_OUT, WB_WRITEBACK_VALUE, 32'd0, EX_OP1_FWD_MUX_OUT, EX_OP1_FWD_SEL);
    mux_4to1_32bit EX_OP2_FWD_MUX (EX_REG_DATA2, MEM_ALU_OUT, WB_WRITEBACK_VALUE, 32'd0, EX_OP2_FWD_MUX_OUT, EX_OP2_FWD_SEL);

    // ALU operand select muxes
    mux_2to1_32bit EX_OP1_SELECT_MUX (EX_OP1_FWD_MUX_OUT, EX_PC, EX_ALU_DATA1, EX_OPERAND1_SELECT);
    mux_2to1_32bit EX_OP2_SELECT_MUX (EX_OP2_FWD_MUX_OUT, EX_IMMEDIATE, EX_ALU_DATA2, EX_OPERAND2_SELECT);

    // ALU
    alu EX_ALU (EX_ALU_DATA1, EX_ALU_DATA2, EX_ALU_OUT, EX_ALU_SELECT);


    // FPU operand forwarding muxes
    mux_4to1_32bit EX_FOP1_FWD_MUX (EX_FREG_DATA1, MEM_FPU_OUT, WB_WRITEBACK_VALUE, 32'd0, EX_FPU_DATA1, EX_OP1_FWD_SEL);
    mux_4to1_32bit EX_FOP2_FWD_MUX (EX_FREG_DATA2, MEM_FPU_OUT, WB_WRITEBACK_VALUE, 32'd0, EX_FPU_DATA2, EX_OP2_FWD_SEL);
    mux_4to1_32bit EX_FOP3_FWD_MUX (EX_FREG_DATA3, MEM_FPU_OUT, WB_WRITEBACK_VALUE, 32'd0, EX_FPU_DATA3, EX_OP3_FWD_SEL);

    // FPU
    fpu EX_FPU (EX_FPU_DATA1, EX_FPU_DATA2, EX_FPU_DATA3, EX_FPU_OUT, EX_FPU_SELECT);

    // Branch Control Unit
    branch_control_unit EX_BRANCH_CTRL_UNIT (EX_OP1_FWD_MUX_OUT, EX_OP2_FWD_MUX_OUT, EX_BRANCH_CTRL, EX_BJ_SIG);

    // EX Forwarding Unit
    ex_forward_unit EX_FWD_UNIT (
        EX_REG_READ_ADDR1, EX_REG_READ_ADDR2, EX_REG_READ_ADDR3, EX_REG_TYPE, 
        MEM_REG_WRITE_ADDR, MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN,
        WB_REG_WRITE_ADDR, WB_REG_WRITE_EN, WB_FREG_WRITE_EN,
        EX_OP1_FWD_SEL, EX_OP2_FWD_SEL, EX_OP3_FWD_SEL
    );

    /****************************************** EX / MEM ******************************************/
    pr_ex_mem PIPE_REG_EX_MEM (
        CLK, RESET, 

        EX_PC, EX_ALU_OUT, EX_OP2_FWD_MUX_OUT, EX_FPU_DATA2, EX_FPU_OUT,
        EX_REG_WRITE_ADDR, EX_REG_READ_ADDR2, EX_REG_TYPE,
        EX_REG_WRITE_EN, EX_FREG_WRITE_EN, EX_DATA_MEM_WRITE_DATA_SELECT,
        EX_DATA_MEM_WRITE, EX_DATA_MEM_READ, EX_WB_VALUE_SELECT,

        MEM_PC, MEM_ALU_OUT, MEM_REG_DATA2, MEM_FREG_DATA2, MEM_FPU_OUT,
        MEM_REG_WRITE_ADDR, MEM_REG_READ_ADDR2, MEM_REG_TYPE,
        MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN, MEM_DATA_MEM_WRITE_DATA_SELECT,
        MEM_DATA_MEM_WRITE, MEM_DATA_MEM_READ, MEM_WB_VALUE_SELECT
    );

    /****************************************** MEM stage ******************************************/
    // Write data select MUX
    mux_2to1_32bit MEM_WRITE_DATA_SEL_MUX (MEM_REG_DATA2, MEM_FREG_DATA2, MEM_WRITE_DATA, MEM_DATA_MEM_WRITE_DATA_SELECT);
    
    // Write data forwarding MUX
    mux_2to1_32bit MEM_WRITE_DATA_FWD_MUX (MEM_WRITE_DATA, WB_WRITEBACK_VALUE, DATA_MEM_WRITE_DATA, MEM_WRITE_DATA_SEL);

    // Data memory connections
    assign DATA_MEM_WRITE = MEM_DATA_MEM_WRITE;
    assign DATA_MEM_READ = MEM_DATA_MEM_READ;
    assign DATA_MEM_ADDR = MEM_ALU_OUT;

    // PC+4 calculation for JAL/JALR instructions
    plus_4_adder MEM_PC_PLUS_4_ADDER (MEM_PC, MEM_PC_PLUS_4);

    // MEM Forwarding Unit
    mem_forward_unit MEM_FWD_UNIT (
        MEM_REG_READ_ADDR2, MEM_DATA_MEM_WRITE[2], 
        MEM_REG_TYPE, WB_REG_WRITE_EN, WB_FREG_WRITE_EN,
        WB_REG_WRITE_ADDR, WB_DATA_MEM_READ, MEM_WRITE_DATA_FWD_SEL
    );


    /****************************************** MEM / WB ******************************************/
    pr_mem_wb PIPE_REG_MEM_WB (
        CLK, RESET, 

        MEM_PC_PLUS_4, MEM_ALU_OUT, DATA_MEM_READ_DATA, MEM_FPU_OUT,
        MEM_REG_WRITE_ADDR, MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN,
        MEM_DATA_MEM_READ[3], MEM_WB_VALUE_SELECT,

        WB_PC, WB_ALU_OUT, WB_DATA_MEM_READ_DATA, WB_FPU_OUT,
        WB_REG_WRITE_ADDR, WB_REG_WRITE_EN, WB_FREG_WRITE_EN,
        WB_DATA_MEM_READ, WB_WB_VALUE_SELECT
    );

    /****************************************** WB stage ******************************************/
    // 
    mux_4to1_32bit WB_WB_VALUE_SELECT_MUX (WB_PC, WB_DATA_MEM_READ_DATA, WB_ALU_OUT, WB_FPU_OUT, WB_WRITEBACK_VALUE, WB_WB_VALUE_SELECT);


    // PC Update
    always @ (posedge CLK)
    begin
        if (RESET == 1'b1)      // Reset PC to zero if RESET is asserted
            PC = 32'b0;
        else if (!INSTR_MEM_BUSYWAIT || !DATA_MEM_BUSYWAIT)     // Stall PC if BUSYWAIT is asserted
            PC = PC_NEXT;
    end

endmodule