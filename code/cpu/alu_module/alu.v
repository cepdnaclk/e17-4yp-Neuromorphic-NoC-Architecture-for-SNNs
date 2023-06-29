// TODO : write testbench 

`timescale 1ns/100ps


module alu (DATA1, DATA2, RESULT, SELECT);

    input [31:0] DATA1, DATA2;
    input [5:0] SELECT; // 6bit allocated 5 bit mentioned in paper
    output reg [31:0] RESULT;

    // Intermediates to hold calculations
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

    // Intermediate for 64-bit calculations
    wire    [63:0]  INTER_MULH64,
                    INTER_MULHU64,
                    INTER_MULHSU64;

    // TODO: Float not yet immplemented


    // Generate intermediates
    // Forward
    assign INTER_FWD = DATA2;

    // Basic arithmetic
    assign INTER_ADD = DATA1 + DATA2;
    assign INTER_SUB = DATA1 - DATA2;
    assign INTER_AND = DATA1 & DATA2;
    assign INTER_OR = DATA1 | DATA2;
    assign INTER_XOR = DATA1 ^ DATA2;

    // logical shift 
    assign  INTER_SLL = DATA1 << DATA2;
    assign  INTER_SRL = DATA1 >> DATA2;

    // arithmetic shift right
    assign  INTER_SRA = $signed(DATA1) >>> DATA2;

    // Set less than
    assign  INTER_SLT = ($signed(DATA1) < $signed(DATA2)) ? 1'b1 : 1'b0; //set less than
    assign  INTER_SLTU = ($unsigned(DATA1) < $unsigned(DATA2)) ? 1'b1 : 1'b0; // set less than unsigned

    // RV32M
    assign  INTER_MUL = DATA1 * DATA2; // multiplication
    // returns upper 32 bits of signed x signed
    assign INTER_MULH64 =  $signed(DATA1) * $signed(DATA2);
    assign INTER_MULH = INTER_MULH64[63:32];
    // returns upper 32 bits of signed x unsigned  
    assign INTER_MULHSU64 = $signed(DATA1) * $unsigned(DATA2);
    assign INTER_MULHSU = INTER_MULHSU64[63:32];
    // returns upper 32 bits of unsigned x unsigned  
    assign INTER_MULHU64 = $unsigned(DATA1) * $unsigned(DATA2);
    assign  INTER_MULHU = INTER_MULHU64[63:32];

    // signed integer division
    assign  INTER_DIV = $signed(DATA1) / $signed(DATA2);
    assign  INTER_REM = $signed(DATA1) % $signed(DATA2);

    // unsigned integer division
    assign INTER_DIVU = $unsigned(DATA1) / $unsigned(DATA2);
    assign  INTER_REMU = $unsigned(DATA1) % $unsigned(DATA2);


    always @ (*)
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
            default: 
                RESULT = 0;
        endcase
    end
endmodule
