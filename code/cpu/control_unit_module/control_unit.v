`timescale 1ns/100ps

module control_unit(INSTRUCTION, alu_signal, reg_file_write, main_mem_write, 
    branch_control, immediate_select, operand_1_select, operand_2_select, 
    reg_write_select,RESET);

    input [31:0] INSTRUCTION;
    input RESET;


    //output control signals
    output wire reg_file_write, operand_1_select, operand_2_select;
    output wire [5:0] alu_signal;
    output wire [2:0] main_mem_write;
    output wire [3:0] main_mem_read;
    output wire [3:0] branch_control, immediate_select;
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
    assign #3 funct3_mux_select = 
    (opcode == 7'b0010111) |    // AUIPC
    (opcode == 7'b1101111) |    // JAL
    (opcode == 7'b0100011) |    // STORE
    (opcode == 7'b0000011) |    // LOAD
    (opcode == 7'b1100011) ;    // BRANCH
    // Added
    // 7'b0101111
    // 7'b0000001
    // 7'b0111111



    mux2to1_3bit funct3_mux (funct3, 3'b000, alu_signal[2:0], funct3_mux_select);

    // FLOAT NOT IMPLEMENTED HERE

    // check for SRAI, SUB, SRA, LUI
    assign #3 alu_signal[4] = 
    ({opcode, funct3, funct7} == {7'b0010011, 3'b101, 7'b0100000})| 
    ({opcode, funct3, funct7} == {7'b0110011, 3'b000, 7'b0100000}) |
    ({opcode, funct3, funct7} == {7'b0110011, 3'b101, 7'b0100000}) | 
    (opcode == 7'b0110111); 
    //({opcode, funct3, funct7} == {7'b0110011, 3'b000, 7'b0100000}); 

    // check if ( MUL_inst  and DIV ) or LUI
    assign #3 alu_signal[3] =
    ({opcode, funct7} == 14'b01100110000001) |
    (opcode == 7'b0110111); 


    
    // =========================== Register file write signal generation ===================
    assign #3 reg_file_write = ~(
        (opcode == 7'b0100011) |
        (opcode == 7'b1100011) |
        (opcode == 7'b0000000)) ;

    // =========================== Main memory write signal generation ===================
    assign #3 main_mem_write[2] = (opcode == 7'b0100011);
    assign #3 main_mem_write[1:0] = funct3[1:0];

    // =========================== Main memory read signal generation ===================
    assign #3 main_mem_read[3] = (opcode == 7'b0000011);
    assign #3 main_mem_read[2:0] = funct3;

    // =========================== Branch control signal generation ===================

    // check if JAL, JALR, B_inst
    assign #3 branch_control[3] = 
    (opcode == 7'b1100111) | // JALR
    (opcode == 7'b1101111) | // JAL
    (opcode == 7'b1100011) ; // BRANCH
    
    // if JAL or JALR = 010 else funct3
    assign #3 branch_control[2:0] = (
        (opcode == 7'b1100111) || (opcode == 7'b1101111))? 3'b010 : funct3;



    // =========================== Immediate select signal generation ===================

    // What is opcode == 7'b0000011 ???? --> MAIN MEMORY READ 

    // if unsigned == 1 
    assign #3 immediate_select[3] = 
    ({opcode, funct3} == {7'b0000011, 3'b100}) | // LBU
    ({opcode, funct3} == {7'b0000011, 3'b101}) | // LHU
    ({opcode, funct3} == {7'b0010011, 3'b011}) | // ??
    ({opcode, funct3 , funct7} == {7'b0110011, 3'b011, 7'b0000000}) | // SLTU
    ({opcode, funct3 , funct7} == {7'b0110011, 3'b010, 7'b0000001}) | // MULHSU
    ({opcode, funct3 , funct7} == {7'b0110011, 3'b011, 7'b0000001}) | // MULHU
    ({opcode, funct3 , funct7} == {7'b0110011, 3'b111, 7'b0000001});  // REMU

    assign #3 immediate_select[2:0] =
    (opcode == 7'b0000011) ? 3'b010 :   // LH, LB, LW, LBU, LHU 
    (opcode == 7'b0111111) ? 3'b010 : 
    (opcode == 7'b0010111) ? 3'b000 :   // AUIPC
    (opcode == 7'b0100011) ? 3'b100 :   // SB 
    (opcode == 7'b0101111) ? 3'b100 :
    (opcode == 7'b0110111) ? 3'b000 :   // LUI 
    (opcode == 7'b1101111) ? 3'b001 :   // JAL 
    (opcode == 7'b1100111) ? 3'b010 :   // JALR 
    (opcode == 7'b1100011) ? 3'b011 :   // Branch Inst 
    ({opcode, funct3} == {7'b0010011, 3'bx01}) ? 3'b101: // SLLI....
    (opcode == 7'b0010011) ? 3'b010: 3'bxxx;

// ========================== operand 1 and 2 signal generation =====================
// if AUIPC, JAL , JALR
// assign #3 operand_1_select =
//     (opcode == 7'b0010111) |
//     (opcode == 7'b1101111) |
//     (opcode == 7'b1100111) |
//     (opcode == 7'b1100011) ;

// if AUIPC, JAL
assign #3 operand_1_select =
    (opcode == 7'b0010111) |
    (opcode == 7'b1101111) |
    (opcode == 7'b1100111) ;

// NOTE: don't care conditions not tested 
assign #3 operand_2_select =
    (opcode == 7'b0000011) |    // all LOAD_inst 
    (opcode == 7'b0010011) |    // immediate_inst
    (opcode == 7'b0010111) |    // AUIPC
    (opcode == 7'b0100011) |    // STORE_inst
    (opcode == 7'b0110111) |    //LUI
    (opcode == 7'b1100111) |    //JALR
    (opcode == 7'b1101111) |    // JAL
    (opcode == 7'b1100011) ;    // BRANCH_inst
    
// ================================== Register file write mux select signal generation================
assign #3 reg_write_select[0] = ~((opcode == 7'b0000011) | (opcode == 7'b0111111));
assign #3 reg_write_select[1] = 
    (opcode == 7'b0010111) | 
    (opcode == 7'b1101111) |
    (opcode == 7'b1100111);

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