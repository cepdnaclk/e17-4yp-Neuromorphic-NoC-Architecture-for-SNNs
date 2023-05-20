`timescale  1ns/100ps

module stage3_forward_unit(MEM_WRITE, ADDR1, ADDR2, OP1_MUX, OP2_MUX, STAGE_3_ADDR, STAGE_3_REGWRITE_EN, STAGE_4_ADDR, STAGE_4_REGWRITE_EN, STAGE_5_EXTRA_ADDR, STAGE_5_EXTRA_REGWRITE_EN, OP1_MUX_OUT, OP2_MUX_OUT);
    input [4:0] ADDR1, ADDR2;
    input OP1_MUX, OP2_MUX;
    input [4:0] STAGE_3_ADDR, STAGE_4_ADDR, STAGE_5_EXTRA_ADDR;
    input STAGE_3_REGWRITE_EN, STAGE_4_REGWRITE_EN, STAGE_5_EXTRA_REGWRITE_EN;
    input MEM_WRITE;
    output reg [1:0] OP1_MUX_OUT, OP2_MUX_OUT;


    always @ (*)
    begin
        // The logic flow for the operand 1
        if(STAGE_3_REGWRITE_EN == 1'b1 && STAGE_3_ADDR == ADDR1)
            begin
                // forwarding data from stage 3
                OP1_MUX_OUT = 2'b01;
            end
        else if(STAGE_4_REGWRITE_EN == 1'b1 && STAGE_4_ADDR == ADDR1)
            begin
                // forwarding data from stage 4
                OP1_MUX_OUT = 2'b10;
            end
        else if(STAGE_5_EXTRA_REGWRITE_EN == 1'b1 && STAGE_5_EXTRA_ADDR == ADDR1)
            begin
                // forwarding data from stage 5 extra stage for forwading 
                OP1_MUX_OUT = 2'b11;
            end
        else
            begin
                // no forwarding 
                OP1_MUX_OUT = 2'b00;
            end


        // The logic flow for the operand 1
        if(STAGE_3_REGWRITE_EN == 1'b1 && STAGE_3_ADDR == ADDR2)
            begin
                // forwading the data from stage 3
                OP2_MUX_OUT = 2'b01;
            end
        else if (STAGE_4_REGWRITE_EN == 1'b1 && STAGE_4_ADDR == ADDR2)
            begin
                // forwading the data from stage 4 
                OP2_MUX_OUT = 2'b10;
            end
        else if (STAGE_5_EXTRA_REGWRITE_EN == 1'b1 && STAGE_5_EXTRA_ADDR == ADDR2)
            begin
                // forwading the data from stage 5 extra stage for forwading 
                OP2_MUX_OUT = 2'b11;
            end
        else
            begin
                // no forwading 
                OP2_MUX_OUT = 2'b00;
            end

    end


endmodule