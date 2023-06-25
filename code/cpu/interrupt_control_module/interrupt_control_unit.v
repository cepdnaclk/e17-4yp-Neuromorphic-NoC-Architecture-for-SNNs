module interrupt_control_unit(IRQ, CURRENT_PC, ISR_SEL_OUT);
    input IRQ;
    input [31:0] CURRENT_PC;
    output ISR_SEL_OUT;   // Select signal for MUX to control PC

    // internal registers
    reg [31:0] INTERRUPT_LR;

    // Activate when IRQ is asserted
    always @ (posedge IRQ)
    begin
        /* do interrupt stuff */

        // Store current PC in LR

        // Branch to ISR

        // Wait for ISR to complete

        // De-assert IRQ

        // Branch back to PC stored in LR
    end

endmodule