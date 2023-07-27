`timescale 1ns/100ps

module instruction_memory (CLK, RESET, READ_ADDRESS, READ_DATA, BUSYWAIT);
    input CLK, RESET;
    input [31:0] READ_ADDRESS;
    output reg BUSYWAIT;
    output reg [31:0] READ_DATA;

    reg [7:0] memory_array [1023:0];    // 1024 x 8-bits memory array

    initial 
    begin
        BUSYWAIT <= 0;

        // Sample program given below. You may hardcode your software program here, or load it from a file:
        {memory_array[10'd3],  memory_array[10'd2],  memory_array[10'd1],  memory_array[10'd0]}  <= 32'b00000000000001000000000000011001; // loadi 4 #25
        {memory_array[10'd7],  memory_array[10'd6],  memory_array[10'd5],  memory_array[10'd4]}  <= 32'b00000000000001010000000000100011; // loadi 5 #35
        {memory_array[10'd11], memory_array[10'd10], memory_array[10'd9],  memory_array[10'd8]}  <= 32'b00000010000001100000010000000101; // add 6 4 5
        {memory_array[10'd15], memory_array[10'd14], memory_array[10'd13], memory_array[10'd12]} <= 32'b00000000000000010000000001011010; // loadi 1 90
        {memory_array[10'd19], memory_array[10'd18], memory_array[10'd17], memory_array[10'd16]} <= 32'b11111111000111111111000001101111; // sub 1 1 4
    end

    always @ (*)
    begin
        READ_DATA[7:0]      <= memory_array[{READ_ADDRESS[31:2],2'b00}];
        READ_DATA[15:8]     <= memory_array[{READ_ADDRESS[31:2],2'b01}];
        READ_DATA[23:16]    <= memory_array[{READ_ADDRESS[31:2],2'b10}];
        READ_DATA[31:24]    <= memory_array[{READ_ADDRESS[31:2],2'b11}];
    end

endmodule