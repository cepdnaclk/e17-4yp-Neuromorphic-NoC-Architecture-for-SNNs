`timescale 1ns/100ps

module data_cache_memory(
    clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait,
    MAIN_MEM_READ,
    MAIN_MEM_WRITE,
    MAIN_MEM_ADDRESS,
    MAIN_MEM_WRITE_DATA,
    MAIN_MEM_READ_DATA,
    MAIN_MEM_BUSY_WAIT
);

    input               clock;
    input               reset;
    input[3:0]          read;
    input[2:0]          write;
    input[31:0]         address;
    input[31:0]         writedata;
    output reg [31:0]   readdata;
    output reg          busywait;

    //main memory input outputs
    output              MAIN_MEM_READ;
    output              MAIN_MEM_WRITE;
    output[27:0]        MAIN_MEM_ADDRESS;
    output[127:0]       MAIN_MEM_WRITE_DATA;
    input[127:0]        MAIN_MEM_READ_DATA;
    input               MAIN_MEM_BUSY_WAIT;


    // Declare cache memory array 256x8 bits
    reg [127:0] data_array  [8:0];
    // Declare tag array 256x8 - bits
    reg [24:0] tag_array    [8:0];
    // Declare dirty bit array 256x8-bits
    reg [1:0] dirty_bit_array   [8:0];
    // Declare valid bit array 256x8-bits
    reg [1:0] valid_bit_array [8:0];

    parameter IDLE = 2'b00, MEM_READ = 2'b01,MEM_WRITE = 2'b10;
    reg [1:0] state, next_state;

    // variables to handle state changesc
    reg CURRENT_DIRTY, CURRENT_VALID;
    reg [24:0] CURRENT_TAG;
    reg [127:0] CURRENT_DATA;
    wire TAG_MATCH;

    // temporary variable to hold the data from the cache 
    reg [31:0] temporary_data;


    // variables to hold the values of the memory module
    reg MAIN_MEM_READ, MAIN_MEM_WRITE;
    reg [27:0] MAIN_MEM_ADDRESS;
    reg [127:0] MAIN_MEM_WRITE_DATA;
    wire [127:0] MAIN_MEM_READ_DATA;
    wire MAIN_MEM_BUSY_WAIT;

    reg [31:0] cache_readdata, cache_writedata;
    reg readCache; // reg to remember the read to cache signal until the posedge
    reg writeCache; // reg to write 

    reg writeCache_mem; // write enable signal to write to the cache mem after a memory read



    // decoding address
    wire [24:0] tag;
    wire [2:0] index;
    wire [1:0] offset, byte_offset;

    assign tag = address[31:7];
    assign index = address[6:4];
    assign offset = address[3:2];
    assign byte_offset = address[1:0];


    always @(*) begin
        case(read[2:0])
            3'b000: //Load Byte
                case(byte_offset)
                    2'b00:
                        readdata = {{24{cache_readdata[7]}}, cache_readdata[7:0]};
                    2'b01:
                        readdata = {{24{cache_readdata[15]}}, cache_readdata[15:8]};
                    2'b10:
                        readdata = {{24{cache_readdata[23]}}, cache_readdata[23:16]};
                    2'b11:
                        readdata = {{24{cache_readdata[31]}}, cache_readdata[31:24]};
                endcase
            3'b001: // LH
                case(byte_offset)
                    2'b00:
                        readdata = {{16{cache_readdata[15]}}, cache_readdata[15:0]};
                    2'b01:
                        readdata = {{16{cache_readdata[31]}}, cache_readdata[31:16]};
                endcase
            3'b010: // LW
                readdata = cache_readdata;
            3'b100: //LBU
                case(byte_offset)
                    2'b00:
                        readdata  = {24'b0, cache_readdata[7:0]};
                    2'b01:
                        readdata  = {24'b0, cache_readdata[15:8]};
                    2'b10:
                        readdata  = {24'b0, cache_readdata[23:16]};
                    2'b11:
                        readdata  = {24'b0, cache_readdata[31:24]};
                endcase
            3'b001: // LHU
                case(byte_offset)
                    2'b00:
                        readdata = {16'b0, cache_readdata[15:0]};
                    2'b01:
                        readdata = {16'b0, cache_readdata[31:16]};
                endcase
        endcase
    end


    //loading data
    always @(*)
    begin
        //#1 //loading the current calues
        CURRENT_VALID   = valid_bit_array[index];
        CURRENT_DIRTY   = dirty_bit_array[index];
        CURRENT_DATA    = data_array[index];
        CURRENT_TAG     = tag_array[index];
    end


    // tag matching
    // TODO: check timing
    //assign #0.9 TAG_MATCH = ~(tag[2]^CURRENT_TAG[2]) && ~(tag[1]^CURRENT_TAG[1]) && ~(tag[0]^CURRENT_TAG[0]);
    assign TAG_MATCH = ~(tag[2]^CURRENT_TAG[2]) && ~(tag[1]^CURRENT_TAG[1]) && ~(tag[0]^CURRENT_TAG[0]);


    wire [127:0] block;
    assign block = data_array[3'b001];
    // puttign data if read access
    always@(*)
    begin
        if (readaccess) // detect th idle read status
        //#1
        begin
            // fetching data
            case(offset)
                2'b00:
                    cache_readdata = data_array[index][31:0];
                2'b01:
                    cache_readdata = data_array[index][63:32];
                2'b10:
                    cache_readdata = data_array[index][95:64];
                2'b11:
                    cache_readdata = data_array[index][127:96];
            endcase
        end
    end

    // Detecting an incomming memory acces
    reg readaccess, writeaccess;
    always@(read, write)
    begin
        // TODO changed to handle undefined state
        if(!(read === 4'bx | write === 3'bx))
            busywait = (read[3] || write[2]);

        else
            busywait = 1'b0;
        readaccess = (read[3] && !write[2]) ? 1:0;
        writeaccess = (!read[3] && write[2]) ? 1:0;

    end

    // combinational next state loic
    always@(*)
    begin
        case(state)
            IDLE: 
                if (!CURRENT_VALID && (readaccess || writeaccess))
                    next_state = MEM_READ;
                else if (CURRENT_VALID && TAG_MATCH && (readaccess || writeaccess))
                    next_state = IDLE;
                else if (CURRENT_VALID && !CURRENT_DIRTY && !TAG_MATCH && (readaccess || writeaccess))
                    next_state = MEM_READ;
                else if (CURRENT_VALID && CURRENT_DIRTY & !TAG_MATCH && (readaccess || writeaccess))
                    next_state = MEM_WRITE;

            MEM_READ:
                if(MAIN_MEM_BUSY_WAIT)
                    next_state = MEM_READ;
                else
                    next_state = IDLE;

            MEM_WRITE:
                if(MAIN_MEM_BUSY_WAIT)
                    next_state = MEM_WRITE;

                else
                    begin
                        // next_state = IDLE;
                        if (CURRENT_VALID && !TAG_MATCH)
                            next_state = MEM_READ;
                        else
                            next_state = IDLE;
                    end
        endcase
    end 

    // combintaional output logic 
    always @(*)
    begin
        if(readaccess || writeaccess)
        begin
            case(state)
                IDLE:
                begin 
                    // set main memory read and write signal to low
                    MAIN_MEM_READ = 1'b0;
                    MAIN_MEM_WRITE = 1'b0;

                    if (readaccess && TAG_MATCH && CURRENT_VALID)
                    begin
                        readCache = 1'b1; // set read cache memory to high 
                        // readdata = tempory_data; // uotput data What is this?
                    end
                    else readCache = 1'b0;

                    if(writeaccess && TAG_MATCH && CURRENT_VALID) // detect the idle write state
                    begin
                        writeCache = 1'b1; // set write to cache memory to high
                    end
                    else writeCache = 1'b0; // set the write cache to signal to zero

                end

                MEM_READ:
                begin
                    MAIN_MEM_READ = 1'b1;
                    MAIN_MEM_WRITE = 1'b0;
                    //set the address to the main memory 
                    MAIN_MEM_ADDRESS = {tag, index};

                    if(!MAIN_MEM_BUSY_WAIT) writeCache_mem = 1'b1;
                    else writeCache_mem = 1'b0;
                end

                MEM_WRITE:
                begin
                    MAIN_MEM_READ = 1'b0;
                    MAIN_MEM_WRITE = 1'b1;
                    // set the address to the main memory
                    MAIN_MEM_ADDRESS = {tag_array[index], index};
                    // set data to be written 
                    MAIN_MEM_WRITE_DATA = data_array[index];
                    if(!MAIN_MEM_BUSY_WAIT)
                    begin
                        valid_bit_array[index] = 1'b1;// set the valid bit after loading data
                        dirty_bit_array[index] = 1'b0;// set the valid bit after writnig data
                    end
                end
            endcase
        end
    end

    integer i;

    // sequential logic for state transitioning

    always @(posedge reset)
    begin
        if(reset)
        begin
            busywait = 1'b0;
            for (i=0;i<8;i=i+1) // resetting the registers
                begin
                    data_array[i] = 0;
                    valid_bit_array[i] = 0;
                    dirty_bit_array[i] = 0;
                end
        end
    end


    // state change logic
    always @ (posedge clock)
    begin
        if(!reset)
            state = next_state;
        else
            begin
                state = IDLE;
                next_state = IDLE;
            end
    end


    // writing cache after a memory read
    always @ (posedge clock)
    begin
        if(writeCache_mem)
        begin
            //#1;
            // put the read data to the cache
            data_array[index] = MAIN_MEM_READ_DATA;
            tag_array[index] = tag;
            valid_bit_array[index] = 1'b1; // set the valid bit after loading data
            dirty_bit_array[index] = 1'b0; // set the dirty bit after loading data
            writeCache_mem = 1'b0;
        end
    end

    // calculating the byte mask
    reg [31:0] write_mask;
    always@(*)
    begin
        case (write[1:0])
            2'b00: // SB
                case(byte_offset)
                    2'b00:
                        begin
                            write_mask = {{24{1'b1}}, 8'b0};
                            cache_writedata = writedata;
                        end
                    2'b01:
                        begin
                            write_mask = {{16{1'b1}}, 8'b0, {8{1'b1}}};
                            cache_writedata = writedata << 8;
                        end
                    2'b10:
                        begin
                            write_mask = {{8{1'b1}}, 8'b0, {16{1'b1}}};
                            cache_writedata = writedata << 16;
                        end
                    2'b11:
                        begin
                            write_mask = {8'b0, {24{1'b1}}};
                            cache_writedata = writedata << 24;
                        end
                endcase
            
            2'b01: //SH
                case(byte_offset)
                    2'b00:
                        begin
                            write_mask = {{16{1'b1}}, 16'b0};
                            cache_writedata = writedata;
                        end
                    2'b10:
                        begin
                            write_mask = {16'b0, {16{1'b1}}};
                            cache_writedata = writedata << 16;
                        end
                endcase
            
            2'b10: //SW 
                begin
                    write_mask = 32'b0;
                    cache_writedata = writedata;
                end
        endcase
    end


    // to deassert and write back to the posedge
    always @ (posedge clock)
    begin
        if (writeCache)
        begin
            case(offset) // writing to the register
                2'b00:
                    begin
                        data_array[index][31:0] = (data_array[index][31:0] & write_mask);
                        data_array[index][31:0] = (data_array[index][31:0] | cache_writedata);
                    end
                2'b01:
                    begin
                        data_array[index][63:32] = (data_array[index][63:32] & write_mask);
                        data_array[index][63:32] = (data_array[index][63:32] | cache_writedata);
                    end
                2'b10:
                    begin
                        data_array[index][95:64] = (data_array[index][95:64] & write_mask);
                        data_array[index][95:64] = (data_array[index][95:64] | cache_writedata);
                    end
                2'b11:
                    begin
                        data_array[index][127:96] = (data_array[index][127:96] & write_mask);
                        data_array[index][127:96] = (data_array[index][127:96] | cache_writedata);
                    end
            endcase


            dirty_bit_array[index] = 1'b1; // set dirty bit because data not consistent with the memory 
            writeCache = 1'b0; // pull the write signal to low
            busywait = 1'b0; // set the busy wait signal to zero

        end

        if (readCache)
        begin
            busywait = 1'b0; // set the busy wait signal to zero 
            readCache = 1'b0; // pull the read signal to low
        end

    end
    /* Cache Controller FSM End  */
endmodule 