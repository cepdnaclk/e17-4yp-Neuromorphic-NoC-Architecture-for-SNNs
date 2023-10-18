`timescale 1ns/100ps

/* Handles load-store data hazards (Hazards that 
   occur when data is read from memory to a register and 
   then stored back to memory in the subsequent instruction) */
module mem_forward_unit (
    MEM_ADDR, MEM_DATA_MEM_WRITE, 
    MEM_REG_TYPE, WB_WRITE_EN, WB_F_WRITE_EN,
    WB_ADDR, WB_DATA_MEM_READ, MEM_FWD_SEL
);

    input MEM_DATA_MEM_WRITE, WB_DATA_MEM_READ, WB_WRITE_EN, WB_F_WRITE_EN;
    input [1:0] MEM_REG_TYPE;
    input [4:0] MEM_ADDR, WB_ADDR;
    output reg MEM_FWD_SEL;

    always @ (*)
    begin    
        if (MEM_DATA_MEM_WRITE && WB_DATA_MEM_READ) 
            if (WB_WRITE_EN)    // Value in WB is int
                MEM_FWD_SEL = (MEM_REG_TYPE == 2'b00) && (MEM_ADDR === WB_ADDR);
            else    // Value in WB is float
                MEM_FWD_SEL = (MEM_REG_TYPE != 2'b00) && (MEM_ADDR === WB_ADDR);
    end
    
endmodule