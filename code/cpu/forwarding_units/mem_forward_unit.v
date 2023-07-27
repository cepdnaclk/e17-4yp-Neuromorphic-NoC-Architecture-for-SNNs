`timescale 1ns/100ps

/* Handles load-store data hazards (Hazards that 
   occur when data is read from memory to a register and 
   then stored back to memory in the subsequent instruction)
*/
module mem_forward_unit (MEM_ADDR, MEM_DATA_MEM_WRITE, WB_ADDR, WB_DATA_MEM_READ, MEM_FWD_SEL);

    input MEM_DATA_MEM_WRITE, WB_DATA_MEM_READ;
    input [4:0] MEM_ADDR, WB_ADDR;
    output reg MEM_FWD_SEL;

    always @ (*)
    begin
        if (MEM_DATA_MEM_WRITE && WB_DATA_MEM_READ && (MEM_ADDR === WB_ADDR))
            MEM_FWD_SEL = 1'b1;
        else
            MEM_FWD_SEL = 1'b0;
    end
    
endmodule