`include "reg_file/reg_file.v"
`timescale 1ns/100ps

module reg_file_tb;

    // Parameters
    parameter CLOCK_PERIOD = 10; // Clock period in ns
    parameter READ_DELAY = 2;
    parameter WRITE_DELAY = 2; 

    // Connections to the register file
    reg[31:0] DATA_IN;
    reg[4:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
    reg WRITE_EN, CLK, RESET;
    wire[31:0] DATA_OUT1, DATA_OUT2;

    // Instantiate register file module
    reg_file dut (DATA_IN, DATA_OUT1, DATA_OUT2, INADDRESS, OUT1ADDRESS,OUT2ADDRESS, WRITE_EN, CLK, RESET);

    // Dump wavedata to vcd file
    integer i;
    initial begin
        $dumpfile("build/reg_file/reg_file_tb.vcd");
        $dumpvars(0, dut);
        for(i = 0; i < 32; i = i + 1)
            $dumpvars(1, reg_file_tb.dut.reg_file.REGISTERS[i]);
    end

    // Clock generation
    initial CLK = 1'b1;
    always #((CLOCK_PERIOD) / 2) CLK = ~CLK;
    

    // Test stimulus
    initial 
    begin
        $display("\t\tTIME\t\tx0\t\tx1\t\tx2\t\tx3\t\tx4\t\tx5");
        $monitor("%t\t%x\t%x\t%x\t%x\t%x\t%x", $time, reg_file_tb.dut.reg_file.REGISTERS[0], reg_file_tb.dut.reg_file.REGISTERS[1], reg_file_tb.dut.reg_file.REGISTERS[2], reg_file_tb.dut.reg_file.REGISTERS[3], reg_file_tb.dut.reg_file.REGISTERS[4], reg_file_tb.dut.reg_file.REGISTERS[5]);

        // Reset initial values
        RESET = 1;
        WRITE_EN = 0;
        DATA_IN = 0;
        INADDRESS = 0;
        OUT1ADDRESS = 0;
        OUT2ADDRESS = 0;

        // Release reset
        #(CLOCK_PERIOD) RESET = 0;


        // TODO: Fix!

        // Testcase 1: Write and read data
        WRITE_EN = 1;
        DATA_IN = 32'h12345678;
        INADDRESS = 1;
        #(WRITE_DELAY)
        WRITE_EN = 0;

        OUT1ADDRESS = 1;
        OUT2ADDRESS = 1;
        #(CLOCK_PERIOD - WRITE_DELAY)
        /* $display("Testcase 1:");
        $display("Input:  DATA_IN = %h, INADDRESS = %h", DATA_IN, INADDRESS);
        $display("Output: DATA_OUT1 = %h, OUT1ADDRESS = %h", DATA_OUT1, OUT1ADDRESS);
        $display("        DATA_OUT2 = %h, OUT2ADDRESS = %h", DATA_OUT2, OUT2ADDRESS); */

        // Testcase 2: Write to different addresses
        WRITE_EN = 1;
        DATA_IN = 32'hABCDEFF0;
        INADDRESS = 3;
        #2;
        WRITE_EN = 0;
        #2;
        INADDRESS = 2;
        #2;
        OUT1ADDRESS = 2;
        #2;
        OUT2ADDRESS = 3;
        #2;
        /* $display("Testcase 2:");
        $display("Input:  DATA_IN = %h, INADDRESS = %h", DATA_IN, INADDRESS);
        $display("Output: DATA_OUT1 = %h, OUT1ADDRESS = %h", DATA_OUT1, OUT1ADDRESS);
        $display("        DATA_OUT2 = %h, OUT2ADDRESS = %h", DATA_OUT2, OUT2ADDRESS); */

        // Testcase 3: Read from unwritten addresses
        OUT1ADDRESS = 0;
        #2;
        OUT2ADDRESS = 1;
        #2;
        /* $display("Testcase 3:");
        $display("Input:  OUT1ADDRESS = %h", OUT1ADDRESS);
        $display("Output: DATA_OUT1 = %h", DATA_OUT1);
        $display("        DATA_OUT2 = %h", DATA_OUT2); */

        // Testcase 4: Write and read from multiple addresses
        WRITE_EN = 1;
        DATA_IN = 32'h98765432;
        INADDRESS = 0;
        #2;
        WRITE_EN = 0;
        #2;
        INADDRESS = 1;
        #2;
        OUT1ADDRESS = 1;
        #2;
        OUT2ADDRESS = 0;
        #2;
        /* $display("Testcase 4:");
        $display("Input:  DATA_IN = %h, INADDRESS = %h", DATA_IN, INADDRESS);
        $display("Output: DATA_OUT1 = %h, OUT1ADDRESS = %h", DATA_OUT1, OUT1ADDRESS);
        $display("        DATA_OUT2 = %h, OUT2ADDRESS = %h", DATA_OUT2, OUT2ADDRESS); */

        // Add more test cases as needed...

        // End simulation
        #10 $finish;
    end

endmodule
