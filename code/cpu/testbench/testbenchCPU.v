/*
Author - W M D U Thilakarathna
Reg No - E/16/366
*/

`include "../cpu_module/cpu.v"
`include "../data_memory_module/data_memory.v"
`include "../data_memory_module/data_cache_memory.v"
`include "../instruction_memory_module/ins_memory.v"
`include "../instruction_memory_module/ins_cache_memory.v"
`timescale 1ns/100ps

module testbenchCPU;
    
    //input registers
    wire [31:0] INS;
    reg CLK, RESET; 
    // reg [7:0] INST_MEMORY [0:1023] ; //instruction array
    reg [7:0] INST_MEMORY [0:1023] ; //instruction array

    wire[31:0] PC;

    wire [3:0] memRead;   // memory read 
    wire [2:0] memWrite; // write enable 
    wire [31:0] ADDRESS; // address of the data memory
    wire [31:0] READ_DATA, WRITE_DATA; // read and write data of the memory module
    // TODO: Busy wait signal should be implemented in CPU
    wire BUSY_WAIT; // busy wait signal of the CPU

    // connections to connect main memory to the cache memory
    wire              MAIN_MEM_READ;
    wire              MAIN_MEM_WRITE;
    wire[27:0]        MAIN_MEM_ADDRESS;
    wire[127:0]       MAIN_MEM_WRITE_DATA;
    wire[127:0]       MAIN_MEM_READ_DATA;
    wire              MAIN_MEM_BUSY_WAIT;

    wire              INS_CACHE_BUSY_WAIT;
    wire insReadEn; // read enable for the instruction memory
    
    cpu mycpu(PC, INS, CLK, RESET, memRead, memWrite, ADDRESS, WRITE_DATA, READ_DATA, BUSY_WAIT, 
                insReadEn, INS_CACHE_BUSY_WAIT); //initialize the cpu
                
    data_cache_memory myCacheMemory(CLK, RESET, memRead, memWrite, ADDRESS, WRITE_DATA, READ_DATA, BUSY_WAIT,
              MAIN_MEM_READ, 
              MAIN_MEM_WRITE, 
              MAIN_MEM_ADDRESS,
              MAIN_MEM_WRITE_DATA, 
              MAIN_MEM_READ_DATA, 
              MAIN_MEM_BUSY_WAIT); // initialize the memory module   

    data_memory myDataMem (CLK, RESET, MAIN_MEM_READ, MAIN_MEM_WRITE, MAIN_MEM_ADDRESS,
            MAIN_MEM_WRITE_DATA, MAIN_MEM_READ_DATA, MAIN_MEM_BUSY_WAIT);

    // connections to the instruction memory
    wire              INS_MEM_READ;
    wire[27:0]        INS_MEM_ADDRESS;
    wire[127:0]       INS_MEM_READ_DATA;
    wire              INS_MEM_BUSY_WAIT;

    ins_cache_memory myInsCacheMemory(CLK, RESET, insReadEn, PC, INS, INS_CACHE_BUSY_WAIT,
              INS_MEM_READ, 
              INS_MEM_ADDRESS,
              INS_MEM_READ_DATA, 
              INS_MEM_BUSY_WAIT); // initialize the memory module   

    ins_memory myInsMem (CLK, INS_MEM_READ, INS_MEM_ADDRESS,
            INS_MEM_READ_DATA, INS_MEM_BUSY_WAIT);

    initial // instruction array
    begin
      //monitor command to check the content od the register file
      $monitor($time, " REG0: %b  REG1: %b  REG2: %b  REG3: %b  REG4: %b  REG5: %b  REG6: %b  REG7: %b ",
                          mycpu.myreg.REGISTERS[0], mycpu.myreg.REGISTERS[1], mycpu.myreg.REGISTERS[2], 
                          mycpu.myreg.REGISTERS[3], mycpu.myreg.REGISTERS[4], mycpu.myreg.REGISTERS[5], 
                          mycpu.myreg.REGISTERS[6], mycpu.myreg.REGISTERS[7]);
      // generate files needed to plot the waveform using GTKWave
      $dumpfile("../../build/cpu_wavedata.vcd");
      $dumpvars(0, testbenchCPU);
    end

    // assign #2 INS = {INST_MEMORY[PC + 3], INST_MEMORY[PC + 2], INST_MEMORY[PC + 1], INST_MEMORY[PC]}; //fetching instruction
       
    initial
    begin
        // load the instructions from the register file
        
        /*
         // loadi 0 0x0A
        {INST_MEMORY[3],INST_MEMORY[2],INST_MEMORY[1],INST_MEMORY[0]}     = 32'b00000101_00000000_00000000_00001010;
        // mov 1 0
        {INST_MEMORY[7],INST_MEMORY[6],INST_MEMORY[5],INST_MEMORY[4]}     = 32'b00000100_00000001_00000000_00000000;
        // loadi 2 0x05
        {INST_MEMORY[11],INST_MEMORY[10],INST_MEMORY[9],INST_MEMORY[8]}   = 32'b00000101_00000010_00000000_00000101;
        // sub 3 1 2
        {INST_MEMORY[15],INST_MEMORY[14],INST_MEMORY[13],INST_MEMORY[12]} = 32'b00000001_00000011_00000001_00000010;
        // or 3 1 2
        {INST_MEMORY[19],INST_MEMORY[18],INST_MEMORY[17],INST_MEMORY[16]} = 32'b00000011_00000011_00000001_00000010;
        // and 3 1 2
        {INST_MEMORY[23],INST_MEMORY[22],INST_MEMORY[21],INST_MEMORY[20]} = 32'b00000010_00000011_00000001_00000010;
        // add 3 1 2
        {INST_MEMORY[27],INST_MEMORY[26],INST_MEMORY[25],INST_MEMORY[24]} = 32'b00000000_00000001_00000001_00000010;
        // j 
        {INST_MEMORY[31],INST_MEMORY[30],INST_MEMORY[29],INST_MEMORY[28]} = 32'b00000110_11111110_00000000_00000000;
        */

        /*
        // loadi 0 0x0A
        {INST_MEMORY[3],INST_MEMORY[2],INST_MEMORY[1],INST_MEMORY[0]}     = 32'b00000101000000000000000000001010;
        // mov 1 0
        {INST_MEMORY[7],INST_MEMORY[6],INST_MEMORY[5],INST_MEMORY[4]}     = 32'b00000101000000110000000000011110;
        // loadi 2 0x05
        {INST_MEMORY[11],INST_MEMORY[10],INST_MEMORY[9],INST_MEMORY[8]}   = 32'b00000101000000010000000000000101;
        // sub 3 1 2
        {INST_MEMORY[15],INST_MEMORY[14],INST_MEMORY[13],INST_MEMORY[12]} = 32'b00000000000000000000000000000001;
        // or 3 1 2
        {INST_MEMORY[19],INST_MEMORY[18],INST_MEMORY[17],INST_MEMORY[16]} = 32'b00000111000000010000000000000011;
        // and 3 1 2
        {INST_MEMORY[23],INST_MEMORY[22],INST_MEMORY[21],INST_MEMORY[20]} = 32'b00000110111111010000000000000000;
        */
        
        /*
        // loadi 0 0xFA
        {INST_MEMORY[3],INST_MEMORY[2],INST_MEMORY[1],INST_MEMORY[0]}     = 32'b00000101_000000000000000011111010;
        // sll 1 0 0x02
        {INST_MEMORY[7],INST_MEMORY[6],INST_MEMORY[5],INST_MEMORY[4]}     = 32'b00001001_000000010000000000000010;
        // srl 1 0 0x02
        {INST_MEMORY[11],INST_MEMORY[10],INST_MEMORY[9],INST_MEMORY[8]}   = 32'b00001010_000000010000000000000010;
        // sra 1 0 0x02
        {INST_MEMORY[15],INST_MEMORY[14],INST_MEMORY[13],INST_MEMORY[12]} = 32'b00001011_000000010000000000000010;
        // ror 1 0 0x02
        {INST_MEMORY[19],INST_MEMORY[18],INST_MEMORY[17],INST_MEMORY[16]} = 32'b00001100_000000010000000000000010;
        // loadi 2 0x05
        {INST_MEMORY[23],INST_MEMORY[22],INST_MEMORY[21],INST_MEMORY[20]}     = 32'b00000101_00000010_00000000_00000101;
        // loadi 3 0x0A
        {INST_MEMORY[27],INST_MEMORY[26],INST_MEMORY[25],INST_MEMORY[24]}     = 32'b00000101_00000011_00000000_00001010;
        // mul 4 2 3
        {INST_MEMORY[31],INST_MEMORY[30],INST_MEMORY[29],INST_MEMORY[28]}     = 32'b00001101_00000100_00000010_00000011;
        // loadi 0 0x0A
        {INST_MEMORY[35],INST_MEMORY[34],INST_MEMORY[33],INST_MEMORY[32]}     = 32'b00000101_00000000_00000000_00001010;
        // swi 0 0X03
        {INST_MEMORY[39],INST_MEMORY[38],INST_MEMORY[37],INST_MEMORY[36]}     = 32'b00010001_00000000_00000000_00000011;
        // lwi 1 0X03
        {INST_MEMORY[43],INST_MEMORY[42],INST_MEMORY[41],INST_MEMORY[40]}   = 32'b00001111_00000001_00000000_00000011;
        // loadi 2 0X03
        {INST_MEMORY[47],INST_MEMORY[46],INST_MEMORY[45],INST_MEMORY[44]} = 32'b00000101_00000010_00000000_00000011;
        // loadi 3 0xAA
        {INST_MEMORY[51],INST_MEMORY[50],INST_MEMORY[49],INST_MEMORY[48]} = 32'b00000101_00000011_00000000_10101010;
        // swd 3 2
        {INST_MEMORY[55],INST_MEMORY[54],INST_MEMORY[53],INST_MEMORY[52]} = 32'b00010000_00000000_00000011_00000010;
        // lwd 4 2
        {INST_MEMORY[59],INST_MEMORY[58],INST_MEMORY[57],INST_MEMORY[56]} = 32'b00001110_00000100_00000000_00000010;
        */


        CLK = 1'b1;
        
        // assign values with time to input signals to see output 
        RESET = 1'b1;

        #25
        RESET = 1'b0;

        #6000
        $finish;
    end
    
    // clock signal generation
    always
    begin
      #10 CLK = ~CLK;
    end              

endmodule