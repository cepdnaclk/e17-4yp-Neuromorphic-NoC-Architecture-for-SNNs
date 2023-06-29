`timescale 1ns/100ps

// Floating Point Register File
module f_reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE_EN, CLK, RESET);
    
    input [31:0]  IN; // 32 bit data input
    input [4:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;  //5bit data inputs
    input WRITE_EN, CLK, RESET;  //1 bit data inputs
    output reg [31:0] OUT1, OUT2; //32 bit data outputs

    reg [31:0]  REGISTERS [31:0]; //32 bit x 32 floating point registers


    // Read on negative clock edge
    always @ (negedge CLK) 
    begin
        OUT1 <= #3 REGISTERS[OUT1ADDRESS];
        OUT2 <= #3 REGISTERS[OUT2ADDRESS];
    end

    // Write on positive clock edge 
    integer i;
    always @ (posedge CLK) 
    begin
        if (RESET == 1'b1)
        begin
            for (i = 0; i < 32; i = i + 1)
            begin
                REGISTERS[i] <= 0;       // Write zero to all registers
            end
        end
        else
        begin
            if (WRITE_EN == 1'b1)
            begin
                REGISTERS[INADDRESS] <= IN;    
            end
        end
    end


endmodule
