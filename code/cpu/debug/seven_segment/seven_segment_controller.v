module seven_segment_controller (IN, OUT);
    input [31:0] IN;
    output reg [6:0] OUT;

    always @ (*)
    begin
        case (IN[3:0])
            4'b0000:
                OUT = 7'b1111110;
            
            4'b0001:
                OUT = 7'b0110000;

            4'b0010:
                OUT = 7'b1101101;
            
            4'b0011:
                OUT = 7'b1111001;
            
            4'b0100:
                OUT = 7'b0110011;
            
            4'b0101:
                OUT = 7'b1011011;

            4'b0110:
                OUT = 7'b1011111;
            
            4'b0111:
                OUT = 7'b1110000;

            4'b1000:
                OUT = 7'b1111111;
            
            4'b1001:
                OUT = 7'b1111011;

            default:
                OUT = 7'b0000001;   // In case of overflow, show a "-" character
        endcase
    end
endmodule