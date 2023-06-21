`timescale 1ns/100ps

module mux4to1_32bit(INPUT1,INPUT2,INPUT3,INPUT4,RESULT,SELECT);

    input [31:0] INPUT1,INPUT2,INPUT3,INPUT4;
    input [1:0] SELECT;
    output reg [31:0] RESULT;

    always @(*)
    begin
        if (SELECT == 2'b00)
            RESULT = INPUT1;
        else if (SELECT == 2'b01)
            RESULT = INPUT2;
        else if (SELECT == 2'b10)
            RESULT = INPUT3;
        else 
            RESULT = INPUT4;
    end

endmodule