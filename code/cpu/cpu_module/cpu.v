`timescale 1ns/100ps

`include "../alu_module/alu.v"
`include "../reg_file_module/reg_file.v"

`include "../supported_modules/mux2to1_3bit.v"
`include "../supported_modules/mux4to1_32bit.v"
`include "../supported_modules/mux2to1_32bit.v"

`include "../immediate_select_module/immediate_select.v"
`include "../control_unit_module/control_unit.v"
`include "../branch_select_module/branch_select.v"
`include "../hazard_detection_module/hazard_detection_unit.v"

`include "../forward_unit_modules/stage3_forward_unit.v"
`include "../forward_unit_modules/stage4_forward_unit.v"

// Haven't included debug outputs yet
// Haven't included interrupt signal 

// TODO : write testbench 
module cpu(PC, INSTRUCTION, CLK, RESET, memReadEn, memWriteEn, DATA_CACHE_ADDR, DATA_CACHE_DATA, DATA_CACHE_READ_DATA, DATA_CACHE_BUSY_WAIT, 
    insReadEn, INS_CACHE_BUSY_WAIT);

    input [31:0] INSTRUCTION;           // fetched INSTRUCTIONS
    input CLK, RESET;                  // clock and reset for the cpu
    input DATA_CACHE_BUSY_WAIT;         // busy wait signal from the memory
    input INS_CACHE_BUSY_WAIT;          // busy wait from the instruction memory 
    input [31:0] DATA_CACHE_READ_DATA;     // input from the memory read
    output reg [31:0] PC;               // programme counter
    output [3:0] memReadEn;             // control signal to the data memory 
    output [2:0] memWriteEn;            // control signal to the data memory 
    output reg insReadEn;               // read enable for the instruction read
    output [31:0] DATA_CACHE_ADDR, DATA_CACHE_DATA;  // output signal to memory 

    wire FLUSH;

    //================= STAGE 1 ==========================

    //data lines
    reg [31:0] PR_INSTRUCTION, PR_PC_S1;

    // structure
    wire [31:0] PC_NEXT, PC_NEXT_FINAL, PC_NEXT_REGFILE;
    //wire INTERUPT_PC_REG_EN;

    //additional registers
    reg [31:0] PC_PLUS_4;

    // Select between PC+4 and branch target calculated by ALU
    mux2to1_32bit muxjump(PC_PLUS_4, ALU_OUT, PC_NEXT, BRANCH_SELECT_OUT);

    // Do not update PC if load-use hazard is detected
    mux2to1_32bit muxhazard(PC_NEXT, PC, PC_NEXT_FINAL, LOAD_USE_HAZARD);
   
    // interrupt control unit
    // TODO;

    always @(posedge CLK)
    begin   
        PC_PLUS_4 = PC + 4;
    end 

    //================= STAGE 2 ==========================
    // data lines
    reg[31:0] PR_PC_S2, PR_DATA_1_S2, PR_DATA_2_S2, PR_IMMEDIATE_OUT;
    reg[4:0] PR_REGISTER_WRITE_ADDR_S2;

    // for the forwarding unit
    reg [4:0] REG_READ_ADDR1_S2, REG_READ_ADDR2_S2;

    // control lines
    reg [3:0] PR_BRANCH_SELECT_S2, PR_MEM_READ_S2;
    reg [5:0] PR_ALU_SELECT;
    reg PR_OPERAND1_SEL, PR_OPERAND2_SEL;
    reg [2:0] PR_MEM_WRITE_S2;
    reg [1:0] PR_REG_WRITE_SELECT_S2;
    reg PR_REG_WRITE_EN_S2;

    // hazard detection
    wire LOAD_USE_HAZARD;

    // structure
    wire [31:0] DATA1_S2, DATA2_S2, IMMEDIATE_OUT_S2;
    wire [2:0] IMMEDIATE_SELECT;
    wire [3:0] BRANCH_SELECT, MEM_READ_S2;
    wire [5:0] ALU_SELECT; 
    wire OPERAND1_SEL, OPERAND2_SEL;

    wire [2:0] MEM_WRITE_S2;
    wire [1:0] REG_WRITE_SELECT_S2;
    wire REG_WRITE_EN_S2;

    // random number generator module

    // units 
    // TODO : WRITE_DATA, WRITE_ADDR, WRITE_EN

    reg_file myreg (REG_WRITE_DATA,
                    DATA1_S2,
                    DATA2_S2,
                    PR_REGISTER_WRITE_ADDR_S4,
                    PR_INSTRUCTION[19:15],
                    PR_INSTRUCTION[24:20],
                    PR_REG_WRITE_EN_S4,
                    CLK,
                    RESET);

    immediate_select myImmediate (PR_INSTRUCTION, IMMEDIATE_SELECT, IMMEDIATE_OUT_S2);

    control_unit myControl (PR_INSTRUCTION,
                            ALU_SELECT,
                            REG_WRITE_EN_S2,
                            MEM_WRITE_S2,
                            MEM_READ_S2,
                            BRANCH_SELECT,
                            IMMEDIATE_SELECT,
                            OPERAND1_SEL,
                            OPERAND2_SEL,
                            REG_WRITE_SELECT_S2,
                            RESET);

    hazard_detection_unit myHazardDetectionUnit (PR_INSTRUCTION[19:15],     // rs1
                                                 PR_INSTRUCTION[24:20],     // rs2
                                                 PR_REGISTER_WRITE_ADDR_S2,     
                                                 MEM_READ_S2[3],
                                                 LOAD_USE_HAZARD);

//================= STAGE 3 ==========================

    reg [31:0] PR_PC_S3, PR_ALU_OUT_S3, PR_DATA_2_S3;
    reg [4:0] PR_REGISTER_WRITE_ADDR_S3;
    reg [4:0] REG_READ_ADDR2_S3;    // For the stage 4 forwarding unit 

    // Control lines
    reg [3:0] PR_MEM_READ_S3;
    reg [2:0] PR_MEM_WRITE_S3;
    reg [1:0] PR_REG_WRITE_SELECT_S3;
    reg PR_REG_WRITE_EN_S3;

    // ALU wires
    wire [31:0] ALU_IN_1, ALU_IN_2;
    wire [31:0] ALU_OUT;
    wire BRANCH_SELECT_OUT; 

    // Hazard MUX wires
    wire [31:0] OP1_HAZ_MUX_OUT, OP2_HAZ_MUX_OUT;
    wire [1:0] OP1_HAZ_MUX_SEL, OP2_HAZ_MUX_SEL;

    // Pipeline flushing signal on branch (TODO: Extract this logic out to a separate pipeline flush module)
    assign FLUSH = BRANCH_SELECT_OUT;

    // NOTE Check the temp  wires something is up here
    mux4to1_32bit operand1_mux_haz(PR_DATA_1_S2, PR_ALU_OUT_S3, REG_WRITE_DATA, 32'b0, OP1_HAZ_MUX_OUT, OP1_HAZ_MUX_SEL);
    mux4to1_32bit operand2_mux_haz(PR_DATA_2_S2, PR_ALU_OUT_S3, REG_WRITE_DATA, 32'b0, OP2_HAZ_MUX_OUT, OP2_HAZ_MUX_SEL);

    mux2to1_32bit operand1_mux(OP1_HAZ_MUX_OUT, PR_PC_S2, ALU_IN_1, PR_OPERAND1_SEL);
    mux2to1_32bit operand2_mux(OP2_HAZ_MUX_OUT, PR_IMMEDIATE_OUT, ALU_IN_2, PR_OPERAND2_SEL);

    alu myAlu(ALU_IN_1, ALU_IN_2, ALU_OUT, PR_ALU_SELECT);
    branch_select myBranchSelect(OP1_HAZ_MUX_OUT, OP2_HAZ_MUX_OUT, PR_BRANCH_SELECT_S2, BRANCH_SELECT_OUT);

    // Forwarding unit in stage 3
    stage3_forward_unit myStage3Forwarding(
        PR_MEM_WRITE_S2[2],
        REG_READ_ADDR1_S2, 
        REG_READ_ADDR2_S2,
        PR_OPERAND1_SEL,
        PR_OPERAND2_SEL,
        PR_REGISTER_WRITE_ADDR_S3,
        PR_REG_WRITE_EN_S3,
        PR_REGISTER_WRITE_ADDR_S4,
        PR_REG_WRITE_EN_S4,
        OP1_HAZ_MUX_SEL,
        OP2_HAZ_MUX_SEL
    );

//================= STAGE 4 ==========================
    // Data lines
    reg [31:0] PR_PC_S4, PR_ALU_OUT_S4, PR_DATA_CACHE_OUT;
    reg [4:0] PR_REGISTER_WRITE_ADDR_S4;

    // Control lines
    reg [1:0] PR_REG_WRITE_SELECT_S4;
    reg PR_REG_WRITE_EN_S4;
    reg [3:0] PR_MEM_READ_S4;


    // Additional wires
    wire [31:0] PC_PLUS_4_2;
    wire HAZ_MUX_SEL;
    wire [31:0] HAZ_MUX_OUT;

    // Connections to data memory
    assign DATA_CACHE_DATA = HAZ_MUX_OUT;
    assign DATA_CACHE_ADDR = PR_ALU_OUT_S3;
    assign memWriteEn = PR_MEM_WRITE_S3;
    assign  memReadEn = PR_MEM_READ_S3;

    stage4_forward_unit stage4_forward_unit(
        REG_READ_ADDR2_S3,
        PR_REGISTER_WRITE_ADDR_S4,
        PR_MEM_WRITE_S3[2],
        PR_MEM_READ_S4[3],
        HAZ_MUX_SEL
    );

    mux2to1_32bit stage4_forward_unit_mux(PR_DATA_2_S3, PR_DATA_CACHE_OUT, HAZ_MUX_OUT, HAZ_MUX_SEL);

    //================= STAGE 5 ==========================
    // additional wires
    wire [31:0] REG_WRITE_DATA;

    // MUX to control writeback value to the register file
    mux4to1_32bit regWriteSelMUX (PR_PC_S4, PR_DATA_CACHE_OUT, PR_ALU_OUT_S4, 32'b0, REG_WRITE_DATA, PR_REG_WRITE_SELECT_S4);


    // register updating section 
    always @ (posedge CLK) begin
        if (RESET == 1'b1)
        begin
            // Reset all pipeline registers
            PR_INSTRUCTION = 32'b0;
            PR_PC_S1 = 32'b0;

            PR_PC_S2 = 32'b0;
            PR_DATA_1_S2 = 32'b0;
            PR_DATA_2_S2 = 32'b0;
            PR_IMMEDIATE_OUT = 32'b0;

            PR_REGISTER_WRITE_ADDR_S2 = 5'b0;
            PR_BRANCH_SELECT_S2 = 4'b0;
            PR_MEM_READ_S2 = 4'b0;
            PR_ALU_SELECT = 5'b0;
            PR_OPERAND1_SEL = 1'b0;
            PR_OPERAND2_SEL = 1'b0;
            PR_MEM_WRITE_S2 = 3'b0;
            PR_REG_WRITE_SELECT_S2 = 2'b0;
            PR_REG_WRITE_EN_S2 = 1'b0;

            PR_PC_S3 = 32'b0;
            PR_ALU_OUT_S3 = 32'b0;
            PR_DATA_2_S3 = 32'b0;
            PR_REGISTER_WRITE_ADDR_S3 = 5'b0;
            PR_MEM_READ_S3 = 4'b0;
            PR_MEM_WRITE_S3 = 3'b0;
            PR_REG_WRITE_SELECT_S3 = 2'b0;
            PR_REG_WRITE_EN_S3 = 1'b0;

            PR_PC_S4 = 32'b0;
            PR_ALU_OUT_S4 = 32'b0;
            PR_DATA_CACHE_OUT = 32'b0;
            PR_REGISTER_WRITE_ADDR_S4 = 5'b0;
            PR_REG_WRITE_SELECT_S4 = 2'b0;
            PR_REG_WRITE_EN_S4 = 1'b0;
        end
        else if (!(DATA_CACHE_BUSY_WAIT || INS_CACHE_BUSY_WAIT)) 
        begin
            #1
            if (FLUSH)
            begin
                #0.001

                // *************************** STAGE 4 *****************************************
                PR_REGISTER_WRITE_ADDR_S4 = PR_REGISTER_WRITE_ADDR_S3;
                PR_PC_S4 = PR_PC_S3;
                PR_ALU_OUT_S4 = PR_ALU_OUT_S3;
                PR_DATA_CACHE_OUT = DATA_CACHE_READ_DATA;

                PR_REG_WRITE_SELECT_S4 = PR_REG_WRITE_SELECT_S3;
                PR_REG_WRITE_EN_S4 = PR_REG_WRITE_EN_S3;
                PR_MEM_READ_S4 = PR_MEM_READ_S3;

                // ****************************** STAGE 3 ************************************

                #0.001
                PR_REGISTER_WRITE_ADDR_S3 = PR_REGISTER_WRITE_ADDR_S2;
                PR_PC_S3 = PR_PC_S2;
                PR_ALU_OUT_S3 = OP2_HAZ_MUX_OUT;
                REG_READ_ADDR2_S3 = REG_READ_ADDR2_S2;

                PR_MEM_READ_S3 = PR_MEM_READ_S2;
                PR_MEM_WRITE_S3 = PR_MEM_WRITE_S2;
                PR_REG_WRITE_SELECT_S3 = PR_REG_WRITE_SELECT_S2;
                PR_REG_WRITE_EN_S3 = PR_REG_WRITE_EN_S2;


                // ****************************** STAGE 2 ************************************
                #0.001
                PR_REGISTER_WRITE_ADDR_S2 = PR_INSTRUCTION[11:7]; // Check the 11:7 value
                PR_PC_S2 = PR_PC_S1;
                PR_DATA_1_S2 = DATA1_S2;
                PR_DATA_2_S2 = DATA2_S2;
                PR_IMMEDIATE_OUT = IMMEDIATE_OUT_S2;
                REG_READ_ADDR1_S2 = PR_INSTRUCTION[19:15];
                REG_READ_ADDR2_S2 = PR_INSTRUCTION[24:20];

                // Pipeline flushes are implemented by letting the instruction go forward
                // but modifying the control signals so that it does not make any permanent changes
                PR_BRANCH_SELECT_S2 = 4'b0000;  // Prevent branches/jumps
                PR_ALU_SELECT = ALU_SELECT;
                PR_OPERAND1_SEL = OPERAND1_SEL;
                PR_OPERAND2_SEL = OPERAND2_SEL;
                PR_MEM_READ_S2 = 4'b0000;       // Do not read from memory (Prevent reg file modifications)
                PR_MEM_WRITE_S2 = 3'b000;       // Prevent memory writes
                PR_REG_WRITE_SELECT_S2 = REG_WRITE_SELECT_S2;
                PR_REG_WRITE_EN_S2 = 1'b0;      // Prevent reg file writes


                // ******************************** STAGE 1 ******************************
                #0.001
                PR_INSTRUCTION = 32'b0;
                PR_PC_S1 = PC; // PC_PLUS_4;
            end
            else
            begin
                #0.001
                // *********************** STAGE 4 *************************************
                PR_REGISTER_WRITE_ADDR_S4 = PR_REGISTER_WRITE_ADDR_S3;
                PR_PC_S4 = PR_PC_S3;
                PR_ALU_OUT_S4 = PR_ALU_OUT_S3;
                PR_DATA_CACHE_OUT = DATA_CACHE_READ_DATA;

                PR_REG_WRITE_SELECT_S4 = PR_REG_WRITE_SELECT_S3;
                PR_REG_WRITE_EN_S4 = PR_REG_WRITE_EN_S3;
                PR_MEM_READ_S4 = PR_MEM_READ_S3;

                // ************************** STAGE 3 ************************************
                #0.001
                PR_REGISTER_WRITE_ADDR_S3 = PR_REGISTER_WRITE_ADDR_S2;
                PR_PC_S3 = PR_PC_S2;
                PR_ALU_OUT_S3 = ALU_OUT;
                PR_DATA_2_S3 = OP2_HAZ_MUX_OUT;
                REG_READ_ADDR2_S3 = REG_READ_ADDR2_S2;

                PR_MEM_READ_S3 = PR_MEM_READ_S2;
                PR_MEM_WRITE_S3 = PR_MEM_WRITE_S2;
                PR_REG_WRITE_SELECT_S3 = PR_REG_WRITE_SELECT_S2;
                PR_REG_WRITE_EN_S3 = PR_REG_WRITE_EN_S2;

                // ************************ STAGE 2 *****************************************
                #0.001
                PR_REGISTER_WRITE_ADDR_S2 = PR_INSTRUCTION[11:7]; // check 11:7 
                PR_PC_S2 = PR_PC_S1;
                PR_DATA_1_S2 = DATA1_S2;
                PR_DATA_2_S2 = DATA2_S2;
                PR_IMMEDIATE_OUT = IMMEDIATE_OUT_S2;
                REG_READ_ADDR1_S2 = PR_INSTRUCTION[19:15];
                REG_READ_ADDR2_S2 = PR_INSTRUCTION[24:20];

                PR_ALU_SELECT = ALU_SELECT;
                PR_OPERAND1_SEL = OPERAND1_SEL;
                PR_OPERAND2_SEL = OPERAND2_SEL;
                PR_REG_WRITE_SELECT_S2 = REG_WRITE_SELECT_S2;

                // In case of load-use hazard, let the instruction go 
                // without committing any permanent changes
                if (LOAD_USE_HAZARD)
                begin
                    PR_BRANCH_SELECT_S2 = 4'b0000;  // Disable branches/jumps
                    PR_MEM_READ_S2 = 4'b0000;       // Disable writes from memory to reg file
                    PR_MEM_WRITE_S2 = 3'b000;       // Prevent memory writes
                    PR_REG_WRITE_EN_S2 = 1'b0;      // Prevent reg file writes
                end
                else
                begin
                    PR_BRANCH_SELECT_S2 = BRANCH_SELECT;
                    PR_MEM_READ_S2 = MEM_READ_S2;
                    PR_MEM_WRITE_S2 = MEM_WRITE_S2;
                    PR_REG_WRITE_EN_S2 = REG_WRITE_EN_S2;
                end

                // *************************** STAGE 1 *******************************
                #0.001
                if (!LOAD_USE_HAZARD)   // Do not update S1 PR if a load-use hazard is detected
                begin
                    PR_INSTRUCTION = INSTRUCTION;
                    PR_PC_S1 = PC; // PC_PLUS_4
                end
            end
        end
    end


    // PC update with clock edge
    always @ (posedge CLK)
    begin
        if (RESET == 1'b1)
        begin
            PC = -4;            // Reset the pc counter         // WHY -4 ?
            insReadEn = 1'b0;   // Disable the read enable signal of the instruction memory
        end
        else
        begin
            insReadEn = 1'b0;
            #1
            if(!(DATA_CACHE_BUSY_WAIT || INS_CACHE_BUSY_WAIT))
            begin
                PC = PC_NEXT_FINAL;       // Increment the pc
                insReadEn = 1'b1;   // Enable read from the instruction memory
            end
        end
    end


endmodule
