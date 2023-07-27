`include "support_modules/mux_2to1_3bit.v"
`timescale 1ns/100ps

module control_unit (
    INSTRUCTION, 
    ALU_SELECT, 
    REG_WRITE_EN, 
    DATA_MEM_WRITE, DATA_MEM_READ,
    BRANCH_CTRL, IMMEDIATE_SELECT, 
    OPERAND1_SELECT, OPERAND2_SELECT, 
    WRITEBACK_VALUE_SELECT);

    // Instruction to be decoded
    input [31:0] INSTRUCTION;

    // Output control signals
    output wire REG_WRITE_EN, OPERAND1_SELECT, OPERAND2_SELECT;
    output wire [5:0] ALU_SELECT;
    output wire [3:0] DATA_MEM_READ, BRANCH_CTRL;
    output wire [2:0] DATA_MEM_WRITE, IMMEDIATE_SELECT;
    output wire [1:0] WRITEBACK_VALUE_SELECT;

    // Decoded instruction segments
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7; 

    // Mux connections
    wire funct3_mux_select; 
    wire funct3_mux_out; 


    // Extract the control segments from the instruction
    assign opcode = INSTRUCTION[6:0];
    assign funct3 = INSTRUCTION[14:12];
    assign funct7 = INSTRUCTION[31:25];

    /*************************** ALU control signal generation ***************************/
    // ALU_SELECT should be ADD for these instructions
    assign #3 funct3_mux_select = 
    (opcode == 7'b0010111) |    // AUIPC
    (opcode == 7'b1101111) |    // JAL
    (opcode == 7'b0100011) |    // STORE
    (opcode == 7'b0000011) |    // LOAD
    (opcode == 7'b1100011) ;    // BRANCH
    // Added
    // 7'b0101111       // I AM CONFUSION: What are these? (FIFO custom instructions...?)
    // 7'b0000001
    // 7'b0111111

    // For instructions where ALU_SELECT should be ADD, set ALU_SELECT[2:0] to 3'b000
    // For other instructions ALU_SELECT[2:0] is funct3
    mux_2to1_3bit funct3_mux (funct3, 3'b000, ALU_SELECT[2:0], funct3_mux_select);

    // TODO: FLOAT NOT IMPLEMENTED HERE

    // Check for SRAI, SUB, SRA, LUI
    assign #3 ALU_SELECT[4] = 
    ({opcode, funct3, funct7} == {7'b0010011, 3'b101, 7'b0100000}) |        // SRAI (ALU_SIGNAL -> SRA)
    ({opcode, funct3, funct7} == {7'b0110011, 3'b000, 7'b0100000}) |        // SUB  (ALU_SIGNAL -> SUB)
    ({opcode, funct3, funct7} == {7'b0110011, 3'b101, 7'b0100000}) |        // SRA (ALU_SIGNAL -> SRA)
    (opcode == 7'b0110111);                                                 // LUI (ALU_SIGNAL -> FWD) [U-Immediates anyway have a 12'b0 at the end so no need to shift]

    // Check for RV32M instructions or LUI instruction
    assign #3 ALU_SELECT[3] =
    ({opcode, funct7} == {7'b0110011, 7'b0000001}) |    // RV32M
    (opcode == 7'b0110111);                             // LUI (Because ALU_SIGNAL for LUI is FWD=6'b011xxx)


    
    /*************************** Register file write enable signal generation ***************************/
    // These instructions should not write to the register file.
    // Everything else should.
    assign #3 REG_WRITE_EN = ~(
        (opcode == 7'b0100011) |        // SB, SH, SW
        (opcode == 7'b1100011) |        // BEQ, BNE, BLT, BGE, BLTU, BGEU
        (opcode == 7'b0000000)) ;       // FIFO...? idk


    /*************************** Data memory write signal generation ***************************/
    // DATA_MEM_WRITE[2] enables writing
    // DATA_MEM_WRITE[1:0] determines bit width of written value based on Funct3[1:0]
    assign #3 DATA_MEM_WRITE[2] = (opcode == 7'b0100011);      // S-Type (SB, SH, SW)
    assign #3 DATA_MEM_WRITE[1:0] = funct3[1:0];

    /*************************** Data memory read signal generation ***************************/
    // DATA_MEM_READ[3] enables reading
    // DATA_MEM_READ[2:0] determines bit width and related settings based on Funct3
    assign #3 DATA_MEM_READ[3] = (opcode == 7'b0000011);    // LB, LH, LW, LBU, LHU
    assign #3 DATA_MEM_READ[2:0] = funct3;

    /*************************** Branch control signal generation ***************************/
    // Enable branching for these instructions
    assign #3 BRANCH_CTRL[3] = 
    (opcode == 7'b1100111) | // JALR
    (opcode == 7'b1101111) | // JAL
    (opcode == 7'b1100011) ; // B-Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
    
    // If JAL or JALR, set to 010 for jumping.
    // Else set to funct3 for branch type.
    assign #3 BRANCH_CTRL[2:0] = (
        (opcode == 7'b1100111) || (opcode == 7'b1101111))? 3'b010 : funct3;



    /*************************** Immediate select signal generation ***************************/
    assign #3 IMMEDIATE_SELECT =
    (opcode == 7'b0010111) ? 3'b000 :   // AUIPC
    (opcode == 7'b0110111) ? 3'b000 :   // LUI 
    (opcode == 7'b1101111) ? 3'b001 :   // JAL
    (opcode == 7'b1100111) ? 3'b010 :   // JALR 
    (opcode == 7'b0000011) ? 3'b010 :   // LB, LH, LW, LBU, LHU 
    (opcode == 7'b1100011) ? 3'b011 :   // BEQ, BNE, BLT, BGE, BLTU, BGEU
    (opcode == 7'b0100011) ? 3'b100 :   // SB, SH, SW 

    (opcode == 7'b0111111) ? 3'b010 :   // I AM CONFUSION: WHAT ARE YOU????
    (opcode == 7'b0101111) ? 3'b100 :   // I AM CONFUSION: WHO ARE YOU???

    (opcode == 7'b0010011) ? 3'b010: 3'bxxx;    // All other I-Type instructions (ADDI, SLTI, etc.)

    /*************************** Operand 1 and Operand 2 signal generation ***************************/
    // Set OPERAND1 to PC for these instructions
    assign #3 OPERAND1_SELECT =
        (opcode == 7'b0010111) |    // AUIPC
        (opcode == 7'b1101111) |    // JAL
        (opcode == 7'b1100011);     // BRANCH (BEQ, BNE, BLT, BGE, BLTU, BGEU)


    // NOTE: don't care conditions not tested (I AM CONFUSION: WHAT DOES THIS MEANNN???)
    assign #3 OPERAND2_SELECT =
        (opcode == 7'b0000011) |    // LOAD instructions 
        (opcode == 7'b0010011) |    // I-Type instructions (ADDI, SLTI, etc.)
        (opcode == 7'b0010111) |    // AUIPC
        (opcode == 7'b0100011) |    // STORE instructions
        (opcode == 7'b0110111) |    // LUI
        (opcode == 7'b1100111) |    // JALR
        (opcode == 7'b1101111) |    // JAL
        (opcode == 7'b1100011);     // BRANCH instructions
        
    /*************************** Writeback mux select signal generation ***************************/
    // 00 = PR_PC_S4, 01 = PR_DATA_CACHE_OUT, 10 = PR_ALU_OUT_S4
    assign #3 WRITEBACK_VALUE_SELECT =
        ((opcode == 7'b1101111) | (opcode == 7'b1100111)) ? 2'b00 :   // JAL, JALR
        (opcode == 7'b0000011) ? 2'b01 :        // LOAD
        2'b10;      // Everything else

    

    // FLOAT ALWAYS BLOCK TO IMPLEMENT (I AM CONFUSION: What always block?)



    //I AM CONFUSION: What is this???
    // always @ (*) //if reset set the pc select
    // begin
    //   if (RESET) 
    //     begin
    //         jump = 1'b0;
    //         beq = 1'b0;
    //         bne = 1'b0;
    //     end
    // end


endmodule