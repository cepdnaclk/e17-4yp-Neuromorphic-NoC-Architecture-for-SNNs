`timescale 1ns/100ps

/* Detects the existence of a load-use data hazard (Hazards
   that occur when a LOAD instruction is followed by an instruction
   that uses the loaded value). This unit asserts the LU_HAZ_SIG line
   when a hazard is detected so that a NOP bubble can be added.
*/
module hazard_detection_unit (
    ID_ADDR1, ID_ADDR2,
    ID_OPERAND1_SELECT, ID_OPERAND2_SELECT,
    EX_REG_WRITE_ADDR, EX_DATA_MEM_READ,
    LU_HAZ_SIG
);
    
    input [4:0] ID_ADDR1, ID_ADDR2, EX_REG_WRITE_ADDR;
    input ID_OPERAND1_SELECT, ID_OPERAND2_SELECT, EX_DATA_MEM_READ;
    output reg LU_HAZ_SIG;

    always @ (*)
    begin
        if (EX_DATA_MEM_READ && (       // Instruction in EX stage must be a memory read
            (!ID_OPERAND1_SELECT && (ID_ADDR1 === EX_REG_WRITE_ADDR)) ||    // Check if instruction in ID uses loaded value as OP1
            (!ID_OPERAND2_SELECT && (ID_ADDR2 === EX_REG_WRITE_ADDR))       // Check if instruction in ID uses loaded value as OP2
        ))
            LU_HAZ_SIG = 1'b1;
        else
            LU_HAZ_SIG = 1'b0;
    end

endmodule