`timescale 1ns/100ps

/* Handles data hazards that occur when register data needed as operands 
   for the ALU in the EX stage have pending commits in the MEM/WB stages
*/
module ex_forward_unit (
    ADDR1, ADDR2, ADDR3, EX_REG_TYPE,
    MEM_ADDR, MEM_WRITE_EN, MEM_F_WRITE_EN,
    WB_ADDR, WB_WRITE_EN, WB_F_WRITE_EN,
    OP1_FWD_SEL, OP2_FWD_SEL, OP3_FWD_SEL
);

    input MEM_WRITE_EN, MEM_F_WRITE_EN, WB_WRITE_EN, WB_F_WRITE_EN;
    input [1:0] EX_REG_TYPE;
    input [4:0] ADDR1, ADDR2, ADDR3, MEM_ADDR, WB_ADDR;
    output reg [1:0] OP1_FWD_SEL, OP2_FWD_SEL, OP3_FWD_SEL;

    /* If the preceding instruction writes to the int reg file, compare address only if address in EX is int as well.
       If it writes to the float reg file, compare only if address in EX is float as well. */
    always @ (*)
    begin
        // Forwarding for OP1
        if (((MEM_WRITE_EN && !EX_REG_TYPE[1]) || (MEM_F_WRITE_EN && EX_REG_TYPE[1])) && MEM_ADDR === ADDR1)
            OP1_FWD_SEL = 2'b01;    // Activate forwarding from MEM stage
        else if (((WB_WRITE_EN && !EX_REG_TYPE[1]) || (WB_F_WRITE_EN && EX_REG_TYPE[1])) && WB_ADDR === ADDR1)
            OP1_FWD_SEL = 2'b10;    // Activate forwarding from WB stage
        else
            OP1_FWD_SEL = 2'b00;    // No forwarding


        // Forwarding for OP2
        if (((MEM_WRITE_EN && EX_REG_TYPE == 2'b00) || (MEM_F_WRITE_EN && EX_REG_TYPE != 2'b00)) && MEM_ADDR === ADDR2)
            OP2_FWD_SEL = 2'b01;    // Activate forwarding from MEM stage
        else if (((WB_WRITE_EN && EX_REG_TYPE == 2'b00) || (WB_F_WRITE_EN && EX_REG_TYPE != 2'b00)) && WB_ADDR === ADDR2)
            OP2_FWD_SEL = 2'b10;    // Activate forwarding from WB stage
        else
            OP2_FWD_SEL = 2'b00;    // No forwarding

        // Forwarding for OP3
        if ((MEM_F_WRITE_EN && EX_REG_TYPE == 2'b11) && MEM_ADDR === ADDR3)
            OP2_FWD_SEL = 2'b01;    // Activate forwarding from MEM stage
        else if ((WB_F_WRITE_EN && EX_REG_TYPE == 2'b11) && WB_ADDR === ADDR3)
            OP2_FWD_SEL = 2'b10;    // Activate forwarding from WB stage
        else
            OP2_FWD_SEL = 2'b00;    // No forwarding

    end
    
endmodule