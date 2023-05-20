`timescale 1ns/100ps

module ins_memory(CLK, READ, ADDRESS, READDATA, BUSYWAIT);

// insutruction memory with 1024 bytes
// byte addressing
// serve data blocks of 16 bytes (4 words)
// 28 bit to address a block
// .bin file - 1024 bytes of instruction data
// 40 time units to simulate block fetching delay

    input CLK, READ;
    // input   [31:0]    ADDRESS;
    // output reg [31:0]   READDATA;
    input [27:0] ADDRESS; // 28 bit memory blocks
    output reg [127:0] READDATA; // 128 bit block size
    output reg BUSYWAIT;

    // // instruction injection 
    // input[9:0]  INJECT_ADDR;
    // input[7:0]  INJECT_DATA;
    // input       INJECT_CLK;

    reg READ_ACCESS;

    // Declare memory array 1024 x 8 bits
    reg [7:0] memory_array [0:1023];
 
    // ================= for simulation ============

    // initial begin
    //     $readmemb("prog.bin", memory_array);
    // end

    // ==============================================
    // UNCOMMENT FOR FPGA

    // // Detecting an incoming memory access
    // always @ (READ)
    // begin
    //     BUSYWAIT = 0;
    //     READ_ACCESS = (READ) ? 1:0;
    // end

    // // READING
    // always @ (posedge CLK)
    // begin
    //     if(READ_ACCESS)
    //     begin
    //         READDATA[7:0]   = memory_array[{ADDRESS[31:2],2'b00}];
    //         READDATA[15:8]  = memory_array[{ADDRESS[31:2],2'b01}];
    //         READDATA[23:16] = memory_array[{ADDRESS[31:2],2'b10}];
    //         READDATA[31:24] = memory_array[{ADDRESS[31:2],2'b11}];
    //     end
    // end

    // // injecting the instructions
    // always @ (posedge INJECT_CLK)
    // begin
    //     memory_array[INJECT_ADDR] = INJECT_DATA;
    // end

    initial
    begin
        $readmemb("../../build/test_prog.bin", memory_array);

        BUSYWAIT = 0;
        READ_ACCESS = 0;


        /*
        // Sample program given below. You may hardcode your software program here, or load it from a file:
        {memory_array[10'd3],  memory_array[10'd2],  memory_array[10'd1],  memory_array[10'd0]}  = 32'b00000000000001000000000000011001; // loadi 4 #25
        {memory_array[10'd7],  memory_array[10'd6],  memory_array[10'd5],  memory_array[10'd4]}  = 32'b00000000000001010000000000100011; // loadi 5 #35
        {memory_array[10'd11], memory_array[10'd10], memory_array[10'd9],  memory_array[10'd8]}  = 32'b00000010000001100000010000000101; // add 6 4 5
        {memory_array[10'd15], memory_array[10'd14], memory_array[10'd13], memory_array[10'd12]} = 32'b00000000000000010000000001011010; // loadi 1 90
        {memory_array[10'd19], memory_array[10'd18], memory_array[10'd17], memory_array[10'd16]} = 32'b00000011000000010000000100000100; // sub 1 1 4
        */

        //TODO: try to read the instruction from file

        // // loadi 0 0xFA
        // {memory_array[10'd3],  memory_array[10'd2],  memory_array[10'd1],  memory_array[10'd0]}    = 32'b00000100_000000000000000011111010;
        // // sll 1 0 0x02
        // {memory_array[10'd7],  memory_array[10'd6],  memory_array[10'd5],  memory_array[10'd4]}      = 32'b00001001_000000010000000000000010;
        // // srl 1 0 0x02
        // {memory_array[10'd11],  memory_array[10'd10],  memory_array[10'd9],  memory_array[10'd8]}    = 32'b00001010_000000010000000000000010;
        // // sra 1 0 0x02
        // {memory_array[10'd15],  memory_array[10'd14],  memory_array[10'd13],  memory_array[10'd12]}  = 32'b00001011_000000010000000000000010;
        // // ror 1 0 0x02
        // {memory_array[10'd19],  memory_array[10'd18],  memory_array[10'd17],  memory_array[10'd16]}  = 32'b00001100_000000010000000000000010;
        // // loadi 2 0x05
        // {memory_array[10'd23],  memory_array[10'd22],  memory_array[10'd21],  memory_array[10'd20]}      = 32'b00000101_00000010_00000000_00000101;
        // // loadi 3 0x0A
        // {memory_array[10'd27],  memory_array[10'd26],  memory_array[10'd25],  memory_array[10'd24]}      = 32'b00000101_00000011_00000000_00001010;
        // // mul 4 2 3
        // {memory_array[10'd31],  memory_array[10'd30],  memory_array[10'd29],  memory_array[10'd28]}      = 32'b00001101_00000100_00000010_00000011;
        // // loadi 0 0x0A
        // {memory_array[10'd35],  memory_array[10'd34],  memory_array[10'd33],  memory_array[10'd32]}     = 32'b00000101_00000000_00000000_00001010;
        // // swi 0 0X03
        // {memory_array[10'd39],  memory_array[10'd38],  memory_array[10'd37],  memory_array[10'd36]}      = 32'b00010001_00000000_00000000_00000011;
        // // lwi 1 0X03
        // {memory_array[10'd43],  memory_array[10'd42],  memory_array[10'd41],  memory_array[10'd40]}    = 32'b00001111_00000001_00000000_00000011;
        // // loadi 2 0X03
        // {memory_array[10'd47],  memory_array[10'd46],  memory_array[10'd45],  memory_array[10'd44]}  = 32'b00000101_00000010_00000000_00000011;
        // // loadi 3 0xAA
        // {memory_array[10'd51],  memory_array[10'd50],  memory_array[10'd49],  memory_array[10'd48]}  = 32'b00000101_00000011_00000000_10101010;
        // // swd 3 2
        // {memory_array[10'd55],  memory_array[10'd54],  memory_array[10'd53],  memory_array[10'd52]}  = 32'b00010000_00000000_00000011_00000010;
        // // lwd 4 2
        // {memory_array[10'd59],  memory_array[10'd58],  memory_array[10'd57],  memory_array[10'd56]}  = 32'b00001110_00000100_00000000_00000010;
    end

    //Detecting an incoming memory access
    always @(READ)
    begin
        BUSYWAIT = (READ)? 1 : 0;
        READ_ACCESS = (READ)? 1 : 0;
    end
    
    //Reading
    always @(posedge CLK)
    begin
        if(READ_ACCESS)
        begin
            READDATA[7:0]     = #40 memory_array[{ADDRESS,4'b0000}];
            READDATA[15:8]    = #40 memory_array[{ADDRESS,4'b0001}];
            READDATA[23:16]   = #40 memory_array[{ADDRESS,4'b0010}];
            READDATA[31:24]   = #40 memory_array[{ADDRESS,4'b0011}];
            READDATA[39:32]   = #40 memory_array[{ADDRESS,4'b0100}];
            READDATA[47:40]   = #40 memory_array[{ADDRESS,4'b0101}];
            READDATA[55:48]   = #40 memory_array[{ADDRESS,4'b0110}];
            READDATA[63:56]   = #40 memory_array[{ADDRESS,4'b0111}];
            READDATA[71:64]   = #40 memory_array[{ADDRESS,4'b1000}];
            READDATA[79:72]   = #40 memory_array[{ADDRESS,4'b1001}];
            READDATA[87:80]   = #40 memory_array[{ADDRESS,4'b1010}];
            READDATA[95:88]   = #40 memory_array[{ADDRESS,4'b1011}];
            READDATA[103:96]  = #40 memory_array[{ADDRESS,4'b1100}];
            READDATA[111:104] = #40 memory_array[{ADDRESS,4'b1101}];
            READDATA[119:112] = #40 memory_array[{ADDRESS,4'b1110}];
            READDATA[127:120] = #40 memory_array[{ADDRESS,4'b1111}];
            BUSYWAIT = 0;
            READ_ACCESS = 0;
        end
    end
    

endmodule