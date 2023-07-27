`timescale 1ns/100ps

/* Handles data hazards that occur when register data needed as operands 
   for the ALU in the EX stage have pending commits in the MEM/WB stages
*/
module ex_forward_unit (
    ADDR1, ADDR2, 
    MEM_ADDR, MEM_WRITE_EN, 
    WB_ADDR, WB_WRITE_EN, 
    OP1_FWD_SEL, OP2_FWD_SEL
);

    input MEM_WRITE_EN, WB_WRITE_EN;
    input [4:0] ADDR1, ADDR2, MEM_ADDR, WB_ADDR;
    output reg [1:0] OP1_FWD_SEL, OP2_FWD_SEL;

    always @ (*)
    begin
        
        // Forwarding for Operand 1
        if (MEM_WRITE_EN && MEM_ADDR === ADDR1)
            OP1_FWD_SEL = 2'b01;    // Activate forwarding from MEM stage
        else if (WB_WRITE_EN && WB_ADDR === ADDR1)
            OP1_FWD_SEL = 2'b10;    // Activate forwarding from WB stage
        else
            OP1_FWD_SEL = 2'b00;    // No forwarding

        // Forwarding for Operand 2
        if (MEM_WRITE_EN && MEM_ADDR === ADDR2)
            OP2_FWD_SEL = 2'b01;    // Activate forwarding from MEM stage
        else if (WB_WRITE_EN && WB_ADDR === ADDR2)
            OP2_FWD_SEL = 2'b10;    // Activate forwarding from WB stage
        else
            OP2_FWD_SEL = 2'b00;    // No forwarding
    end
    
endmodule