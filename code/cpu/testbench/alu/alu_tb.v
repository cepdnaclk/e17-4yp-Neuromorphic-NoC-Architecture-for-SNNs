`include "../../cpu/alu_module/alu.v"
`timescale 1ns/100ps

module alu_tb;

    // Declare connections to ALU
    reg[31:0] DATA1, DATA2;
    reg[5:0] SELECT;
    wire[31:0] RESULT;

    // Instantiate ALU module
    alu myALU(DATA1, DATA2, RESULT, SELECT);

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0,myALU);
    end

    initial begin
        DATA1 = 32'b00000000000000000000000000000010;
        DATA2 = 32'b00000000000000000000000000000011;
        SELECT = 6'b000000;
        #10;
        SELECT = 6'b000001;
        #10;
        SELECT = 6'b000010;
        #10;
        SELECT = 6'b000011;

        #10;
        SELECT = 6'b000100;
        #10;
        SELECT = 6'b000101;
        #10;
        SELECT = 6'b000110;
        #10;
        SELECT = 6'b000111;

        //mul commmand
        #10;
        SELECT = 6'b001000;
        #10;
        SELECT = 6'b001001;
        #10;
        SELECT = 6'b001010;
        #10;
        SELECT = 6'b001011;
        #10;
        SELECT = 6'b001100;
        #10;
        SELECT = 6'b001101;
        #10;
        SELECT = 6'b001111;


        #10;
        SELECT = 6'b010000;
        #10;
        SELECT = 6'b010101;
        #10;
        SELECT = 6'b011111;
        $finish;

    end

endmodule
