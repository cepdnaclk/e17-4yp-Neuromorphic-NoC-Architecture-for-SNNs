`timescale 1ns/100ps

module f_alu (DATA1, DATA2, DATA3, RESULT, SELECT);

    input [31:0] DATA1, DATA2;
    input [5:0] SELECT;
    output reg [31:0] RESULT;

    // Wires for intermediate calculations
    wire [31:0] INTER_FADD,
                INTER_FSUB,
                INTER_FMUL,
                INTER_FDIV,
                INTER_FSQRT,
                INTER_FMIN,
                INTER_FMAX,
                INTER_FMADD,
                INTER_FMSUB,
                INTER_FNMADD,
                INTER_FNMSUB,
                ;

    // 64-bit intermediates to hold results of multiplications
    wire [63:0] INTER_MULH64,
                INTER_MULHU64;
    reg  [63:0] INTER_MULHSU64;



    /* Send out correct result based on SELECT */
    always @(*) 
    begin
        casez (SELECT)

            default: 
                RESULT = 0;
        endcase
    end

endmodule