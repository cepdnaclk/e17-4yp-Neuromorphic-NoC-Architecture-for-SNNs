`timescale 1ns/100ps

module pr_ex_mem (
    CLK, RESET, 

    EX_PC, EX_ALU_OUT, EX_REG_DATA2, EX_FREG_DATA2, EX_FPU_OUT,
    EX_REG_WRITE_ADDR, EX_REG_READ_ADDR2, EX_REG_TYPE,
    EX_REG_WRITE_EN, EX_FREG_WRITE_EN, EX_DATA_MEM_WRITE_DATA_SELECT,
    EX_DATA_MEM_WRITE, EX_DATA_MEM_READ, EX_WB_VALUE_SELECT,

    MEM_PC, MEM_ALU_OUT, MEM_REG_DATA2, MEM_FREG_DATA2, MEM_FPU_OUT,
    MEM_REG_WRITE_ADDR, MEM_REG_READ_ADDR2, MEM_REG_TYPE,
    MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN, MEM_DATA_MEM_WRITE_DATA_SELECT,
    MEM_DATA_MEM_WRITE, MEM_DATA_MEM_READ, MEM_WB_VALUE_SELECT
);

    input CLK, RESET;

    input [31:0] EX_PC, EX_ALU_OUT, EX_REG_DATA2, 
                 EX_FPU_OUT, EX_FREG_DATA2;
    input [4:0] EX_REG_WRITE_ADDR, EX_REG_READ_ADDR2;
    input EX_REG_WRITE_EN, EX_FREG_WRITE_EN, 
          EX_DATA_MEM_WRITE_DATA_SELECT;
    input [3:0] EX_DATA_MEM_READ;
    input [2:0] EX_DATA_MEM_WRITE;
    input [1:0] EX_REG_TYPE, EX_WB_VALUE_SELECT;

    output reg [31:0] MEM_PC, MEM_ALU_OUT, MEM_REG_DATA2,
                      MEM_FPU_OUT, MEM_FREG_DATA2;
    output reg [4:0] MEM_REG_WRITE_ADDR, MEM_REG_READ_ADDR2;
    output reg MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN, 
               MEM_DATA_MEM_WRITE_DATA_SELECT;
    output reg [3:0] MEM_DATA_MEM_READ;
    output reg [2:0] MEM_DATA_MEM_WRITE;
    output reg [1:0] MEM_REG_TYPE, MEM_WB_VALUE_SELECT;

    always @ (posedge CLK)
    begin
        if (RESET == 1'b1)
        begin
            MEM_PC <= #0.1 32'd0;
            MEM_ALU_OUT <= #0.1 32'd0;
            MEM_REG_DATA2 <= #0.1 32'd0;
            MEM_FPU_OUT <= #0.1 32'd0;
            MEM_FREG_DATA2 <= #0.1 32'd0;
            MEM_REG_WRITE_ADDR <= #0.1 4'd0;
            MEM_REG_READ_ADDR2 <= #0.1 4'd0;
            MEM_REG_TYPE <= #0.1 2'd0;
            MEM_REG_WRITE_EN <= #0.1 1'd0;
            MEM_FREG_WRITE_EN <= #0.1 1'd0;
            MEM_DATA_MEM_WRITE_DATA_SELECT <= #0.1 1'd0;
            MEM_DATA_MEM_WRITE <= #0.1 3'd0;
            MEM_DATA_MEM_READ <= #0.1 4'd0;
            MEM_WB_VALUE_SELECT <= #0.1 2'd0;
        end
        else
        begin
            MEM_PC <= #0.1 EX_PC;
            MEM_ALU_OUT <= #0.1 EX_ALU_OUT;
            MEM_REG_DATA2 <= #0.1 EX_REG_DATA2;
            MEM_FPU_OUT <= #0.1 EX_FPU_OUT;
            MEM_FREG_DATA2 <= #0.1 EX_FREG_DATA2;
            MEM_REG_WRITE_ADDR <= #0.1 EX_REG_WRITE_ADDR;
            MEM_REG_READ_ADDR2 <= #0.1 EX_REG_READ_ADDR2;
            MEM_REG_TYPE <= #0.1 EX_REG_TYPE;
            MEM_REG_WRITE_EN <= #0.1 EX_REG_WRITE_EN;
            MEM_FREG_WRITE_EN <= #0.1 EX_FREG_WRITE_EN;
            MEM_DATA_MEM_WRITE_DATA_SELECT <= #0.1 EX_DATA_MEM_WRITE_DATA_SELECT;
            MEM_DATA_MEM_WRITE <= #0.1 EX_DATA_MEM_WRITE;
            MEM_DATA_MEM_READ <= #0.1 EX_DATA_MEM_READ;
            MEM_WB_VALUE_SELECT <= #0.1 EX_WB_VALUE_SELECT;
        end
    end
    
endmodule