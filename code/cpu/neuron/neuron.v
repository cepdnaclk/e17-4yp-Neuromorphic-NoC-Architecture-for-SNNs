`include "fpu/Multiplication.v"
`include "fpu/Addition-Subtraction.v"
`include "fpu/Comparison.v"

`timescale 1ns/100ps

module neuron (CLK, RESET, SPIKED, I, a, b, c, d);
    localparam POINT_ZERO_FOUR = 32'h3d23d70a;
    localparam FIVE = 32'h40a00000;
    localparam ONE_FORTY = 32'h430c0000;
    localparam THIRTY = 32'h41f00000;

    input CLK, RESET;
    input [31:0] I, a, b, c, d;
    output SPIKED;

    reg [31:0] V;   // Membrane potential
    reg [31:0] U;   // Recovery variable

    // Connection wires
    wire [31:0] POINT_ZERO_FOUR_V, POINT_ZERO_FOUR_V_SQUARED, FIVE_V, B_V, 
                B_V_MINUS_U, ADD1_OUT, ADD2_OUT, ADD3_OUT, V_NEW, U_NEW, U_PLUS_D;

    wire [1:0] COMPARE_RESULT;
    wire Mul1_Exception, Mul1_Overflow, Mul1_Underflow,
         Mul2_Exception, Mul2_Overflow, Mul2_Underflow,
         Mul3_Exception, Mul3_Overflow, Mul3_Underflow,
         Mul4_Exception, Mul4_Overflow, Mul4_Underflow,
         Mul5_Exception, Mul5_Overflow, Mul5_Underflow,
         Add1_Exception, Add2_Exception, Add3_Exception,
         Add4_Exception, Add5_Exception, Add6_Exception;


    /******************************** V' Calculation ********************************/
    Multiplication mul1 (POINT_ZERO_FOUR, V, Mul1_Exception, Mul1_Overflow, Mul1_Underflow, POINT_ZERO_FOUR_V);
    Multiplication mul2 (POINT_ZERO_FOUR_V, V, Mul2_Exception, Mul2_Overflow, Mul2_Underflow, POINT_ZERO_FOUR_V_SQUARED);

    Multiplication mul3 (FIVE, V, Mul3_Exception, Mul3_Overflow, Mul3_Underflow, FIVE_V);

    Addition_Subtraction add1 (POINT_ZERO_FOUR_V_SQUARED, FIVE_V, 1'b0, Add1_Exception, ADD1_OUT);
    Addition_Subtraction add2 (ADD1_OUT, ONE_FORTY, 1'b0, Add2_Exception, ADD2_OUT);
    Addition_Subtraction add3 (ADD2_OUT, U, 1'b1, Add3_Exception, ADD3_OUT);
    Addition_Subtraction add4 (ADD3_OUT, I, 1'b0, Add4_Exception, V_NEW);

    /******************************** U' Calculation ********************************/
    Multiplication mul4 (b, V, Mul4_Exception, Mul4_Overflow, Mul4_Underflow, B_V);
    Addition_Subtraction add5 (B_V, U, 1'b1, Add5_Exception, B_V_MINUS_U);

    Multiplication mul5 (a, B_V_MINUS_U, Mul5_Exception, Mul5_Overflow, Mul5_Underflow, U_NEW);

    /******************************** U RESET Calculation ********************************/
    Addition_Subtraction add6 (U, d, 1'b0, Add6_Exception, U_PLUS_D);

    /******************************** SPIKED Calculation ********************************/
    Comparison CuI (V, THIRTY, COMPARE_RESULT);
    assign #1 SPIKED = (COMPARE_RESULT == 2'b00) | (COMPARE_RESULT == 2'b01);


    always @ (posedge CLK)
    begin
        if (RESET)
        begin
            V <= #1 c;
            U <= #1 U_PLUS_D;
        end
        else
        begin
            V <= #1 V_NEW;
            U <= #1 U_NEW;
        end
    end
    
endmodule