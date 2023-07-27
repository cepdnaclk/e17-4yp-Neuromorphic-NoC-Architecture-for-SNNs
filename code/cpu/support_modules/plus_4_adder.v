`timescale 1ns/100ps

module plus_4_adder (IN, OUT);

    input [31:0] IN;
    output [31:0] OUT;

    assign #1 OUT = IN + 4;

endmodule