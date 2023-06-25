`timescale 1ns/100ps

module hazard_detection_unit (ADDR1_S2, ADDR2_S2, ADDR_S3, MEM_READ_S3, LOAD_USE_HAZARD);
    input [4:0] ADDR2_S2, ADDR1_S2, ADDR_S3;
    input MEM_READ_S3;
    output LOAD_USE_HAZARD;

    // If instruction in EX stage is a LOAD instruction and
    // the destination reg address in S3 is equal to either of the 
    // operand reg addresses in S2, we have a load-use hazard
    assign LOAD_USE_HAZARD = MEM_READ_S3 && ((ADDR1_S2 == ADDR_S3) || (ADDR2_S2 == ADDR_S3));

endmodule