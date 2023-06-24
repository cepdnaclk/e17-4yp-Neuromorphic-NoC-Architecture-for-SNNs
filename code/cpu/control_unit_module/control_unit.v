`timescale 1ns/100ps

module control_unit(INSTRUCTION, alu_signal, reg_file_write_enable, data_mem_write, data_mem_read,
    branch_control, immediate_select, operand_1_select, operand_2_select, 
    reg_write_select, RESET);

    input [31:0] INSTRUCTION;
    input RESET;

    //output control signals
    output wire reg_file_write_enable, operand_1_select, operand_2_select;
    output wire [5:0] alu_signal;
    output wire [2:0] data_mem_write, immediate_select;
    output wire [3:0] data_mem_read;
    output wire [3:0] branch_control;
    output wire [1:0] reg_write_select;

    //decoded instructions
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7; 

    // to select the alu signal between funct3 and predefined 
    // values for JAL & AUIPC
    wire funct3_mux_select; 
    wire funct3_mux_out; 

    assign opcode = INSTRUCTION[6:0];
    assign funct3 = INSTRUCTION[14:12];
    assign funct7 = INSTRUCTION[31:25];

    // =========================== ALU control signal generation ===================
    // ALU_SIGNAL -> ADD for these instructions
    assign #3 funct3_mux_select = 
    (opcode == 7'b0010111) |    // AUIPC
    (opcode == 7'b1101111) |    // JAL
    (opcode == 7'b0100011) |    // STORE
    (opcode == 7'b0000011) |    // LOAD
    (opcode == 7'b1100011) ;    // BRANCH
    // Added
    // 7'b0101111       // What are these? (FIFO custom instructions...?)
    // 7'b0000001
    // 7'b0111111

    // For instructions where ALU_SIGNAL -> ADD, set ALU_SIGNAL[2:0] to 3'b000
    // For other instructions ALU_SIGNAL[2:0] is Funct3
    mux2to1_3bit funct3_mux (funct3, 3'b000, alu_signal[2:0], funct3_mux_select);

    // FLOAT NOT IMPLEMENTED HERE

    // Check for SRAI, SUB, SRA, LUI
    assign #3 alu_signal[4] = 
    ({opcode, funct3, funct7} == {7'b0010011, 3'b101, 7'b0100000}) |        // SRAI (ALU_SIGNAL -> SRA)
    ({opcode, funct3, funct7} == {7'b0110011, 3'b000, 7'b0100000}) |        // SUB  (ALU_SIGNAL -> SUB)
    ({opcode, funct3, funct7} == {7'b0110011, 3'b101, 7'b0100000}) |        // SRA (ALU_SIGNAL -> SRA)
    (opcode == 7'b0110111);                                                 // LUI (ALU_SIGNAL -> FWD) [U-Immediates anyway have a 12'b0 at the end so no need to shift]

    // Check for RV32M instructions or LUI instruction
    assign #3 alu_signal[3] =
    ({opcode, funct7} == {7'b0110011, 7'b0000001}) |    // RV32M
    (opcode == 7'b0110111);                             // LUI (Because ALU_SIGNAL for LUI is FWD=6'b011xxx)


    
    // =========================== Register file write signal generation ===================
    // These instructions should not write to the register file.
    // Everything else should.
    assign #3 reg_file_write_enable = ~(
        (opcode == 7'b0100011) |        // SB, SH, SW
        (opcode == 7'b1100011) |        // BEQ, BNE, BLT, BGE, BLTU, BGEU
        (opcode == 7'b0000000)) ;       // FIFO...? idk


    // =========================== Data memory write signal generation ===================
    // DATA_MEM_WRITE[2] enables writing
    // DATA_MEM_WRITE[1:0] determines bit width of written value based on Funct3[1:0]
    assign #3 data_mem_write[2] = (opcode == 7'b0100011);      // S-Type (SB, SH, SW)
    assign #3 data_mem_write[1:0] = funct3[1:0];

    // =========================== Data memory read signal generation ===================
    // DATA_MEM_READ[3] enables reading
    // DATA_MEM_READ[2:0] determines bit width and related settings based on Funct3
    assign #3 data_mem_read[3] = (opcode == 7'b0000011);    // LB, LH, LW, LBU, LHU
    assign #3 data_mem_read[2:0] = funct3;

    // =========================== Branch control signal generation ===================
    // Enable branching for these instructions
    assign #3 branch_control[3] = 
    (opcode == 7'b1100111) | // JALR
    (opcode == 7'b1101111) | // JAL
    (opcode == 7'b1100011) ; // B-Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
    
    // If JAL or JALR, set to 010 for jumping.
    // Else set to funct3 for branch type.
    assign #3 branch_control[2:0] = (
        (opcode == 7'b1100111) || (opcode == 7'b1101111))? 3'b010 : funct3;



    // =========================== Immediate select signal generation ===================
    assign #3 immediate_select =
    (opcode == 7'b0010111) ? 3'b000 :   // AUIPC
    (opcode == 7'b0110111) ? 3'b000 :   // LUI 
    (opcode == 7'b1101111) ? 3'b001 :   // JAL
    (opcode == 7'b1100111) ? 3'b010 :   // JALR 
    (opcode == 7'b0000011) ? 3'b010 :   // LH, LB, LW, LBU, LHU 
    (opcode == 7'b1100011) ? 3'b011 :   // BEQ, BNE, BLT, BGE, BLTU, BGEU
    (opcode == 7'b0100011) ? 3'b100 :   // SB, SH, SW 

    (opcode == 7'b0111111) ? 3'b010 :   // WHAT ARE YOU????
    (opcode == 7'b0101111) ? 3'b100 :   // WHO ARE YOU???

    (opcode == 7'b0010011) ? 3'b010: 3'bxxx;    // All other I-Type instructions (ADDI, SLTI, etc.)

    // ========================== Operand 1 and Operand 2 signal generation =====================
    // Set OPERAND_1 to PC for these instructions
    assign #3 operand_1_select =
        (opcode == 7'b0010111) |    // AUIPC
        (opcode == 7'b1101111) |    // JAL
        (opcode == 7'b1100111) |    // JALR
        (opcode == 7'b1100011);     // BRANCH (BEQ, BNE, BLT, BGE, BLTU, BGEU)


    // NOTE: don't care conditions not tested (WHAT DOES THIS MEANNN???)
    assign #3 operand_2_select =
        (opcode == 7'b0000011) |    // LOAD instructions 
        (opcode == 7'b0010011) |    // I-Type instructions (ADDI, SLTI, etc.)
        (opcode == 7'b0010111) |    // AUIPC
        (opcode == 7'b0100011) |    // STORE instructions
        (opcode == 7'b0110111) |    // LUI
        (opcode == 7'b1100111) |    // JALR
        (opcode == 7'b1101111) |    // JAL
        (opcode == 7'b1100011);    // BRANCH instructions
        
    // ================================== Register file write mux select signal generation================
    // 00 = PR_PC_S4, 01 = PR_DATA_CACHE_OUT, 10 = PR_ALU_OUT_S4
    assign #3 reg_write_select =
        ((opcode == 7'b1101111) | (opcode == 7'b1100111)) ? 2'b00 :   // JAL, JALR
        (opcode == 7'b0000011) ? 2'b01 :        // LOAD
        2'b10;      // Everything else

    

    // FLOAT ALWAYS BLOCK TO IMPLEMENT




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