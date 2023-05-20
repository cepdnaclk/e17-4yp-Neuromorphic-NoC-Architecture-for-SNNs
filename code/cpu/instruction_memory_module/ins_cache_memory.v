`timescale 1ns/100ps

module ins_cache_memory(
    clock, 
    reset, 
    read, 
    address, 
    readdata,
    busywait,
    MAIN_MEM_READ,
    MAIN_MEM_ADDRESS,
    MAIN_MEM_READ_DATA,
    MAIN_MEM_BUSY_WAIT
);

    input               clock;
    input               reset;
    input               read;
    input [31:0]        address; // taking the PC as the address
    output reg [31:0]   readdata;
    output reg          busywait;

    // main memory input outputs
    output              MAIN_MEM_READ;
    output  [27:0]      MAIN_MEM_ADDRESS;
    input   [127:0]     MAIN_MEM_READ_DATA;
    input               MAIN_MEM_BUSY_WAIT;

    // Declare cache memory array 256x8 -bits
    reg [127:0] data_array [8:0];
    // Declare tag array 256x8-bits
    reg [24:0] tag_array    [8:0];
    // Declare value bit array 356x8-bits
    reg [1:0]   valid_bit_array [8:0];

    parameter IDLE = 1'b0, MEM_READ = 1'b1;
    reg [1:0] state, next_state;

    // variables to handle state changes
    reg CURRENT_VALID;
    reg [24:0]  CURRENT_TAG;
    reg [31:0]  CURRENT_DATA;
    wire TAG_MATCH;

    // temporary variable to hold the data from the cache
    reg [31:0] temporary_data;


    // variables to hold the values of teh memory module
    reg MAIN_MEM_READ;
    reg [27:0] MAIN_MEM_ADDRESS;
    wire [127:0] MAIN_MEM_READ_DATA;
    wire MAIN_MEM_BUSY_WAIT;

    reg readCache; // reg to remember the read to cache signal until the posedge
    reg writeCache; // reg to write the write cache signal until the posedge

    reg writeCache_mem; // write enable signal to write to the cache mem after a memory read

    // decoding the address
    wire [24:0]  tag;
    wire [2:0]   index;
    wire [1:0]  offset;
    assign tag = address[31:7];
    assign index = address[6:4];
    assign offset = address[3:2];


    // loading data
    always @ (*)
    begin
        CURRENT_VALID = valid_bit_array[index];
        CURRENT_DATA = data_array[index];
        CURRENT_TAG = tag_array[index];
    end


    // tag matching 
    //assign #0.9 TAG_MATCH = (tag == CURRENT_TAG );
    assign TAG_MATCH = (tag == CURRENT_TAG );
    reg [127:0] temp;

    // putting data if read access
    always @(*)
    begin
        if(readaccess) // detect the idle read status
        begin
            temp = data_array[index];
            // fetching data
            case(offset)
                2'b00:
                    readdata = data_array[index][31:0];
                2'b01:
                    readdata = data_array[index][63:32];
                2'b10:
                    readdata = data_array[index][95:64];
                2'b11:
                    readdata = data_array[index][127:96];
            endcase 
        end
    end

    // Detecting an incoming memory acccess
    reg readaccess;
    always @ (read)
    begin
        if(read)
            begin
                busywait = 1'b1;
                readaccess = 1'b1;
            end
    end

    // combinational next state logic
    always @ (*)
    begin
        case(state)
            IDLE: 
                if(!CURRENT_VALID && (readaccess))
                    next_state = MEM_READ;
                else if (CURRENT_VALID && TAG_MATCH &&  (readaccess))
                    next_state = IDLE;
                else if (CURRENT_VALID && !TAG_MATCH && (readaccess))
                    next_state = MEM_READ;
            
            MEM_READ:
                if(MAIN_MEM_BUSY_WAIT)
                    next_state = MEM_READ;
                else
                    next_state = IDLE;
        endcase
    end
    

    // combinational output logic
    always @(*)
    begin
        if(readaccess)
        begin
            case(state)
                IDLE: 
                begin
                    // set main memory read and write signal to low
                    MAIN_MEM_READ = 1'b0;

                    if(readaccess && TAG_MATCH && CURRENT_VALID)
                        begin
                            readCache = 1'b1; // set read cache memory to high
                        end
                    else readCache = 1'b0; // set the readCache signal to zero
                end

                MEM_READ:
                begin
                    MAIN_MEM_READ = 1'b1;
                    // set the address to the main memory 
                    MAIN_MEM_ADDRESS = {tag, index};


                    if(!MAIN_MEM_BUSY_WAIT) writeCache_mem = 1'b1;
                    else writeCache_mem = 1'b0;

                end
            endcase
        end
    end

    integer i;

    //sequential logic for state transitioning
    always @ (posedge reset)
    begin
        if(reset)
        begin
            busywait = 1'b0;
            for(i=0;i<8;i=i+1) // resetting the registers
                begin
                    data_array[i] = 0;
                    valid_bit_array[i] =0;
                end
        end
    end

    // state change logic
    always@(posedge clock)
    begin
        if(!reset)
            state = next_state;
        else
            begin
                // set the busy wait signal to 0
                state = IDLE;
                next_state = IDLE;
            end
    end

    // writing cache after a memory read
    always @(posedge clock)
    begin
        if(writeCache_mem)
        begin
            // put the read data to the cache
            data_array[index] = MAIN_MEM_READ_DATA;
            tag_array[index] = tag;
            valid_bit_array[index] = 1'b1; // set the valid bit after loading data
            writeCache_mem = 1'b0;
        end
    end

    // to deassert and write back to the posedge
    always @ (posedge clock)
    begin
        if(readCache)
        begin
            busywait = 1'b0; // set the busy signal to zero 
            readCache = 1'b0; // pull the read signal to low
            readaccess = 1'b0; // pull the read access to signal to low
        end
    end

    /*  Cache Controller FSM End */
endmodule