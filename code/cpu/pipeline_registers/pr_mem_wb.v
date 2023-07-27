`timescale 1ns/100ps

module pr_mem_wb (
    CLK, RESET, 

    MEM_PC, MEM_ALU_OUT, MEM_DATA_MEM_READ_DATA,
    MEM_REG_WRITE_ADDR, MEM_REG_WRITE_EN, 
    MEM_DATA_MEM_READ, MEM_WB_VALUE_SELECT,

    WB_PC, WB_ALU_OUT, WB_DATA_MEM_READ_DATA,
    WB_REG_WRITE_ADDR, WB_REG_WRITE_EN,
    WB_DATA_MEM_READ, WB_WB_VALUE_SELECT
);

    input CLK, RESET;

    input [31:0] MEM_PC, MEM_ALU_OUT, MEM_DATA_MEM_READ_DATA;
    input [4:0] MEM_REG_WRITE_ADDR;
    input MEM_REG_WRITE_EN;
    input MEM_DATA_MEM_READ;
    input [1:0] MEM_WB_VALUE_SELECT;

    output reg [31:0] WB_PC, WB_ALU_OUT, WB_DATA_MEM_READ_DATA;
    output reg [4:0] WB_REG_WRITE_ADDR;
    output reg WB_REG_WRITE_EN;
    output reg WB_DATA_MEM_READ;
    output reg [1:0] WB_WB_VALUE_SELECT;

    always @ (posedge CLK)
    begin
        if (RESET == 1'b1)
        begin
            WB_PC = 32'b0;
            WB_ALU_OUT = 32'b0;
            WB_DATA_MEM_READ_DATA = 32'b0;
            WB_REG_WRITE_ADDR = 4'b0;
            WB_REG_WRITE_EN = 1'b0;
            WB_DATA_MEM_READ = 1'b0;
            WB_WB_VALUE_SELECT = 2'b0;
        end
        else
        begin
            WB_PC = MEM_PC;
            WB_ALU_OUT = MEM_ALU_OUT;
            WB_DATA_MEM_READ_DATA = MEM_DATA_MEM_READ_DATA;
            WB_REG_WRITE_ADDR = MEM_REG_WRITE_ADDR;
            WB_REG_WRITE_EN = MEM_REG_WRITE_EN;
            WB_DATA_MEM_READ = MEM_DATA_MEM_READ;
            WB_WB_VALUE_SELECT = MEM_WB_VALUE_SELECT;
        end
    end
    
endmodule