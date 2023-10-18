`timescale 1ns/100ps

/* Detects the existence of a load-use data hazard (Hazards
   that occur when a LOAD instruction is followed by an instruction
   that uses the loaded value). This unit asserts the LU_HAZ_SIG line
   when a hazard is detected so that a NOP bubble can be added.
*/
module hazard_detection_unit (
    ID_ADDR1, ID_ADDR2, ID_ADDR3,
    ID_REG_TYPE, ID_OPERAND1_SELECT, ID_OPERAND2_SELECT,
    EX_REG_WRITE_ADDR, EX_DATA_MEM_READ,
    EX_REG_WRITE_EN, EX_FREG_WRITE_EN,
    LU_HAZ_SIG
);
    
    input [4:0] ID_ADDR1, ID_ADDR2, ID_ADDR3, EX_REG_WRITE_ADDR;
    input [1:0] ID_REG_TYPE;
    input ID_OPERAND1_SELECT, ID_OPERAND2_SELECT, EX_DATA_MEM_READ,
          EX_REG_WRITE_EN, EX_FREG_WRITE_EN;
    output reg LU_HAZ_SIG;

    always @ (*)
    begin
        if (EX_DATA_MEM_READ)
            if (EX_REG_WRITE_EN)    // Load to int reg file
            begin
                if (ID_REG_TYPE == 2'b00)   // ID_ADDR1/ID_ADDR2 are int
                    // Set if instruction in ID uses loaded value as OP1 or OP2
                    LU_HAZ_SIG = (!ID_OPERAND1_SELECT && (ID_ADDR1 === EX_REG_WRITE_ADDR)) ||    
                                 (!ID_OPERAND2_SELECT && (ID_ADDR2 === EX_REG_WRITE_ADDR));

                else if (ID_REG_TYPE == 2'b01)  // ID_ADDR1 is int / ID_ADDR2 is float
                    // Set if instruction in ID uses loaded value as OP1
                    LU_HAZ_SIG = (!ID_OPERAND1_SELECT && (ID_ADDR1 === EX_REG_WRITE_ADDR));    
                else
                    LU_HAZ_SIG = 1'b0;
            end
            else    // Load to float reg file
            begin
                if (ID_REG_TYPE == 2'b10)   // ID_ADDR1/ID_ADDR2 are float
                    // Set if instruction in ID uses loaded value as FOP1 or FOP2
                    LU_HAZ_SIG = (ID_ADDR1 === EX_REG_WRITE_ADDR) || 
                                 (ID_ADDR2 === EX_REG_WRITE_ADDR);  

                else if (ID_REG_TYPE == 2'b11)  // ID_ADDR1/ID_ADDR2/ID_ADDR3 are float
                    // Set if instruction in ID uses loaded value as FOP1, FOP2 or FOP3
                    LU_HAZ_SIG = (ID_ADDR1 === EX_REG_WRITE_ADDR) || 
                                 (ID_ADDR2 === EX_REG_WRITE_ADDR) || 
                                 (ID_ADDR3 === EX_REG_WRITE_ADDR);

                else
                    LU_HAZ_SIG = 1'b0;
            end
    end

endmodule