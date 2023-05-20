/*
Program	: 256x8-bit data memory (4-Byte blocks)
Author	: Isuru Nawinne
Date    : 30/05/2020

Description	:

This program presents a primitive data memory module for CO224 Lab 6 - Part 2
This memory allows data to be read and written as 4-Byte blocks
*/

`timescale 1ns/100ps

module data_memory(
	clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
	busywait
);
input				clock;
input           	reset;
input           	read;
input           	write;
input[27:0]      	address;
input[127:0]     	writedata;
output reg [127:0]	readdata;
output reg      	busywait;

//TODO: can increase memory size because we have 32 bit vyte addressing space
//Declare memory array 256x8-bits 
reg [7:0] memory_array [255:0];

//Detecting an incoming memory access
reg readaccess, writeaccess;
always @(read, write)
begin
	busywait = (read || write)? 1 : 0;
	readaccess = (read && !write)? 1 : 0;
	writeaccess = (!read && write)? 1 : 0;
end

//Reading & writing
always @(posedge clock)
begin
	if(readaccess)
	begin
		//TODO set the delay to a ralistic value, #4 used for tesing		
		readdata[7:0]   = #4 memory_array[{address,4'b0000}];
		readdata[15:8]  = #4 memory_array[{address,4'b0001}];
		readdata[23:16] = #4 memory_array[{address,4'b0010}];
		readdata[31:24] = #4 memory_array[{address,4'b0011}];

        readdata[39:32] = #4 memory_array[{address,4'b0100}];
		readdata[47:40] = #4 memory_array[{address,4'b0101}];
		readdata[55:48] = #4 memory_array[{address,4'b0110}];
		readdata[63:56] = #4 memory_array[{address,4'b0111}];

        readdata[71:64] = #4 memory_array[{address,4'b1000}];
		readdata[79:72] = #4 memory_array[{address,4'b1001}];
		readdata[87:80] = #4 memory_array[{address,4'b1010}];
		readdata[95:88] = #4 memory_array[{address,4'b1011}];

        readdata[103:96]  = #4 memory_array[{address,4'b1100}];
		readdata[111:104] = #4 memory_array[{address,4'b1101}];
		readdata[119:112] = #4 memory_array[{address,4'b1110}];
		readdata[127:120] = #4 memory_array[{address,4'b1111}];
		busywait = 0;
		readaccess = 0;
	end
	if(writeaccess)
	begin
		memory_array[{address,4'b0000}] = #40 writedata[7:0];
		memory_array[{address,4'b0001}] = #40 writedata[15:8];
		memory_array[{address,4'b0010}] = #40 writedata[23:16];
		memory_array[{address,4'b0011}] = #40 writedata[31:24];
		
		memory_array[{address,4'b0100}] = #40 writedata[39:32];
		memory_array[{address,4'b0101}] = #40 writedata[47:40];
		memory_array[{address,4'b0110}] = #40 writedata[55:48];
		memory_array[{address,4'b0111}] = #40 writedata[63:56];

		memory_array[{address,4'b1000}] = #40 writedata[71:64];
		memory_array[{address,4'b1001}] = #40 writedata[79:72];
		memory_array[{address,4'b1010}] = #40 writedata[87:80];
		memory_array[{address,4'b1011}] = #40 writedata[95:88];

		memory_array[{address,4'b1100}] = #40 writedata[103:96];
		memory_array[{address,4'b1101}] = #40 writedata[111:104];
		memory_array[{address,4'b1110}] = #40 writedata[119:112];
		memory_array[{address,4'b1111}] = #40 writedata[127:120];
		busywait = 0;
		writeaccess = 0;
	end
end

integer i;

//Reset memory
always @(posedge reset)
begin
    if (reset)
    begin
        for (i=0;i<256; i=i+1)
            memory_array[i] = 0;
        
        busywait = 0;
		readaccess = 0;
		writeaccess = 0;
    end
end

// For implementation comment everything above and use this


// Detecting an incoming memory access
// reg readaccess, writeaccess;
// always @(read, write)
// begin
// 	//busywait = (read[3] || write[2])? 1 : 0;
// 	busywait = 1'b0;
// 	readaccess = (read[3] && !write[2])? 1 : 0;
// 	writeaccess = (!read[3] && write[2])? 1 : 0;
// end


// integer i;
// //Reading & writing
// always @(negedge clock)
// begin
// 	// resetting the memory
// 	if (reset)
//     begin
//         for (i=0;i<256; i=i+1)
//             memory_array[i] = 0;
        
//         // busywait = 0;
// 		// readaccess = 0;
// 		// writeaccess = 0;
//     end
// 	else
// 	begin
// 		if(readaccess)
// 		begin
// 			//TODO set the delay to a ralistic value, #4 used for tesing		
// 			readdata[7:0]     = memory_array[{address[31:2],2'b00}];
// 			readdata[15:8]    = memory_array[{address[31:2],2'b01}];
// 			readdata[23:16]   = memory_array[{address[31:2],2'b10}];
// 			readdata[31:24]   = memory_array[{address[31:2],2'b11}];
// 			// busywait = 0;
// 			// readaccess = 0;
// 		end
// 		if(writeaccess)
// 		begin
// 			memory_array[{address[31:2],2'b00}] = writedata[7:0];
// 			memory_array[{address[31:2],2'b01}] = writedata[15:8];
// 			memory_array[{address[31:2],2'b10}] = writedata[23:16];
// 			memory_array[{address[31:2],2'b11}] = writedata[31:24];

// 			// busywait = 0;
// 			// writeaccess = 0;
// 		end
// 	end
// end

endmodule
