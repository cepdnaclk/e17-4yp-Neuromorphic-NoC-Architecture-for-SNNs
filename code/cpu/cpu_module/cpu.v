`timescale 1ns/100ps

`include "../alu_module/alu.v"
`include "../reg_file_module/reg_file.v"

`include "../supported_modules/mux2to1_3bit.v"
`include "../supported_modules/mux4to1_32bit.v"
`include "../supported_modules/mux2to1_32bit.v"

`include "../immediate_select_module/immediate_select.v"
`include "../control_unit_module/control_unit.v"
`include "../branch_select_module/branch_select.v"

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

    //units
    // TODO : ALUOUT and BRANCHSELSECT 
//    mux2tol_32bit muxjump(PC_PLUS_4, ALU_OUT, PC_NEXT, BRANCH_SELECT_OUT);

   // interrupt control unit
   // TODO;

   always @(posedge CLK)
   begin   
        PC_PLUS_4 = PC + 4;
   end 

//================= STAGE 2 ==========================
    // data lines
    reg[31:0] PR_PC_S2, PR_DATA_1_S2, PR_DATA_2_S2, PR_IMMEDIATE_SELECT_OUT;
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

    reg_file myreg (REG_WRITE_DATA,         // THIS *MIGHT* BE WRONG...
                    DATA1_S2,
                    DATA2_S2,
                    PR_REGISTER_WRITE_ADDR_S2,      // THIS IS WRONG!!!
                    PR_INSTRUCTION[19:15],
                    PR_INSTRUCTION[24:20],
                    PR_REG_WRITE_EN_S2,     // THIS *MIGHT* BE WRONG...
                    CLK,
                    RESET);
// s2 or s4 ? 

    immediate_select myImmediate (PR_INSTRUCTION, IMMEDIATE_SELECT, IMMEDIATE_OUT_S2);

    // TODO: Pass the output control signals through a MUX.
    // Need to clear the control signals in case we need to add bubbles.
    control_unit myControl (PR_INSTRUCTION,
                            ALU_SELECT,
                            REG_WRITE_EN_S2,
                            MEM_WRITE_S2,
                            MEM_READ_S2,
                            BRANCH_SELECT,
                            IMMEDIATE_SELECT,   // TODO: Changed this signal from 4-bit to 3-bit. Fix propagation through PRs.
                            OPERAND1_SEL,
                            OPERAND2_SEL,
                            REG_WRITE_SELECT_S2,
                            RESET);

//================= STAGE 3 ==========================

    reg [31:0] PR_PC_S3, PR_ALU_OUT_S3, PR_DATA_2_S3;
    reg [4:0] PR_REGISTER_WRITE_ADDR_S3;
    // for the forwarding unit Stage 4
    reg [4:0] REG_READ_ADDR2_S3;

    //control lines
    reg [3:0] PR_MEM_READ_S3;
    reg [2:0] PR_MEM_WRITE_S3;
    reg [1:0] PR_REG_WRITE_SELECT_S3;
    reg PR_REG_WRITE_EN_S3;

    //structure 
    // additional wires
    wire [31:0] ALU_IN_1, ALU_IN_2;
    wire [31:0] ALU_OUT;
    wire BRANCH_SELECT_OUT; 

    // HAZARDS??
    wire [31:0] OP1_HAZ_MUX_OUT, OP2_HAZ_MUX_OUT;
    wire [1:0] OP1_HAZ_MUX_SEL, OP2_HAZ_MUX_SEL;

    assign FLUSH = BRANCH_SELECT_OUT;
    // NOTE Check the temp  wires somehtings up here
    mux4to1_32bit operand1_mux_haz(PR_DATA_1_S2, PR_ALU_OUT_S3, REG_WRITE_DATA,REG_WRITE_DATA_S5, OP1_HAZ_MUX_OUT, OP1_HAZ_MUX_SEL);
    mux4to1_32bit operand2_mux_haz(PR_DATA_2_S2, PR_ALU_OUT_S3, REG_WRITE_DATA,REG_WRITE_DATA_S5, OP2_HAZ_MUX_OUT, OP2_HAZ_MUX_SEL);

    mux2to1_32bit operand1_mux (OP1_HAZ_MUX_OUT, PR_PC_S2, ALU_IN_1, PR_OPERAND1_SEL);
    mux2to1_32bit operand2_mux (OP2_HAZ_MUX_OUT, PR_IMMEDIATE_SELECT_OUT, ALU_IN_2, PR_OPERAND2_SEL);

    alu myAlu (ALU_IN_1, ALU_IN_2, ALU_OUT, PR_ALU_SELECT);
    branch_select myBranchSelect(OP1_HAZ_MUX_OUT, OP2_HAZ_MUX_OUT, PR_BRANCH_SELECT_S2, BRANCH_SELECT_OUT);

    // forwading unit in stage 3
    stage3_forward_unit myStage3Forwarding (
        PR_MEM_WRITE_S2[2],
        REG_READ_ADDR1_S2, 
        REG_READ_ADDR2_S2,
        PR_OPERAND1_SEL,
        PR_OPERAND2_SEL,
        PR_REGISTER_WRITE_ADDR_S3,
        PR_REG_WRITE_EN_S3,
        PR_REGISTER_WRITE_ADDR_S4,
        PR_REG_WRITE_EN_S4,
        PR_REGISTER_WRITE_ADDR_S5,
        PR_REG_WRITE_EN_S5,
        OP1_HAZ_MUX_SEL,
        OP2_HAZ_MUX_SEL
    );

//================= STAGE 4 ==========================
    // data lines
    reg [31:0] PR_PC_S4, PR_ALU_OUT_S4, PR_DATA_CACHE_OUT;
    reg [4:0] PR_REGISTER_WRITE_ADDR_S4;

    // control lines
    reg [1:0] PR_REG_WRITE_SELECT_S4;
    reg PR_REG_WRITE_EN_S4;
    reg [3:0] PR_MEM_READ_S4;


    // structure 
    // additional wires
    wire [31:0] PC_PLUS_4_2;
    wire HAZ_MUX_SEL;
    wire [31:0] HAZ_MUX_OUT;

    // units
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
    // EXTRA pipeline registers to handle the fowarding 
    // data lines
    reg [31:0] REG_WRITE_DATA_S5;
    reg [4:0] PR_REGISTER_WRITE_ADDR_S5;

    // control lines
    reg PR_REG_WRITE_EN_S5;

    // structure
    // additional wires
    wire [31:0] REG_WRITE_DATA;

    // unit 
    mux4to1_32bit regWriteSelMUX (PR_DATA_CACHE_OUT, PR_ALU_OUT_S4, 32'b0, PR_PC_S4, REG_WRITE_DATA, PR_REG_WRITE_SELECT_S4);

    // connections

    // register updating section 
    always @ (posedge CLK) begin
        #1 // change this if required
        if(!(DATA_CACHE_BUSY_WAIT || INS_CACHE_BUSY_WAIT)) 
        begin
            if (FLUSH)
            begin
                // ********************** STAGE 5 Temporary stage for the forwarding unit ************************
                REG_WRITE_DATA_S5 = REG_WRITE_DATA;
                PR_REGISTER_WRITE_ADDR_S5 = PR_REGISTER_WRITE_ADDR_S4;

                PR_REG_WRITE_EN_S5 = PR_REG_WRITE_EN_S4;

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
                PR_IMMEDIATE_SELECT_OUT = IMMEDIATE_OUT_S2;
                REG_READ_ADDR1_S2 = PR_INSTRUCTION[19:15];
                REG_READ_ADDR2_S2 = PR_INSTRUCTION[24:20];

                PR_BRANCH_SELECT_S2 = BRANCH_SELECT;
                PR_ALU_SELECT = ALU_SELECT;
                PR_OPERAND1_SEL = OPERAND1_SEL;
                PR_OPERAND2_SEL = OPERAND2_SEL;
                PR_MEM_READ_S2 = 4'b0000;
                PR_MEM_WRITE_S2 = 3'b000;
                PR_REG_WRITE_SELECT_S2 = REG_WRITE_SELECT_S2;
                PR_REG_WRITE_EN_S2 = 1'b0;


                // ******************************** STAGE 1 ******************************
                #0.001
                PR_INSTRUCTION = 32'b0;
                PR_PC_S1 = PC; // PC_PLUS_4;

            end
            else
            begin

                // ************************ STAGE 5 Temporary Stage for the forwarding unit *************
                REG_WRITE_DATA_S5 = REG_WRITE_DATA;
                PR_REGISTER_WRITE_ADDR_S5 = PR_REGISTER_WRITE_ADDR_S4;

                PR_REG_WRITE_EN_S5 = PR_REG_WRITE_EN_S4;

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
                PR_IMMEDIATE_SELECT_OUT = IMMEDIATE_OUT_S2;
                REG_READ_ADDR1_S2 = PR_INSTRUCTION[19:15];
                REG_READ_ADDR2_S2 = PR_INSTRUCTION[24:20];

                PR_BRANCH_SELECT_S2 = BRANCH_SELECT;
                PR_ALU_SELECT = ALU_SELECT;
                PR_OPERAND1_SEL = OPERAND1_SEL;
                PR_OPERAND2_SEL = OPERAND2_SEL;
                PR_MEM_READ_S2 = MEM_READ_S2;
                PR_MEM_WRITE_S2 = MEM_WRITE_S2;
                PR_REG_WRITE_SELECT_S2 = REG_WRITE_SELECT_S2;
                PR_REG_WRITE_EN_S2 = REG_WRITE_EN_S2;

                // *************************** STAGE 1 *******************************
                #0.001
                PR_INSTRUCTION = INSTRUCTION;
                PR_PC_S1 = PC; // PC_PLUS_4
            end
        end
    end


    // PC update with clock edge
    always @ (posedge CLK)begin
        if(RESET == 1'b1)
        begin
            PC = -4; // reset the pc counter 
            // clearing the pipeline registers
            PR_INSTRUCTION = 32'b0;
            PR_PC_S1 = 32'b0;

            PR_PC_S2 = 32'b0;
            PR_DATA_1_S2 = 32'b0;
            PR_DATA_2_S2 = 32'b0;
            PR_IMMEDIATE_SELECT_OUT = 32'b0;

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

            insReadEn = 1'b0; // disable the read enable signal of the instruction memory
        end
        else
        begin
            insReadEn = 1'b0;
            #1
            if(!(DATA_CACHE_BUSY_WAIT || INS_CACHE_BUSY_WAIT))
            begin
                PC = PC_NEXT; // increment the pc
                insReadEn = 1'b1; // enable read form the instruction memory
            end
        end
    end


endmodule
