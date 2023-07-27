module clock_divider (CLK_IN, CLK_OUT);
    input CLK_IN;
    output reg CLK_OUT;

    reg [24:0] counter;

    initial
    begin
        counter = 0;
        CLK_OUT = 0;
    end
    
    always @ (posedge CLK_IN)
    begin
        if (counter == 0)
        begin
            counter <= 25'd24999999;
            CLK_OUT <= ~CLK_OUT;
        end
        else
            counter <= counter - 25'd1;
    end

endmodule