`timescale 1ns/100ps

module pr_mem_wb (
    CLK, RESET, 

    MEM_PC, MEM_ALU_OUT, MEM_DATA_MEM_READ_DATA, MEM_FPU_OUT,
    MEM_REG_WRITE_ADDR, MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN,
    MEM_DATA_MEM_READ, MEM_WB_VALUE_SELECT,

    WB_PC, WB_ALU_OUT, WB_DATA_MEM_READ_DATA, WB_FPU_OUT,
    WB_REG_WRITE_ADDR, WB_REG_WRITE_EN, WB_FREG_WRITE_EN,
    WB_DATA_MEM_READ, WB_WB_VALUE_SELECT
);

    input CLK, RESET;

    input [31:0] MEM_PC, MEM_ALU_OUT, 
                 MEM_DATA_MEM_READ_DATA, MEM_FPU_OUT;
    input [4:0] MEM_REG_WRITE_ADDR;
    input MEM_REG_WRITE_EN, MEM_FREG_WRITE_EN;
    input MEM_DATA_MEM_READ;
    input [1:0] MEM_WB_VALUE_SELECT;

    output reg [31:0] WB_PC, WB_ALU_OUT, 
                      WB_DATA_MEM_READ_DATA, WB_FPU_OUT;
    output reg [4:0] WB_REG_WRITE_ADDR;
    output reg WB_REG_WRITE_EN, WB_FREG_WRITE_EN;
    output reg WB_DATA_MEM_READ;
    output reg [1:0] WB_WB_VALUE_SELECT;

    always @ (posedge CLK)
    begin
        if (RESET == 1'b1)
        begin
            WB_PC <= #0.1 32'd0;
            WB_ALU_OUT <= #0.1 32'd0;
            WB_DATA_MEM_READ_DATA <= #0.1 32'd0;
            WB_FPU_OUT <= #0.1 32'd0;
            WB_REG_WRITE_ADDR <= #0.1 4'd0;
            WB_REG_WRITE_EN <= #0.1 1'd0;
            WB_FREG_WRITE_EN <= #0.1 1'd0;
            WB_DATA_MEM_READ <= #0.1 1'd0;
            WB_WB_VALUE_SELECT <= #0.1 2'd0;
        end
        else
        begin
            WB_PC <= #0.1 MEM_PC;
            WB_ALU_OUT <= #0.1 MEM_ALU_OUT;
            WB_DATA_MEM_READ_DATA <= #0.1 MEM_DATA_MEM_READ_DATA;
            WB_FPU_OUT <= #0.1 MEM_FPU_OUT;
            WB_REG_WRITE_ADDR <= #0.1 MEM_REG_WRITE_ADDR;
            WB_REG_WRITE_EN <= #0.1 MEM_REG_WRITE_EN;
            WB_FREG_WRITE_EN <= #0.1 MEM_FREG_WRITE_EN;
            WB_DATA_MEM_READ <= #0.1 MEM_DATA_MEM_READ;
            WB_WB_VALUE_SELECT <= #0.1 MEM_WB_VALUE_SELECT;
        end
    end
    
endmodule