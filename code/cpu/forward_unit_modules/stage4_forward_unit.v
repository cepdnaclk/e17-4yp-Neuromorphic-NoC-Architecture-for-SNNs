`timescale 1ns/100ps

module stage4_forward_unit(REG_READ_ADDR_S3, STAGE4_REG_ADDR, STAGE_3_MEM_WRITE, STAGE_4_MEM_READ, MUX_OUT);
    input [4:0] REG_READ_ADDR_S3, STAGE4_REG_ADDR;
    input STAGE_3_MEM_WRITE, STAGE_4_MEM_READ;
    output reg MUX_OUT;

    always @ (*) 
    begin
        // The logic flow for the mux
        if(STAGE_4_MEM_READ == 1'b1 && STAGE_3_MEM_WRITE == 1'b1)
            begin
                // if stage 3 and stage 4 use same address forward the stage 4 memory read
                if(REG_READ_ADDR_S3 == STAGE4_REG_ADDR)
                    MUX_OUT = 1'b1;
                // else no change 
                else 
                    MUX_OUT = 1'b0;
            end
        else
            MUX_OUT = 1'b0;
    end

endmodule