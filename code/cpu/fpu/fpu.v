`include "fpu/Addition-Subtraction.v"
`include "fpu/Multiplication.v"
`include "fpu/Division.v"
`include "fpu/Comparison.v"
`include "fpu/Converter.v"

`timescale 1ns/100ps

module fpu (DATA1, DATA2, DATA3, RESULT, SELECT);

    input [31:0] DATA1, DATA2, DATA3;
    input [4:0] SELECT;
    output reg [31:0] RESULT;

    // Exception wires
    wire Add_Sub_Exception, Mul_Exception, Mul_Overflow, Mul_Underflow, Div_Exception;

    // Connection wires
    wire AddBar_Sub, AddSubOp2Select;
    wire [1:0] AddSubOp1Select;
    wire [31:0] AddSubOp1, AddSubOp2;

    wire [1:0] COMPARE_RESULT;

    // Wires for intermediate calculations
    wire [31:0] INTER_FFWD,
                INTER_FADDSUB,
                INTER_FMUL,
                INTER_FDIV,
                INTER_FSQRT,    // Not implemented
                INTER_FMIN,
                INTER_FMAX,
                INTER_FCVTWS,
                INTER_FCVTWUS,  // Not implemented
                INTER_FSGNJ,
                INTER_FSGNJN,
                INTER_FSGNJX,
                INTER_FEQ,
                INTER_FLT,
                INTER_FLE,
                INTER_FCLASS;   // Not implemented

    /************** Functional Unit Control Signal Generation **************/
    // Set AddSubOp1 to (DATA1 * DATA2) for FMADD and FMSUB and -(DATA1 * DATA2) for FNMADD and FNMSUB
    // 00 = DATA1, 01 = xxx, 10 = (DATA1 * DATA2), 11 = -(DATA1 * DATA2)
    assign AddSubOp1Select[1] = (SELECT == 5'b01110) |     // FMADD
                                (SELECT == 5'b01111) |     // FMSUB
                                (SELECT == 5'b10000) |     // FNMADD
                                (SELECT == 5'b10001);      // FNMSUB
    
    assign AddSubOp1Select[0] = (SELECT == 5'b10000) |     // FNMADD
                                (SELECT == 5'b10001);      // FNMSUB


    // Set AddSubOp2 to DATA3 for any fused multiply operations
    assign AddSubOp2Select = (SELECT == 5'b01110) |     // FMADD
                             (SELECT == 5'b01111) |     // FMSUB
                             (SELECT == 5'b10000) |     // FNMADD
                             (SELECT == 5'b10001);      // FNMSUB

    // Set AddBar_Sub
    assign AddBar_Sub = (SELECT == 5'b00010) |  // FSUB
                        (SELECT == 5'b01111) |  // FMSUB
                        (SELECT == 5'b10000);   // FNMADD (This is not a mistake. RISC-V is weird!)

    /**************************** Functional Units ****************************/
    mux_4to1_32bit AddSubOp1_Mux (DATA1, 32'd0, INTER_FMUL, {~INTER_FMUL[31], INTER_FMUL[30:0]}, AddSubOp1, AddSubOp1Select);
    mux_2to1_32bit AddSubOp2_Mux (DATA2, DATA3, AddSubOp2, AddSubOp2Select);
    Addition_Subtraction AuI (AddSubOp1, AddSubOp2, AddBar_Sub, Add_Sub_Exception, INTER_FADDSUB);

    Multiplication MuI (DATA1, DATA2, Mul_Exception, Mul_Overflow, Mul_Underflow, INTER_FMUL);

    Division DuI (DATA1, DATA2, Div_Exception, INTER_FDIV);

    Comparison CuI (DATA1, DATA2, COMPARE_RESULT);

    Floating_Point_to_Integer FuI (DATA1, INTER_FCVTWS);


    /**************************** Intermediate Value Generation ****************************/
    // Forwarding
    assign INTER_FFWD = DATA1;

    // Sign Injection Operations
    assign INTER_FSGNJ = {DATA2[31], DATA1[30:0]};
    assign INTER_FSGNJN = {~DATA2[31], DATA1[30:0]};
    assign INTER_FSGNJX = {DATA1[31] ^ DATA2[31], DATA1[30:0]};

    // Min-Max Operations
    assign INTER_FMIN = (COMPARE_RESULT == 2'b01) ? DATA2 : DATA1;
    assign INTER_FMAX = (COMPARE_RESULT == 2'b01) ? DATA1 : DATA2;

    // Compare Operations
    assign INTER_FEQ = (COMPARE_RESULT == 2'b00) ? 32'd1 : 32'd0;
    assign INTER_FLT = (COMPARE_RESULT == 2'b10) ? 32'd1 : 32'd0;
    assign INTER_FLE = INTER_FEQ | INTER_FLT;


    /**************************** RESULT Selection ****************************/
    always @ (*) 
    begin
        casez (SELECT)
            5'b00000:
                RESULT <= INTER_FFWD;

            5'b00001, 5'b00010:   // FADD, FSUB
                RESULT <= INTER_FADDSUB;

            5'b00011:
                RESULT <= INTER_FMUL;

            5'b00100:
                RESULT <= INTER_FDIV;

            5'b00101:
                RESULT <= INTER_FMIN;

            5'b00110:
                RESULT <= INTER_FMAX;

            5'b00111:
                RESULT <= INTER_FSGNJ;

            5'b01000:
                RESULT <= INTER_FSGNJN;

            5'b01001:
                RESULT <= INTER_FSGNJX;

            5'b01010:
                RESULT <= INTER_FEQ;

            5'b01011:
                RESULT <= INTER_FLT;

            5'b01100:
                RESULT <= INTER_FLE;

            5'b01101:
                RESULT <= INTER_FSQRT;      // Not implemented

            5'b01110, 5'b01111, 5'b10000, 5'b10001:     // FMADD, FMSUB, FNMADD, FNMSUB
                RESULT <= INTER_FADDSUB;

            5'b10010:
                RESULT <= INTER_FCVTWS;

            5'b10011:
                RESULT <= INTER_FCVTWUS;    // Not implemented

            5'b10100:
                RESULT <= INTER_FCLASS;     // Not Implemented
            
            default: 
                RESULT = 0;
        endcase
    end

endmodule