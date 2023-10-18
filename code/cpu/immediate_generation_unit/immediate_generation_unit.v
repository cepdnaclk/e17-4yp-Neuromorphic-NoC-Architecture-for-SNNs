`timescale 1ns/100ps

module immediate_generation_unit (INSTRUCTION, SELECT, OUTPUT);

    input [31:0] INSTRUCTION;
    input [2:0] SELECT;
    output reg [31:0] OUTPUT;

    wire[31:0] TYPE_I, TYPE_S, TYPE_B, TYPE_U, TYPE_J;

    // Immediate value encodings for each type
    assign TYPE_I = {{21{INSTRUCTION[31]}}, INSTRUCTION[30:20]};
    assign TYPE_S = {{21{INSTRUCTION[31]}}, INSTRUCTION[30:25], INSTRUCTION[11:7]};
    assign TYPE_B = {{20{INSTRUCTION[31]}}, INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8], 1'b0};
    assign TYPE_U = {INSTRUCTION[31:12], 12'b0};
    assign TYPE_J = {{12{INSTRUCTION[31]}}, INSTRUCTION[19:12], INSTRUCTION[20], INSTRUCTION[30:21], 1'b0};

    always @ (*)
    begin
        case (SELECT)
            3'b000:
                OUTPUT = TYPE_U;

            3'b001:
                OUTPUT = TYPE_J;

            3'b010:
                OUTPUT = TYPE_I;

            3'b011:
                OUTPUT = TYPE_B;

            3'b100:
                OUTPUT = TYPE_S;
                
            default:
                OUTPUT = 32'b0;
        endcase
    end

endmodule