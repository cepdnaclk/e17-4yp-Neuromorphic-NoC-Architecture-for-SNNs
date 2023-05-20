`include "../../cpu/reg_file_module/reg_file.v"
`timescale 1ns/100ps

module reg_file_tb;

    // Declare connections to ALU
    reg[31:0] IN;
    reg[4:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
    reg WRITE_EN, CLK, RESET;
    wire[31:0] OUT1, OUT2;

    // Instantiate ALU module
    reg_file my_reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS,OUT2ADDRESS, WRITE_EN, CLK, RESET);

    integer i;

    initial begin
        $dumpfile("reg_file_tb.vcd");
        $dumpvars(0,my_reg_file);
        for(i=0;i<31;i=i+1)
            $dumpvars(1, reg_file_tb.my_reg_file.reg_file.REGISTERS[i]);
    end

    initial begin

        CLK = 1'b0;
        RESET = 1'b1;
        WRITE_EN = 1'b0; // write enable not needed for reset
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00011;
        OUT2ADDRESS = 5'b00001;

        #1;
        CLK = 1'b1;
        RESET = 1'b1;
        WRITE_EN = 1'b0; // write enable not needed for reset
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00011;
        OUT2ADDRESS = 5'b00001;

        #1;
        CLK = 1'b0;
        RESET = 1'b0;
        WRITE_EN = 1'b0; 
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00011;
        OUT2ADDRESS = 5'b00001;

        #1;
        CLK = 1'b1;
        RESET = 1'b0;
        WRITE_EN = 1'b1; 
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00011;
        OUT2ADDRESS = 5'b00001;


        #1
        CLK = 1'b0;
        RESET = 1'b0;
        WRITE_EN = 1'b0; 
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00010;
        OUT2ADDRESS = 5'b00001;


        #1;
        CLK = 1'b1;
        RESET = 1'b0;
        WRITE_EN = 1'b0; 
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00000;
        OUT2ADDRESS = 5'b00010;


        #1;
        CLK = 1'b0;
        RESET = 1'b0;
        WRITE_EN = 1'b0; 
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00000;
        OUT2ADDRESS = 5'b00001;

        #1;
        CLK = 1'b1;
        RESET = 1'b1;
        WRITE_EN = 1'b0; 
        IN = 32'b00000000000000000000000000000010;
        INADDRESS = 5'b00000;
        OUT1ADDRESS = 5'b00000;
        OUT2ADDRESS = 5'b00010;
        #1;


        $finish;

    end

endmodule
