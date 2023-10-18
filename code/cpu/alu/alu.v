`timescale 1ns/100ps

module alu (DATA1, DATA2, RESULT, SELECT);

    input [31:0] DATA1, DATA2;
    input [5:0] SELECT;
    output reg [31:0] RESULT;

    // Wires for intermediate calculations
    wire [31:0] INTER_ADD,
                INTER_SUB,
                INTER_AND,
                INTER_OR,
                INTER_XOR,
                INTER_SLT,
                INTER_SLTU,
                INTER_SLL,
                INTER_SRL,
                INTER_SRA,
                INTER_MUL,
                INTER_MULH,
                INTER_MULHSU,
                INTER_MULHU,
                INTER_DIV,
                INTER_DIVU,
                INTER_REM,
                INTER_REMU,
                INTER_FWD;

                /*INTER_FCVTSW,
                INTER_FCVTSWU */

    // 64-bit intermediates to hold results of multiplications
    wire [63:0] INTER_MULH64,
                INTER_MULHU64;
    reg  [63:0] INTER_MULHSU64;


    // TODO: Floating point instructions


    /*** Generate values for intermediates ***/
    // Forward
    assign INTER_FWD = DATA2;

    // Basic arithmetic
    assign #1 INTER_ADD = DATA1 + DATA2;
    assign #1 INTER_SUB = DATA1 - DATA2;
    assign #1 INTER_AND = DATA1 & DATA2;
    assign #1 INTER_OR = DATA1 | DATA2;
    assign #1 INTER_XOR = DATA1 ^ DATA2;

    // Logical shifts
    assign #2 INTER_SLL = DATA1 << DATA2;
    assign #2 INTER_SRL = DATA1 >> DATA2;

    // Arithmetic shift
    assign #2 INTER_SRA = $signed(DATA1) >>> DATA2;    // $signed is needed because DATA1 is considered unsigned by default and >>> will not work

    // Set less than
    assign #1 INTER_SLT = ($signed(DATA1) < $signed(DATA2)) ? 1'b1 : 1'b0;
    assign #1 INTER_SLTU = ($unsigned(DATA1) < $unsigned(DATA2)) ? 1'b1 : 1'b0;

    // Multiplication
    assign #5 INTER_MUL = DATA1 * DATA2;

    // MULH returns the upper 32 bits of signed x signed multiplication
    assign #5 INTER_MULH64 = $signed(DATA1) * $signed(DATA2);
    assign INTER_MULH = INTER_MULH64[63:32];

    // MULHSU returns the upper 32 bits of signed x unsigned multiplication 
    always @ (*)
    begin
        #5
        case ({DATA1[31], DATA2[31]})
            2'b00,
            2'b01:
                INTER_MULHSU64 = DATA1 * DATA2;         // Both operands are positive so no need to mark as signed

            2'b10:
                INTER_MULHSU64 = $signed(DATA1) * $signed(DATA2);       // Since second operand is positive anyway, consider as signed

            2'b11:
                INTER_MULHSU64 = ~($signed(DATA1) * $unsigned(DATA2)) + 1;      // Result must be negative when signed operand is negative
        endcase
    end
    assign INTER_MULHSU = INTER_MULHSU64[63:32];

    // MULHU returns the upper 32 bits of unsigned x unsigned multiplication 
    assign #5 INTER_MULHU64 = $unsigned(DATA1) * $unsigned(DATA2);
    assign INTER_MULHU = INTER_MULHU64[63:32];

    // Division
    assign #8 INTER_DIV = $signed(DATA1) / $signed(DATA2);
    assign #8 INTER_DIVU = $unsigned(DATA1) / $unsigned(DATA2);

    // Remainder
    assign #8 INTER_REM = $signed(DATA1) % $signed(DATA2);
    assign #8 INTER_REMU = $unsigned(DATA1) % $unsigned(DATA2);

    /* Send out correct result based on SELECT */
    always @(*) 
    begin
        casez (SELECT)
            // RV32I
            6'b000000:
                RESULT = INTER_ADD;
            6'b000001:
                RESULT = INTER_SLL;
            6'b000010:
                RESULT = INTER_SLT;
            6'b000011:
                RESULT = INTER_SLTU;
            6'b000100:
                RESULT = INTER_XOR;
            6'b000101:
                RESULT = INTER_SRL;
            6'b000110:
                RESULT = INTER_OR;
            6'b000111:
                RESULT = INTER_AND;

            // RV32M
            6'b001000:
                RESULT = INTER_MUL;
            6'b001001:
                RESULT = INTER_MULH;
            6'b001010:
                RESULT = INTER_MULHSU;
            6'b001011:
                RESULT = INTER_MULHU;
            6'b001100:
                RESULT = INTER_DIV;
            6'b001101:
                RESULT = INTER_DIVU;
            6'b001110:
                RESULT = INTER_REM;
            6'b001111:
                RESULT = INTER_REMU;

            // RV32I (Contd...)
            6'b010000:
                RESULT = INTER_SUB;
            6'b010101:
                RESULT = INTER_SRA;
            6'b011???:
                RESULT = INTER_FWD;

            // TODO: 6'b100000 onwards for floating point

            
            default: 
                RESULT = 0;
        endcase
    end

endmodule