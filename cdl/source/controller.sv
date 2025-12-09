`timescale 1ns / 10ps

module controller #(
    // parameters

) (
    input logic clk, n_rst,
//  input  logic [3:0]  read_valid,    // pulses from sram_buffer
//  input  logic [3:0]  write_done,    // pulses from sram_buffer on write complete    
    input logic load_weights, start_inference, //from subordinate control reg 
    input logic load_weights_en, load_inputs_en, //from subordinate
    input logic activation_ready, //from activation block
    input  logic [63:0] input_reg,
    input  logic [63:0] weight_reg,
    input logic [63:0] read_data0, read_data1, read_data2, read_data3,
    input logic [63:0] activations, //from activation block
    input logic activated, //TODO:from activation block  -> INSTEAD OF ACTIVATION READY (CHANGE!!)
    // input logic [7:0] num_outputs,

    output logic controller_busy, data_ready, //to subordinate
    output logic ren, wen, //to sram buffer
    output logic start_weights, start_array,//to systolic array
    // output logic [7:0] zout_en, //to systolic array 
    output logic [63:0]  output_reg,
    output logic weights_done, 
    output logic invalid, //TODO: extra output provided if needed
    // output logic [63:0] write_data,      //NEED TO SPLIT THIS UP INTO 4 DIFFERENT WRITE SIGNALS -> SRAM RESTARTS WITH NEW DATA ON THE BUS 
    output logic [63:0] write_data0, write_data1, write_data2, write_data3, //to each of the srams 
    output logic cs0,cs1,cs2,cs3, //chip select to choose btw the 4 srams
    output logic [9:0] addr,
    output logic [63:0] systolic_data,
    output logic inputs_done, //needed? 
    output logic occupancy_err, //to subordinate
    output logic [7:0] num_input // to systolic array 
    //ADD SIGNAL FOR HOW MANY INPUTS TO THE SYSTOLIC ARRAY  -> done 
    //CHANGE LOAD -> START_WEIGHTS -> LOAD_INPUTS ->START_ARRAY -> done
);


logic enable_counter_num_input_chunks;
localparam [3:0] MAX_INPUT_CHUNKS = 'hF; //d16
logic [3:0] num_input_chunks;
logic input_chunks_rollover;
logic no_more_inputs;
logic counter_num_input_chunks_clr;

logic enable_counter_num_input;
localparam [7:0] MAX_INPUTS = 'd128; //d128
logic counter_num_input_clr;
logic unused_num_input_rollover;

logic [7:0] unused_compute_counter;
logic compute_counter_enable;
logic compute_rollover;
logic compute_counter_clr;

logic buffout_clr;
logic buffout_rollover;
logic [7:0] unused_buffout_counter;
logic buffout_counter_enable;

logic capture_clr;
logic capture_rollover;
logic [7:0] unused_capture_counter;
logic capture_counter_enable;



// output logic [63:0] write_data0, write_data1, write_data2, write_data3; //to each of the srams 

// logic sram_wait_done;
// logic [1:0] sram_counter;
//need to handle 3 cycle read delay to the systolic array and subordinate  - OR NOT? -> nope :)


localparam  SRAM_WEIGHT_BASE = 10'h0;
localparam  SRAM_INPUT_BASE = 10'h100; 
localparam  SRAM_OUTPUT_BASE = 10'h300;
    
    typedef enum logic [6:0] {
    IDLE,
    FETCH_WEIGHT_REG0, FETCH_WEIGHT_REG1, FETCH_WEIGHT_REG2, FETCH_WEIGHT_REG3, FETCH_WEIGHT_REG4, 
    FETCH_WEIGHT_REG5, FETCH_WEIGHT_REG6, FETCH_WEIGHT_REG7,
    WAIT_SRAM_READ0,WAIT_SRAM_READ1,/*WAIT_SRAM_READ2,WAIT_SRAM_READ3,*/
    START_LOAD_COLUMN0,START_LOAD_COLUMN1,START_LOAD_COLUMN2,START_LOAD_COLUMN3,
    /*START_LOAD_COLUMN4,START_LOAD_COLUMN5,START_LOAD_COLUMN6,START_LOAD_COLUMN7,*/
    LOAD_COLUMN0, LOAD_COLUMN1, LOAD_COLUMN2, LOAD_COLUMN3,
    LOAD_COLUMN4, LOAD_COLUMN5, LOAD_COLUMN6, LOAD_COLUMN7,/* LOAD_COLUMN7_DUMMY,*/
    WAIT_INF,
    FETCH_INPUT_REG0,FETCH_INPUT_REG1, FETCH_INPUT_REG2, FETCH_INPUT_REG3,
    FETCH_INPUT_REG4, FETCH_INPUT_REG5, FETCH_INPUT_REG6, FETCH_INPUT_REG7,
    START_COMPUTE_ROW0,START_COMPUTE_ROW1,START_COMPUTE_ROW2,START_COMPUTE_ROW3,START_COMPUTE_ROW4,
    COMPUTE_ROW0, COMPUTE_ROW1, COMPUTE_ROW2, COMPUTE_ROW3,COMPUTE_ROW3_DUMMY,
    COMPUTE_ROW4, COMPUTE_ROW5, COMPUTE_ROW6, COMPUTE_ROW7, /*COMPUTE_ROW7_DUMMY,*/
    WAIT_ACTIVATION_READY,
    BUFF_OUTPUT0, BUFF_OUTPUT1, BUFF_OUTPUT2, BUFF_OUTPUT3, BUFF_OUTPUT4,
    BUFF_OUTPUT5, BUFF_OUTPUT6, BUFF_OUTPUT7,
    WAIT_OUT_READ0, WAIT_OUT_READ1, WAIT_OUT_READ2, WAIT_OUT_READ3,
    START_CAPTURE_OUT0,START_CAPTURE_OUT1,START_CAPTURE_OUT2,START_CAPTURE_OUT3,START_CAPTURE_OUT4,
    CAPTURE_OUT0, CAPTURE_OUT1, CAPTURE_OUT2, CAPTURE_OUT3, CAPTURE_OUT4, CAPTURE_OUT3_DUMMY,
    CAPTURE_OUT5, CAPTURE_OUT6, CAPTURE_OUT7,
    ERR      //added err state for bufffer occupancy err
} state_t;

state_t state, next_state;


always_ff @(posedge clk or negedge n_rst) begin
        if(!n_rst)
            state <= IDLE;
        else
            state <= next_state;
end

//next state logic 
 always_comb begin
        next_state = state;
        case(state)
            IDLE: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG0;
                else if(load_inputs_en) 
                next_state = FETCH_INPUT_REG0;
            end
            FETCH_WEIGHT_REG0: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG1;
                else if (load_weights)  //todo: TAKES 8 WEIGHTS BUT ACCOUNTS FOR STALL 
                next_state = IDLE;
            end
            FETCH_WEIGHT_REG1: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG2;
                else if (load_weights)
                next_state = IDLE;
            end
            FETCH_WEIGHT_REG2: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG3;
                else if (load_weights)
                next_state = IDLE;
            end            
            FETCH_WEIGHT_REG3: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG4;
                else if (load_weights)
                next_state = IDLE;                
               
            end            
            FETCH_WEIGHT_REG4: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG5;
                else if (load_weights)
                next_state = IDLE;                
            end
            FETCH_WEIGHT_REG5: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG6;
                else if (load_weights)
                next_state = IDLE;                
              
            end
            FETCH_WEIGHT_REG6: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT_REG7;
                else if (load_weights)
                next_state = IDLE;                
              
            end
            FETCH_WEIGHT_REG7: begin
                if(load_weights_en)
                next_state = ERR; //more than 8 weights
                else if(load_weights) 
                next_state = START_LOAD_COLUMN0;
            end
            START_LOAD_COLUMN0: begin
                next_state = START_LOAD_COLUMN1;
            end
            START_LOAD_COLUMN1: begin
                next_state = START_LOAD_COLUMN2;
            end
            START_LOAD_COLUMN2: begin
                next_state = START_LOAD_COLUMN3;
            end
            START_LOAD_COLUMN3: begin
                next_state = WAIT_SRAM_READ0;
            end
          
            // START_LOAD_COLUMN4: begin
            //     next_state = START_LOAD_COLUMN5;
            // end
            // START_LOAD_COLUMN5: begin
            //     next_state = START_LOAD_COLUMN6;
            // end
            // START_LOAD_COLUMN6: begin
            //     next_state = START_LOAD_COLUMN7;
            // end
            // START_LOAD_COLUMN7: begin
            //     next_state = LOAD_COLUMN0;
            // end            

            WAIT_SRAM_READ0: begin
                next_state = LOAD_COLUMN0;
            end
            // WAIT_SRAM_READ1: begin
            //     next_state = LOAD_COLUMN0;
            // end
            // WAIT_SRAM_READ2: begin
            //     next_state = WAIT_SRAM_READ3;
            // end
            // WAIT_SRAM_READ3: begin
            //     next_state = LOAD_COLUMN0;
            // end            
            LOAD_COLUMN0: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN0;
                // else                
                    next_state = LOAD_COLUMN1;                
            end
            LOAD_COLUMN1: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN1;
                // else 
                    next_state = LOAD_COLUMN2;
            end    
            LOAD_COLUMN2: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN2;
                // else                 
                    next_state = LOAD_COLUMN3;
            end
            LOAD_COLUMN3: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN3;
                // else           
                    next_state = WAIT_SRAM_READ1;
            end 
            WAIT_SRAM_READ1: begin
                next_state = LOAD_COLUMN4;
            end
            LOAD_COLUMN4: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN4;
                // else                 
                next_state = LOAD_COLUMN5;
            end
            LOAD_COLUMN5: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN5;
                // else                 
                next_state = LOAD_COLUMN6;
            end    
            LOAD_COLUMN6: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN6;
                // else                 
                next_state = LOAD_COLUMN7;
            end
            LOAD_COLUMN7: begin
                // if (!sram_wait_done)
                //     next_state = LOAD_COLUMN7;
                // else                 
                next_state = WAIT_INF;
            end       
            // LOAD_COLUMN7_DUMMY: begin
            //     // if (!sram_wait_done)
            //     //     next_state = LOAD_COLUMN7;
            //     // else                 
            //     next_state = WAIT_INF;
            // end                           
            WAIT_INF: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG0;
                else 
                next_state = IDLE; //no inputs
            end
            FETCH_INPUT_REG0: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG1;
                else 
                if(start_inference)
                next_state = IDLE;  //CAN'T HANDLE NON MULTIPLE OF 8S
                // else 
                // next_state = IDLE; //no inputs
            end
            FETCH_INPUT_REG1: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG2;
                else 
                if(start_inference)
                next_state = IDLE;                
            end
            FETCH_INPUT_REG2: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG3;
                else 
                if(start_inference)
                next_state = IDLE;                
            end
            FETCH_INPUT_REG3: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG4;
                else 
                if(start_inference)
                next_state = IDLE;                
            end
            FETCH_INPUT_REG4: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG5;
                else 
                if(start_inference)
                next_state = IDLE;                
            end
            FETCH_INPUT_REG5: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG6;
                else 
                if(start_inference)
                next_state = IDLE;                
            end
            FETCH_INPUT_REG6: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT_REG7;
                else 
                if(start_inference)
                next_state = IDLE;                
            end
            FETCH_INPUT_REG7: begin
            // if (num_input_chunks[3] && !load_inputs_en) begin //checking for bit 3 and no more new write to input reg -> using chunks instead now
            if (load_inputs_en) begin
                if(!no_more_inputs)  //else condition handled in subordinate 
                    next_state = FETCH_INPUT_REG0;
                if(no_more_inputs)
                    next_state = ERR; //send occupancy error to subordinate
            end
            else begin
                if(start_inference)
                next_state = START_COMPUTE_ROW0;
            end
            end
            START_COMPUTE_ROW0: begin
            if (!compute_rollover) 
                next_state = START_COMPUTE_ROW1;
            else 
                next_state = WAIT_ACTIVATION_READY;      
            end
            START_COMPUTE_ROW1: begin
            if (!compute_rollover) 
                next_state = START_COMPUTE_ROW2;
            else 
                next_state = WAIT_ACTIVATION_READY;      
                
            end
            START_COMPUTE_ROW2: begin
            if (!compute_rollover) 
                next_state = START_COMPUTE_ROW3;
            else 
                next_state = WAIT_ACTIVATION_READY;      
            end
            START_COMPUTE_ROW3: begin
            if (!compute_rollover) 
                next_state = START_COMPUTE_ROW4;
            else 
                next_state = WAIT_ACTIVATION_READY;      
            end
            START_COMPUTE_ROW4: begin
            if (!compute_rollover) 
                next_state = COMPUTE_ROW0;
            else 
                next_state = WAIT_ACTIVATION_READY;      
            end
            COMPUTE_ROW0: begin  
                // if (!sram_wait_done)    
                // next_state = COMPUTE_ROW0;
                // else begin
                    // if (!compute_rollover)     //if non multiple 8 -> then how to handle next state?
                    next_state = COMPUTE_ROW1;
                    // else 
                    //     next_state = ERR; //no outputs from activation block
                // end
            end
            COMPUTE_ROW1: begin
                // if (!sram_wait_done)    
                // next_state = COMPUTE_ROW1;
                // else begin
                    // if (!compute_rollover)  
                    next_state = COMPUTE_ROW2;
                    // else 
                    //     next_state = WAIT_ACTIVATION_READY;
                // end
            end            
            COMPUTE_ROW2: begin
                // if (!sram_wait_done)    
                // next_state = COMPUTE_ROW2;
                // else begin
                    // if (!compute_rollover)  
                    next_state = COMPUTE_ROW3;
                    // else 
                    //     next_state = WAIT_ACTIVATION_READY;
                // end
            end
            COMPUTE_ROW3: begin
                // if (!sram_wait_done)    
                // next_state = COMPUTE_ROW3;
                // else begin
                    // if (!compute_rollover)  
                    next_state = COMPUTE_ROW3_DUMMY;
                    // else 
                    //     next_state = WAIT_ACTIVATION_READY;
                // end
            end
            COMPUTE_ROW3_DUMMY: begin
                // if (!compute_rollover)    //-> changed the rollover based on number of inputs  
                next_state = COMPUTE_ROW4;
                // else 
                //     next_state = COMPUTE_ROW7_DUMMY;
            end            
            COMPUTE_ROW4: begin
                // if (!sram_wait_done)    
                // next_state = COMPUTE_ROW4;
                // else 
                    // if (!compute_rollover)  
                    next_state = COMPUTE_ROW5;
                    // else 
                    //     next_state = WAIT_ACTIVATION_READY;
                    // end
            end
            COMPUTE_ROW5: begin
                // if (!sram_wait_done)    
                // next_state = COMPUTE_ROW5;
                // else begin
                    // if (!compute_rollover)  
                    next_state = COMPUTE_ROW6;
                    // else 
                    //     next_state = WAIT_ACTIVATION_READY;
                // end
            end
            COMPUTE_ROW6: begin
                // if (!sram_wait_done)    
                // next_state = COMPUTE_ROW6;
                // else begin
                    // if (!compute_rollover)  
                    next_state = COMPUTE_ROW7;
                    // else 
                    //     next_state = WAIT_ACTIVATION_READY;
                // end
            end
            COMPUTE_ROW7: begin
                if (!compute_rollover)    //-> changed the rollover based on number of inputs  
                next_state = COMPUTE_ROW0;
                else 
                    next_state = WAIT_ACTIVATION_READY;
            end
            // COMPUTE_ROW7_DUMMY: begin
            //     // if (!compute_rollover)    //-> changed the rollover based on number of inputs  
            //     // next_state = COMPUTE_ROW0;
            //     // else 
            //         next_state = WAIT_ACTIVATION_READY;
            // end
            WAIT_ACTIVATION_READY: begin
                if(activated)
                    next_state = BUFF_OUTPUT0;
            end            

            BUFF_OUTPUT0: begin
                if(/*!buffout_rollover && */activated)
                next_state =BUFF_OUTPUT1;
                // else 
                // next_state = CAPTURE_OUT0;
            end
            BUFF_OUTPUT1: begin
                if(/*!buffout_rollover && */ activated)
                next_state =BUFF_OUTPUT2;
                // else 
                // next_state = CAPTURE_OUT0;
            end
            BUFF_OUTPUT2: begin
                if(/*!buffout_rollover && */activated)
                next_state =BUFF_OUTPUT3;
                // else 
                // next_state = CAPTURE_OUT0;
            end
            BUFF_OUTPUT3: begin
                if(/*!buffout_rollover && */activated)
                next_state =BUFF_OUTPUT4;
                // else 
                // next_state = CAPTURE_OUT0;
            end
            BUFF_OUTPUT4: begin
                if(/*!buffout_rollover && */activated)
                next_state =BUFF_OUTPUT5;
                // else 
                // next_state = CAPTURE_OUT0;
            end
            BUFF_OUTPUT5: begin
                if(/*!buffout_rollover && */ activated)
                next_state =BUFF_OUTPUT6;
                // else 
                // next_state = CAPTURE_OUT0;
            end
            BUFF_OUTPUT6: begin
                if(/*!buffout_rollover && */ activated)
                next_state =BUFF_OUTPUT7;
                // else 
                // next_state = CAPTURE_OUT0;
            end
            BUFF_OUTPUT7: begin
                if(!buffout_rollover && activated)
                next_state =BUFF_OUTPUT0;
                else 
                next_state = WAIT_OUT_READ0;
            end 
            WAIT_OUT_READ0: begin
                next_state = WAIT_OUT_READ1;
            end
            WAIT_OUT_READ1: begin
                next_state = WAIT_OUT_READ2;
            end
            WAIT_OUT_READ2: begin
                next_state = WAIT_OUT_READ3;
            end
            WAIT_OUT_READ3: begin
                next_state = START_CAPTURE_OUT0;
            end

            START_CAPTURE_OUT0: begin
                    // if(!capture_rollover)
                next_state = START_CAPTURE_OUT1;
            // else 
            //     next_state = WAIT_ACTIVATION_READY;      
            end
            START_CAPTURE_OUT1: begin
                    // if(!capture_rollover)
                next_state = START_CAPTURE_OUT2;
            // else 
            //     next_state = WAIT_ACTIVATION_READY;      
                
            end
            START_CAPTURE_OUT2: begin
                    // if(!capture_rollover)
                next_state = START_CAPTURE_OUT3;
            // else 
            //     next_state = WAIT_ACTIVATION_READY;      
            end
            START_CAPTURE_OUT3: begin
                    // if(!capture_rollover)
                next_state = START_CAPTURE_OUT4;
            // else 
            //     next_state = WAIT_ACTIVATION_READY;      
            end
            START_CAPTURE_OUT4: begin
                    // if(!capture_rollover)
                next_state = CAPTURE_OUT0;
            // else 
            //     next_state = WAIT_ACTIVATION_READY;      
            end
            
            CAPTURE_OUT0: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT0;
                // else begin
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT1;
                    // else
                    // next_state=IDLE;
                // end
            end
            CAPTURE_OUT1: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT1;
                // else begin
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT2;
                    // else
                    // next_state=IDLE;
                // end
            end
            CAPTURE_OUT2: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT2;
                // else begin
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT3;
                    // else
                    // next_state=IDLE;
                // end
            end
            CAPTURE_OUT3: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT3;
                // else begin
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT3_DUMMY;
                    // else
                    // next_state=IDLE;
                // end
            end
            CAPTURE_OUT3_DUMMY: begin
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT4;  
            end
            CAPTURE_OUT4: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT4;
                // else begin
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT5;
                    // else
                    // next_state=IDLE;
                // end
            end
            CAPTURE_OUT5: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT5;
                // else begin                
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT6;
                    // else
                    // next_state=IDLE;
                // end
            end
            CAPTURE_OUT6: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT6;
                // else begin                
                    // if(!capture_rollover)
                    next_state =CAPTURE_OUT7;
                    // else
                    // next_state=IDLE;
                // end
            end
            CAPTURE_OUT7: begin
                // if (!sram_wait_done)    
                // next_state = CAPTURE_OUT7;
                // else begin
                    if(!capture_rollover)
                    next_state =CAPTURE_OUT0;
                    else
                    next_state=IDLE;
                // end
            end
            ERR: begin 
                next_state = IDLE;
            end
            default: begin
            end
        endcase
    end


//output logic 
 always_comb begin
        wen = 1'b0;
        controller_busy = 1'b0;
        ren = 1'b0;
        weights_done =1'b0;
        cs0 =1'b0;
        cs1 =1'b0;
        cs2 =1'b0;
        cs3 =1'b0;
        invalid = 1'b0;
        start_weights = 1'b0;
        start_array = 1'b0;
        data_ready = 1'b0;
        systolic_data = 64'b0;
        output_reg = 64'b0;
        // write_data = 64'b0;
        write_data0 = 64'b0;
        write_data1 = 64'b0;
        write_data2 = 64'b0;
        write_data3 = 64'b0;
        // activated = 1'b0;
        addr = 10'b0;
        enable_counter_num_input = 1'b0;
        inputs_done = 1'b0;
        compute_counter_enable = 1'b0;
        compute_counter_clr = 1'b0;
        counter_num_input_clr = 1'b0;
        buffout_clr =1'b0;
        buffout_counter_enable = 1'b0;
        capture_clr =1'b0;
        capture_counter_enable =1'b0;
        occupancy_err = 1'b0;
        counter_num_input_chunks_clr = 1'b0;
        enable_counter_num_input_chunks = 1'b0;


        case(state)
            IDLE: begin
                capture_clr =1'b1;
                compute_counter_clr = 1'b1;
                counter_num_input_chunks_clr = 1'b1;
                buffout_clr =1'b1;
                counter_num_input_clr = 1'b1;
            end
            FETCH_WEIGHT_REG0: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data0[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0001;
            end
            FETCH_WEIGHT_REG1: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data1[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0010;
                end
            FETCH_WEIGHT_REG2: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data2[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0100;

            end            
            FETCH_WEIGHT_REG3: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data3[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b1000;                
            end            
            FETCH_WEIGHT_REG4: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                write_data0[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0001;
                
                end
            FETCH_WEIGHT_REG5: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                write_data1[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0010;
                end
            FETCH_WEIGHT_REG6: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                write_data2[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0100;

            end
            FETCH_WEIGHT_REG7: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                write_data3[63:0] = weight_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b1000;
                weights_done=1;
            end
            START_LOAD_COLUMN0: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b0001;
            end
            START_LOAD_COLUMN1: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b0011;
                
            end
            START_LOAD_COLUMN2: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b0110;
            end
            START_LOAD_COLUMN3: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b1100;
            end
            WAIT_SRAM_READ0: begin
                controller_busy =1;
                // invalid=1;
            end
            // WAIT_SRAM_READ1: begin
            // end
            // START_LOAD_COLUMN4: begin
            //     ren=1;

            //     addr[9:0] = SRAM_WEIGHT_BASE + 10'h2; 

            //     {cs3, cs2, cs1, cs0} = 4'b1001;


            // end
            // START_LOAD_COLUMN5: begin
            //     ren=1;

            //     addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;

            //     {cs3, cs2, cs1, cs0} = 4'b0011;


            // end
            // START_LOAD_COLUMN6: begin
            //     ren=1;

            //     addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;

            //     {cs3, cs2, cs1, cs0} = 4'b0110;


            // end
            // START_LOAD_COLUMN7: begin

            //     ren=1;

            //     addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;

            //     {cs3, cs2, cs1, cs0} = 4'b1000;

            // end
            LOAD_COLUMN0: begin
                controller_busy = 1;
                start_weights =1;
                // if (!sram_wait_done) begin
                //capturing data 0
                systolic_data[63:0] = read_data0[63:0];
                // end
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                // {cs3, cs2, cs1, cs0} = 4'b0001;

                //starting data 4  
                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2; 
                {cs3, cs2, cs1, cs0} = 4'b1001;


            end
            LOAD_COLUMN1: begin
                controller_busy = 1;
                // if (!sram_wait_done) begin
                systolic_data[63:0] = read_data1[63:0];
                // end
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                // {cs3, cs2, cs1, cs0} = 4'b0011; 

                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                {cs3, cs2, cs1, cs0} = 4'b0011;
            end
            LOAD_COLUMN2: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data2[63:0];
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                // {cs3, cs2, cs1, cs0} = 4'b0110;
                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                {cs3, cs2, cs1, cs0} = 4'b0110;                

            end
            LOAD_COLUMN3: begin
                controller_busy = 1;
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                systolic_data[63:0] = read_data3[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b1100;
                ren=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                {cs3, cs2, cs1, cs0} = 4'b1000;                

            end
            WAIT_SRAM_READ1: begin
                controller_busy =1;
                invalid =1;
            end
            LOAD_COLUMN4: begin
                controller_busy = 1;
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h2; 
                systolic_data[63:0] = read_data0[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b1001;

            end  
            LOAD_COLUMN5: begin
                controller_busy = 1;
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                systolic_data[63:0] = read_data1[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0011;

            end
            LOAD_COLUMN6: begin
                controller_busy = 1;
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                systolic_data[63:0] = read_data2[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0110;

            end
            LOAD_COLUMN7: begin
                controller_busy = 1;
                // ren=1;
                // addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
                systolic_data[63:0] = read_data3[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b1100;
            end            
 

            // LOAD_COLUMN7_DUMMY: begin
            //     controller_busy = 1;
            //     // ren=1;
            //     // addr[9:0] = SRAM_WEIGHT_BASE + 10'h2;
            //     systolic_data[63:0] = read_data3[63:0];
            //     // {cs3, cs2, cs1, cs0} = 4'b1000;
            // end            
 
            WAIT_INF: begin
                controller_busy = 1;
            end  

            FETCH_INPUT_REG0: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;//no address hard coded anymore for multiple input vectors
                write_data0[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0001;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
                end
            FETCH_INPUT_REG1: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                write_data1[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0010;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
            end
            FETCH_INPUT_REG2: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                write_data2[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0100;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
            end
            FETCH_INPUT_REG3: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                write_data3[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b1000;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
            end
            FETCH_INPUT_REG4: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data0[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0001;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
            end
            FETCH_INPUT_REG5: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data1[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0010;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
            end
            FETCH_INPUT_REG6: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data2[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0100;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
            end
            FETCH_INPUT_REG7: begin
                controller_busy = 0;
                wen=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data3[63:0] = input_reg[63:0];
                {cs3, cs2, cs1, cs0} = 4'b1000;
                enable_counter_num_input = (!load_inputs_en)? 1'b0:1'b1;
                enable_counter_num_input_chunks = (!load_inputs_en)? 1'b0:1'b1;
                // enable_counter_num_input  =1'b1;
                // enable_counter_num_input_chunks = 1'b1; //enable input chunks loop counter
            end
            START_COMPUTE_ROW0: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4)+ 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b0001;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                inputs_done=1;
            end
            START_COMPUTE_ROW1: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b0011;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
            end
            START_COMPUTE_ROW2: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b0110;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
            end
            START_COMPUTE_ROW3: begin
                controller_busy =1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b1100;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
            end
            START_COMPUTE_ROW4: begin
                controller_busy =1;
                {cs3, cs2, cs1, cs0} = 4'b1001;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
            end

            COMPUTE_ROW0: begin
                controller_busy = 1;
                start_array =1; //load and load_inputs differentiate btw weights and inputs for the systolic array 
                systolic_data[63:0] = read_data0[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0001;
                // inputs_done = 1'b1;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4)+ 10'h0;
                
                //start 5
                {cs3, cs2, cs1, cs0} = 4'b0011;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;                
            end  
            COMPUTE_ROW1: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data1[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0011;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;

                {cs3, cs2, cs1, cs0} = 4'b0110;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;

            end  
            COMPUTE_ROW2: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data2[63:0];
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                // {cs3, cs2, cs1, cs0} = 4'b0110;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;

                {cs3, cs2, cs1, cs0} = 4'b1100;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                
            end  
            COMPUTE_ROW3: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data3[63:0];

                {cs3, cs2, cs1, cs0} = 4'b1100;
                compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                ren=1;
                addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                
                // {cs3, cs2, cs1, cs0} = 4'b1100;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
            
            
            end  
            COMPUTE_ROW3_DUMMY: begin
                controller_busy = 1;
                invalid =1'b1;
            end
            COMPUTE_ROW4: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data0[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b1001;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                
            end  
            COMPUTE_ROW5: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data1[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0011;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                
            end  
            COMPUTE_ROW6: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data2[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0110;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
            end  
            COMPUTE_ROW7: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data3[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b1100;
                // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
                // ren=1;
                // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                
            end
            // COMPUTE_ROW7_DUMMY: begin
            //     controller_busy = 1;
            //     systolic_data[63:0] = read_data3[63:0];
            //     // {cs3, cs2, cs1, cs0} = 4'b1001;
            //     // compute_counter_enable = (compute_rollover)? 1'b0:1'b1;
            //     // ren=1;
            //     // addr[9:0] = SRAM_INPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                
            // end
            WAIT_ACTIVATION_READY: begin
                controller_busy = 1;
            end
            BUFF_OUTPUT0: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                write_data0[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0001;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            BUFF_OUTPUT1: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                write_data1[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0010;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            BUFF_OUTPUT2: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                write_data2[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0100;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            BUFF_OUTPUT3: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                write_data3[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b1000;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            BUFF_OUTPUT4: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data0[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0001;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            BUFF_OUTPUT5: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data1[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0010;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            BUFF_OUTPUT6: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data2[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b0100;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            BUFF_OUTPUT7: begin
                controller_busy = 1;
                wen=1'b1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                write_data3[63:0] = activations[63:0];
                {cs3, cs2, cs1, cs0} = 4'b1000;
                buffout_counter_enable = (buffout_rollover)? 1'b0:1'b1;
            end 
            WAIT_OUT_READ0: begin
                controller_busy = 1;
            end
            WAIT_OUT_READ1: begin
                controller_busy = 1;
            end
            WAIT_OUT_READ2: begin
                controller_busy = 1;
            end
            WAIT_OUT_READ3: begin
                controller_busy = 1;
            end

            START_CAPTURE_OUT0: begin
                controller_busy = 0;
                ren=1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                {cs3, cs2, cs1, cs0} = 4'b0001;
                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
                
            end
            START_CAPTURE_OUT1: begin
                controller_busy =0;
                ren=1;
                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                output_reg[63:0] = read_data1[63:0];
                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
                {cs3, cs2, cs1, cs0} = 4'b0011;
            end
            START_CAPTURE_OUT2: begin
                controller_busy = 0;

                ren=1;

                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;

                {cs3, cs2, cs1, cs0} = 4'b0110;

                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;

            end
            START_CAPTURE_OUT3: begin
                controller_busy = 0;

                ren=1;

                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;

                {cs3, cs2, cs1, cs0} = 4'b1100;

                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
            end
            START_CAPTURE_OUT4: begin
                controller_busy = 0;

                ren=1;

                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;

                {cs3, cs2, cs1, cs0} = 4'b1001;

                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
            end            
            CAPTURE_OUT0: begin
                data_ready =1; //to subordinate
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                output_reg[63:0] = read_data0[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0001;
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
                ren=1;

                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;

                {cs3, cs2, cs1, cs0} = 4'b0011;

                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;

            end  
            CAPTURE_OUT1: begin
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                output_reg[63:0] = read_data1[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0010;
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;

                controller_busy = 0;

                ren=1;

                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;

                {cs3, cs2, cs1, cs0} = 4'b0110;

                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;

            end  
            CAPTURE_OUT2: begin
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                output_reg[63:0] = read_data2[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0110;
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;

                controller_busy = 0;

                ren=1;

                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;

                {cs3, cs2, cs1, cs0} = 4'b1100;


            end  
            CAPTURE_OUT3: begin
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h0;
                output_reg[63:0] = read_data3[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b1100;
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;

                capture_counter_enable = (capture_rollover)? 1'b0:1'b1;

                controller_busy = 0;

                ren=1;

                addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;

                {cs3, cs2, cs1, cs0} = 4'b1100;
                
            end  
            CAPTURE_OUT3_DUMMY: begin
                controller_busy = 0;
                invalid = 1;

            end
            CAPTURE_OUT4: begin
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                output_reg[63:0] = read_data0[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0001;
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
            end  
            CAPTURE_OUT5: begin
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                output_reg[63:0] = read_data1[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0011;
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
            end  
            CAPTURE_OUT6: begin
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                output_reg[63:0] = read_data2[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b0110;
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
            end  
            CAPTURE_OUT7: begin
                // capture_counter_enable = (capture_rollover)? 1'b0:1'b1;
                controller_busy = 0;
                // ren=1;
                // data_ready =1; //to subordinate
                // addr[9:0] = SRAM_OUTPUT_BASE + ({6'h0,num_input_chunks} << 4) + 10'h2;
                output_reg[63:0] = read_data3[63:0];
                // {cs3, cs2, cs1, cs0} = 4'b1100;
            end  
            ERR: begin
                occupancy_err = 1'b1;
            end
            default: begin
            end


        endcase
    end

//counter for input chunks loop 
flex_counter #(.SIZE(4)) flex_counter_num_input_chunks (   
        .clk(clk),
        .n_rst(n_rst),
        .clear(counter_num_input_chunks_clr), // 
        .count_enable(enable_counter_num_input_chunks),
        .rollover_val(MAX_INPUT_CHUNKS),  //max of 128 inputs = 16 chunks
        .count_out(num_input_chunks), //number of inputs (chunks of 8) -will be compared against number of outputs
        .rollover_flag(input_chunks_rollover) //no more inputs
    );
assign no_more_inputs = input_chunks_rollover;
// logic [7:0]counter_out_inputs;

//counter for num of input loop 
flex_counter #(.SIZE(8)) flex_counter_num_inputs (   
        .clk(clk),
        .n_rst(n_rst),
        .clear(counter_num_input_clr), // 
        .count_enable(enable_counter_num_input),
        .rollover_val(MAX_INPUTS),  //max of 128 inputs 
        .count_out(num_input), 
        .rollover_flag(unused_num_input_rollover)
    );
// logic [7:0] compute_rollover_cnt;
// assign compute_rollover_cnt = (num_input == 'h0)? 'h0 : num_input + 'h4;
// //counter for compute loop
flex_counter #(.SIZE(8)) flex_counter_compute (
    .clk(clk),
    .n_rst(n_rst),
    .clear(compute_counter_clr),
    .count_enable(compute_counter_enable),
    .rollover_val(num_input),
    .count_out(unused_compute_counter),
    .rollover_flag(compute_rollover)
);


//counter for the buffout loop 
flex_counter #(.SIZE(8)) flex_counter_buffout (
    .clk(clk),
    .n_rst(n_rst),
    .clear(buffout_clr),
    .count_enable(buffout_counter_enable),
    .rollover_val(num_input),
    .count_out(unused_buffout_counter),
    .rollover_flag(buffout_rollover)
);


//counter for the capture loop 
flex_counter #(.SIZE(8)) flex_counter_capture (
    .clk(clk),
    .n_rst(n_rst),
    .clear(capture_clr),
    .count_enable(capture_counter_enable),
    .rollover_val(num_input),
    .count_out(unused_capture_counter),
    .rollover_flag(capture_rollover)
);
//1 input vector = 64 bits -> 8 fetchs (8 bytes) -> 8 input vectors 
//128 input vectors = 16*8 input vectors 
//sram inputs base addr stored as : 110 , 112 -> 120, 122 -> 130, 132 - ....



//wait for 3 cycles -> send in the data late to the systolic array 
//instead poll for a valid for the sram_buffer 
// always_ff@(posedge clk, negedge n_rst) begin
//     if(!n_rst)
//     sram_counter <= 2'b0;
//     else if(state != next_state)
//     sram_counter <= 2'b0;
//     else if (ren)
//     sram_counter <= sram_counter + 1'b1;
// end
// always_comb begin
//     if (sram_counter == 2'd4)
//         sram_wait_done = 1'b1;
//     else 
//         sram_wait_done = 1'b0;
// end

endmodule

