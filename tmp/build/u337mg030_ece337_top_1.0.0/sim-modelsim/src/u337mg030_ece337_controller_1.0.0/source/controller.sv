`timescale 1ns / 10ps

module controller #(
    // parameters

) (

    input logic clk, n_rst,
    input logic load_weights, 
    input logic start_inference,
    input logic load_weights_en, 
    input logic load_inputs_en, 

    input  logic [63:0] input_reg,
    input  logic [63:0] weight_reg,
    input logic [63:0] read_data0, read_data1, read_data2, read_data3,read_data4, read_data5, read_data6, read_data7,
    
    input logic [63:0] activations, 
    input logic activated, 

    output logic controller_busy, 
    output logic data_ready, 
    output logic [7:0] r_trigger, w_trigger,
    output logic start_weights, 
    output logic  start_array,
    output logic [63:0]  output_reg,
    output logic weights_done, 
    // output logic invalid, 
    output logic enable,
    output logic [63:0] write_data0, write_data1, write_data2, write_data3,  write_data4, write_data5, write_data6, write_data7, 
    output logic cs0,cs1,cs2,cs3, cs4,cs5,cs6,cs7, 
    output logic [9:0] addr,
    output logic [63:0] systolic_data,
    output logic inputs_done,
    output logic occupancy_err
    // output logic [6:0] num_input 
    
);

// weight reg delay

logic [63:0] activations_delay;

always_ff @( negedge n_rst, posedge clk ) begin
    if (!n_rst) begin
        activations_delay <= 0;        
    end else begin
        activations_delay <= activations;
    end
end

logic [63:0] weight_reg_delay;

always_ff @( negedge n_rst, posedge clk ) begin
    if (!n_rst) begin
        weight_reg_delay <= 0;        
    end else begin
        weight_reg_delay <= weight_reg;
    end
end


logic [63:0] input_reg_delay;

always_ff @( negedge n_rst, posedge clk ) begin
    if (!n_rst) begin
        input_reg_delay <= 0;        
    end else begin
        input_reg_delay <= input_reg;
    end
end

localparam  SRAM_WEIGHT_BASE = 10'h0;
localparam  SRAM_INPUT_BASE = 10'h100; 
localparam  SRAM_ACTIVATION_BASE = 10'h300;

typedef enum logic [6:0] {
IDLE, 
FETCH_WEIGHT0, WAIT_WEIGHT0, FETCH_WEIGHT1, WAIT_WEIGHT1, FETCH_WEIGHT2, WAIT_WEIGHT2,  FETCH_WEIGHT3, WAIT_WEIGHT3,
FETCH_WEIGHT4, WAIT_WEIGHT4, FETCH_WEIGHT5, WAIT_WEIGHT5, FETCH_WEIGHT6, WAIT_WEIGHT6, FETCH_WEIGHT7, WAIT_WEIGHT7,
READ_WEIGHT0, READ_WEIGHT1, READ_WEIGHT2, READ_WEIGHT3, READ_WEIGHT4, READ_WEIGHT5, READ_WEIGHT6, READ_WEIGHT7,
WAIT_WEIGHT8, WAIT_WEIGHT9, WAIT_WEIGHT10, WAIT_WEIGHT11, WAIT_WEIGHT12,

FETCH_INPUT0, WAIT_INPUT0, FETCH_INPUT1, WAIT_INPUT1, FETCH_INPUT2, WAIT_INPUT2,  FETCH_INPUT3, WAIT_INPUT3,
FETCH_INPUT4, WAIT_INPUT4, FETCH_INPUT5, WAIT_INPUT5, FETCH_INPUT6, WAIT_INPUT6, FETCH_INPUT7, WAIT_INPUT7,
READ_INPUT0, READ_INPUT1, READ_INPUT2, READ_INPUT3, READ_INPUT4, READ_INPUT5, READ_INPUT6, READ_INPUT7,
WAIT_INPUT8, WAIT_INPUT9, WAIT_INPUT10, WAIT_INPUT11, WAIT_INPUT12,

FETCH_ACTIVATION0, WAIT_ACTIVATION0, FETCH_ACTIVATION1, WAIT_ACTIVATION1, FETCH_ACTIVATION2, WAIT_ACTIVATION2,  FETCH_ACTIVATION3, WAIT_ACTIVATION3,
FETCH_ACTIVATION4, WAIT_ACTIVATION4, FETCH_ACTIVATION5, WAIT_ACTIVATION5, FETCH_ACTIVATION6, WAIT_ACTIVATION6, FETCH_ACTIVATION7, WAIT_ACTIVATION7,
READ_ACTIVATION0, READ_ACTIVATION1, READ_ACTIVATION2, READ_ACTIVATION3, READ_ACTIVATION4, READ_ACTIVATION5, READ_ACTIVATION6, READ_ACTIVATION7,
WAIT_ACTIVATION8, WAIT_ACTIVATION9, WAIT_ACTIVATION10, WAIT_ACTIVATION11, WAIT_ACTIVATION12,
ERR

} state_t;

state_t state, next_state;

always_ff @(posedge clk or negedge n_rst) begin
        if(!n_rst)
            state <= IDLE;
        else
            state <= next_state;
end



 always_comb begin
        next_state = state;
        case(state)
            IDLE: begin
                if(load_weights_en) begin
                    next_state = FETCH_WEIGHT0;
                end else if (load_inputs_en) begin
                    next_state = FETCH_INPUT0;
                end else begin
                    next_state = IDLE;
                end
            end

            FETCH_WEIGHT0: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT1;
                else if ((load_weights) ||(load_weights && load_weights_en)) 
                next_state = ERR;
                else
                next_state = WAIT_WEIGHT0;
            end
            
            WAIT_WEIGHT0: begin
                if (load_weights_en) begin
                    next_state = FETCH_WEIGHT1;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT0;
                end
            end

            FETCH_WEIGHT1: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT2;
                else if ((load_weights) ||(load_weights && load_weights_en)) 
                next_state = ERR;
                else
                next_state = WAIT_WEIGHT1;
            end
            
            WAIT_WEIGHT1: begin
                if (load_weights_en) begin
                    next_state = FETCH_WEIGHT2;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT1;
                end
            end

            FETCH_WEIGHT2: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT3;
                else if ((load_weights) ||(load_weights && load_weights_en))  
                next_state = ERR;
                else
                next_state = WAIT_WEIGHT2;
            end

            WAIT_WEIGHT2: begin
                if (load_weights_en) begin
                    next_state = FETCH_WEIGHT3;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT2;
                end
            end
            
            FETCH_WEIGHT3: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT4;
                else if ((load_weights) ||(load_weights && load_weights_en))  
                next_state = ERR;
                else
                next_state = WAIT_WEIGHT3;
            end
            
            WAIT_WEIGHT3: begin
                if (load_weights_en) begin
                    next_state = FETCH_WEIGHT4;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT3;
                end
            end
            
            FETCH_WEIGHT4: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT5;
                else if ((load_weights) ||(load_weights && load_weights_en))  
                next_state = ERR;
                else
                next_state = WAIT_WEIGHT4;
            end
            
            WAIT_WEIGHT4: begin
                if (load_weights_en) begin
                    next_state = FETCH_WEIGHT5;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT4;
                end
            end
            
            FETCH_WEIGHT5: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT6;
                else if ((load_weights) ||(load_weights && load_weights_en))  
                next_state = ERR;
                else
                next_state = WAIT_WEIGHT5;
            end
            
            WAIT_WEIGHT5: begin
                if (load_weights_en) begin
                    next_state = FETCH_WEIGHT6;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT5;
                end
            end
            
            FETCH_WEIGHT6: begin
                if(load_weights_en) 
                next_state = FETCH_WEIGHT7;
                else if ((load_weights) ||(load_weights && load_weights_en)) 
                next_state = ERR;
                else
                next_state = WAIT_WEIGHT6;
            end
            
            WAIT_WEIGHT6: begin
                if (load_weights_en) begin
                    next_state = FETCH_WEIGHT7;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT6;
                end
            end
            
            FETCH_WEIGHT7: begin
                if(load_weights) 
                    next_state = READ_WEIGHT0;
                else if ((load_weights) ||(load_weights && load_weights_en))  
                next_state = ERR;
                else
                    next_state = WAIT_WEIGHT7;
            end
            WAIT_WEIGHT7: begin
                if (load_weights) begin
                    next_state = READ_WEIGHT0;
                end else if ((load_weights) ||(load_weights && load_weights_en))begin
                    next_state = ERR;
                end else begin
                    next_state = WAIT_WEIGHT7;
                end
            end

            READ_WEIGHT0: begin
                next_state = READ_WEIGHT1;
            end
            READ_WEIGHT1: begin
                next_state = READ_WEIGHT2;
            end
            READ_WEIGHT2: begin
                next_state = READ_WEIGHT3;
            end
            READ_WEIGHT3: begin
                next_state = READ_WEIGHT4;
            end
            READ_WEIGHT4: begin
                next_state = READ_WEIGHT5;
            end
            READ_WEIGHT5: begin
                next_state = READ_WEIGHT6;
            end
            READ_WEIGHT6: begin
                next_state = READ_WEIGHT7;
            end
            READ_WEIGHT7: begin
                next_state = WAIT_WEIGHT8;
            end
            WAIT_WEIGHT8: begin
                next_state = WAIT_WEIGHT9;
            end
            WAIT_WEIGHT9: begin
                next_state = WAIT_WEIGHT10;
            end
            WAIT_WEIGHT10: begin
                next_state = WAIT_WEIGHT11;
            end
            WAIT_WEIGHT11: begin
                next_state = WAIT_WEIGHT12;
            end
            WAIT_WEIGHT12: begin
                next_state = IDLE;
            end
            ///////////////////////////////////////////////////////////////////////
            // Inputs
            /////////////////////////////////////////////////////////////////////////


            FETCH_INPUT0: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT1;
                else if (load_weights) 
                next_state = ERR;
                else
                next_state = WAIT_INPUT0;
            end
            
            WAIT_INPUT0: begin
                if (load_inputs_en) begin
                    next_state = FETCH_INPUT1;
                end else begin
                    next_state = WAIT_INPUT0;
                end
            end

            FETCH_INPUT1: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT2;
                else if (load_weights) 
                next_state = ERR;
                else
                next_state = WAIT_INPUT1;
            end
            
            WAIT_INPUT1: begin
                if (load_inputs_en) begin
                    next_state = FETCH_INPUT2;
                end else begin
                    next_state = WAIT_INPUT1;
                end
            end

            FETCH_INPUT2: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT3;
                else if (load_weights) 
                next_state = ERR;
                else
                next_state = WAIT_INPUT2;
            end

            WAIT_INPUT2: begin
                if (load_inputs_en) begin
                    next_state = FETCH_INPUT3;
                end else begin
                    next_state = WAIT_INPUT2;
                end
            end
            
            FETCH_INPUT3: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT4;
                else if (load_weights) 
                next_state = ERR;
                else
                next_state = WAIT_INPUT3;
            end
            
            WAIT_INPUT3: begin
                if (load_inputs_en) begin
                    next_state = FETCH_INPUT4;
                end else begin
                    next_state = WAIT_INPUT3;
                end
            end
            
            FETCH_INPUT4: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT5;
                else if (load_weights) 
                next_state = ERR;
                else
                next_state = WAIT_INPUT4;
            end
            
            WAIT_INPUT4: begin
                if (load_inputs_en) begin
                    next_state = FETCH_INPUT5;
                end else begin
                    next_state = WAIT_INPUT4;
                end
            end
            
            FETCH_INPUT5: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT6;
                else if (load_weights) 
                next_state = ERR;
                else
                next_state = WAIT_INPUT5;
            end
            
            WAIT_INPUT5: begin
                if (load_inputs_en) begin
                    next_state = FETCH_INPUT6;
                end else begin
                    next_state = WAIT_INPUT5;
                end
            end
            
            FETCH_INPUT6: begin
                if(load_inputs_en) 
                next_state = FETCH_INPUT7;
                else if (load_weights) 
                next_state = ERR;
                else
                next_state = WAIT_INPUT6;
            end
            
            WAIT_INPUT6: begin
                if (load_inputs_en) begin
                    next_state = FETCH_INPUT7;
                end else begin
                    next_state = WAIT_INPUT6;
                end
            end
            
            FETCH_INPUT7: begin
                if(start_inference) 
                    next_state = READ_INPUT0;
                else if (load_weights) 
                next_state = ERR;
                else
                    next_state = WAIT_INPUT7;
            end
            WAIT_INPUT7: begin
                if (start_inference) begin
                    next_state = READ_INPUT0;
                end else begin
                    next_state = WAIT_INPUT7;
                end
            end

            READ_INPUT0: begin
                next_state = READ_INPUT1;
            end
            READ_INPUT1: begin
                next_state = READ_INPUT2;
            end
            READ_INPUT2: begin
                next_state = READ_INPUT3;
            end
            READ_INPUT3: begin
                next_state = READ_INPUT4;
            end
            READ_INPUT4: begin
                next_state = READ_INPUT5;
            end
            READ_INPUT5: begin
                next_state = READ_INPUT6;
            end
            READ_INPUT6: begin
                next_state = READ_INPUT7;
            end
            READ_INPUT7: begin
                next_state = WAIT_INPUT8;
            end
            WAIT_INPUT8: begin
                next_state = WAIT_INPUT9;
            end
            WAIT_INPUT9: begin
                next_state = WAIT_INPUT10;
            end
            WAIT_INPUT10: begin
                next_state = WAIT_INPUT11;
            end
            WAIT_INPUT11: begin
                next_state = WAIT_INPUT12;
            end
            WAIT_INPUT12: begin
                if(activated)
                next_state = FETCH_ACTIVATION0;
            end
            ///////////////////////////////////////////////////////////////////////
            // ACTIVATION OUTPUT
            /////////////////////////////////////////////////////////////////////////

            FETCH_ACTIVATION0: begin
                if(activated) 
                next_state = FETCH_ACTIVATION1;
                else 
                next_state = WAIT_ACTIVATION0;
            end
            
            WAIT_ACTIVATION0: begin
                if (activated) begin
                    next_state = FETCH_ACTIVATION1;
                end else begin
                    next_state = WAIT_ACTIVATION0;
                end
            end

            FETCH_ACTIVATION1: begin
                if(activated) 
                next_state = FETCH_ACTIVATION2;
                else 
                next_state = WAIT_ACTIVATION1;
            end
            
            WAIT_ACTIVATION1: begin
                if (activated) begin
                    next_state = FETCH_ACTIVATION2;
                end else begin
                    next_state = WAIT_ACTIVATION1;
                end
            end

            FETCH_ACTIVATION2: begin
                if(activated) 
                next_state = FETCH_ACTIVATION3;
                else 
                next_state = WAIT_ACTIVATION2;
            end

            WAIT_ACTIVATION2: begin
                if (activated) begin
                    next_state = FETCH_ACTIVATION3;
                end else begin
                    next_state = WAIT_ACTIVATION2;
                end
            end
            
            FETCH_ACTIVATION3: begin
                if(activated) 
                next_state = FETCH_ACTIVATION4;
                else 
                next_state = WAIT_ACTIVATION3;
            end
            
            WAIT_ACTIVATION3: begin
                if (activated) begin
                    next_state = FETCH_ACTIVATION4;
                end else begin
                    next_state = WAIT_ACTIVATION3;
                end
            end
            
            FETCH_ACTIVATION4: begin
                if(activated) 
                next_state = FETCH_ACTIVATION5;
                else 
                next_state = WAIT_ACTIVATION4;
            end
            
            WAIT_ACTIVATION4: begin
                if (activated) begin
                    next_state = FETCH_ACTIVATION5;
                end else begin
                    next_state = WAIT_ACTIVATION4;
                end
            end
            
            FETCH_ACTIVATION5: begin
                if(activated) 
                next_state = FETCH_ACTIVATION6;
                else 
                next_state = WAIT_ACTIVATION5;
            end
            
            WAIT_ACTIVATION5: begin
                if (activated) begin
                    next_state = FETCH_ACTIVATION6;
                end else begin
                    next_state = WAIT_ACTIVATION5;
                end
            end
            
            FETCH_ACTIVATION6: begin
                if(activated) 
                next_state = FETCH_ACTIVATION7;
                else 
                next_state = WAIT_ACTIVATION6;
            end
            
            WAIT_ACTIVATION6: begin
                if (activated) begin
                    next_state = FETCH_ACTIVATION7;
                end else begin
                    next_state = WAIT_ACTIVATION6;
                end
            end
            
            FETCH_ACTIVATION7: begin
                if(activated) 
                    next_state = READ_ACTIVATION0;
                else 
                    next_state = WAIT_ACTIVATION7;
            end
            WAIT_ACTIVATION7: begin
                // if (activated) begin
                    next_state = READ_ACTIVATION0;
                // end else begin
                //     next_state = WAIT_ACTIVATION7;
                // end
            end

            READ_ACTIVATION0: begin
                next_state = READ_ACTIVATION1;
            end
            READ_ACTIVATION1: begin
                next_state = READ_ACTIVATION2;
            end
            READ_ACTIVATION2: begin
                next_state = READ_ACTIVATION3;
            end
            READ_ACTIVATION3: begin
                next_state = READ_ACTIVATION4;
            end
            READ_ACTIVATION4: begin
                next_state = READ_ACTIVATION5;
            end
            READ_ACTIVATION5: begin
                next_state = READ_ACTIVATION6;
            end
            READ_ACTIVATION6: begin
                next_state = READ_ACTIVATION7;
            end
            READ_ACTIVATION7: begin
                next_state = WAIT_ACTIVATION8;
            end
            WAIT_ACTIVATION8: begin
                next_state = WAIT_ACTIVATION9;
            end
            WAIT_ACTIVATION9: begin
                next_state = WAIT_ACTIVATION10;
            end
            WAIT_ACTIVATION10: begin
                next_state = WAIT_ACTIVATION11;
            end
            WAIT_ACTIVATION11: begin
                next_state = WAIT_ACTIVATION12;
            end
            WAIT_ACTIVATION12: begin
                next_state = IDLE;
            end
            default: begin
            end        
    endcase
 end

//output logic 
 always_comb begin

write_data0 =0;
write_data1 =0;
write_data2 =0;
write_data3 =0;
write_data4 =0;
write_data5 =0;
write_data6 =0;
write_data7 =0;
controller_busy = 0;
cs7 = 0;
cs6 = 0;
cs5 = 0;
cs4 = 0;
cs3 = 0;
cs2 = 0;
cs1 = 0;
cs0 = 0;
start_weights =0;
occupancy_err =1'b0;
start_array =0;
w_trigger [7:0] = 8'b0;
r_trigger [7:0] = 8'b0;
w_trigger [7:0] = 8'b0;
addr = 10'b0;
systolic_data = 64'b0;
output_reg = 64'b0;
weights_done = 0;
inputs_done = 0;
data_ready = 0;
enable = 0;


         case(state)
            IDLE: begin
                // w_trigger[0] = load_weights_en;
                
            end
            FETCH_WEIGHT0: begin
                controller_busy = 0;
                w_trigger[0]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data0[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000001;   

            end
            WAIT_WEIGHT0: begin
                controller_busy = 0;
                w_trigger[0]=0;
            end
            FETCH_WEIGHT1: begin
                controller_busy = 0;
                w_trigger[1]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data1[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000010;   
            end
            WAIT_WEIGHT1: begin
                controller_busy = 0;
                w_trigger[1]=0;
            end            
            FETCH_WEIGHT2: begin
                controller_busy = 0;
                w_trigger[2]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data2[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000100;   
            end
            WAIT_WEIGHT2: begin
                controller_busy = 0;
                w_trigger[2]=0;

            end            
            FETCH_WEIGHT3: begin
                controller_busy = 0;
                w_trigger[3]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data3[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00001000;   
            end
            WAIT_WEIGHT3: begin
                controller_busy = 0;
                w_trigger[3]=0;

            end            
            FETCH_WEIGHT4: begin
                controller_busy = 0;
                w_trigger[4]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data4[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00010000;   
            end
            WAIT_WEIGHT4: begin
                controller_busy = 0;
                w_trigger[4]=0;

            end            
            FETCH_WEIGHT5: begin
                controller_busy = 0;
                w_trigger[5]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data5[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00100000;   
            end
            WAIT_WEIGHT5: begin
                controller_busy = 0;
                w_trigger[5]=0;
            end            
            FETCH_WEIGHT6: begin
                controller_busy = 0;
                w_trigger[6]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data6[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b01000000;   
            end
            WAIT_WEIGHT6: begin
                controller_busy = 0;
                w_trigger[6]=0;

            end            
            FETCH_WEIGHT7: begin
                controller_busy = 0;
                w_trigger[7]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                write_data7[63:0] = weight_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b10000000;   
                weights_done = 1'b1;
            end
            WAIT_WEIGHT7: begin
                controller_busy = 0;
                w_trigger[7]=0;

            end            
            READ_WEIGHT0: begin
                controller_busy =1;
                r_trigger[0]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000001;

            end
            READ_WEIGHT1: begin
                controller_busy =1;
                r_trigger[1]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000010;
                
           
            end
            READ_WEIGHT2: begin
                controller_busy =1;
                r_trigger[2]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000100;
            
            end
            READ_WEIGHT3: begin
                controller_busy =1;
                r_trigger[3]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00001000;            
            end
            READ_WEIGHT4: begin
                controller_busy =1;
                r_trigger[4]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00010000;    

                           
            end
            READ_WEIGHT5: begin
                controller_busy =1;
                r_trigger[5]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00100000;  
                enable = 1;
                controller_busy = 1;
                start_weights =1;
                systolic_data[63:0] = read_data0[63:0];
                             
            end
            READ_WEIGHT6: begin
                controller_busy =1;
                r_trigger[6]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b01000000;   
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data1[63:0];
                            
            end
            READ_WEIGHT7: begin
                controller_busy =1;
                r_trigger[7]=1;
                addr[9:0] = SRAM_WEIGHT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b10000000; 
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data2[63:0];
                              
            end
            WAIT_WEIGHT8: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data3[63:0];
                enable = 1;
            end
            WAIT_WEIGHT9: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data4[63:0];
                enable = 1;
            end
            WAIT_WEIGHT10: begin
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data5[63:0];
            end
            WAIT_WEIGHT11: begin
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data6[63:0];
                
            end
            WAIT_WEIGHT12: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data7[63:0];
                enable = 1;
            end

            ///////////////////////////////////////////////////
            //INPUTS
            ///////////////////////////////////////////////////    
            FETCH_INPUT0: begin
                controller_busy = 0;
                w_trigger[0]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data0[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000001;    

            end

            WAIT_INPUT0: begin
                controller_busy = 0;
                w_trigger[0]=0;
            end
            FETCH_INPUT1: begin
                controller_busy = 0;
                w_trigger[1]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data1[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000010;   
            end
            WAIT_INPUT1: begin
                controller_busy = 0;
                w_trigger[1]=0;
            end            
            FETCH_INPUT2: begin
                controller_busy = 0;
                w_trigger[2]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data2[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000100;   
            end
            WAIT_INPUT2: begin
                controller_busy = 0;
                w_trigger[2]=0;

            end            
            FETCH_INPUT3: begin
                controller_busy = 0;
                w_trigger[3]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data3[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00001000;   
            end
            WAIT_INPUT3: begin
                controller_busy = 0;
                w_trigger[3]=0;

            end            
            FETCH_INPUT4: begin
                controller_busy = 0;
                w_trigger[4]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data4[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00010000;   
            end
            WAIT_INPUT4: begin
                controller_busy = 0;
                w_trigger[4]=0;

            end            
            FETCH_INPUT5: begin
                controller_busy = 0;
                w_trigger[5]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data5[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00100000;   
            end
            WAIT_INPUT5: begin
                controller_busy = 0;
                w_trigger[5]=0;
            end            
            FETCH_INPUT6: begin
                controller_busy = 0;
                w_trigger[6]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data6[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b01000000;   
            end
            WAIT_INPUT6: begin
                controller_busy = 0;
                w_trigger[6]=0;

            end            
            FETCH_INPUT7: begin
                controller_busy = 0;
                w_trigger[7]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                write_data7[63:0] = input_reg_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b10000000;   
                inputs_done = 1'b1;
            end
            WAIT_INPUT7: begin
                controller_busy = 0;
                w_trigger[7]=0;

            end            
            READ_INPUT0: begin
                controller_busy =1;
                r_trigger[0]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000001;

            end
            READ_INPUT1: begin
                controller_busy =1;
                r_trigger[1]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000010;
                
           
            end
            READ_INPUT2: begin
                controller_busy =1;
                r_trigger[2]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000100;
            
            end
            READ_INPUT3: begin
                controller_busy =1;
                r_trigger[3]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00001000;            
            end
            READ_INPUT4: begin
                controller_busy =1;
                r_trigger[4]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00010000;    

                           
            end
            READ_INPUT5: begin
                controller_busy =1;
                r_trigger[5]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00100000;  

                controller_busy = 1;
                start_array =1;
                enable = 1;
                systolic_data[63:0] = read_data0[63:0];
                             
            end
            READ_INPUT6: begin
                controller_busy =1;
                r_trigger[6]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b01000000;   
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data1[63:0];
                            
            end
            READ_INPUT7: begin
                controller_busy =1;
                r_trigger[7]=1;
                addr[9:0] = SRAM_INPUT_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b10000000; 
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data2[63:0];
                              
            end
            WAIT_INPUT8: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data3[63:0];
                enable = 1;
            end
            WAIT_INPUT9: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data4[63:0];
                enable = 1;
            end
            WAIT_INPUT10: begin
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data5[63:0];
            end
            WAIT_INPUT11: begin
                enable = 1;
                controller_busy = 1;
                systolic_data[63:0] = read_data6[63:0];
                
            end
            WAIT_INPUT12: begin
                controller_busy = 1;
                systolic_data[63:0] = read_data7[63:0];
                enable = 1;
            end
//////////////////////////////////////
////  ACTIVATIONS
///////////////////////////////////
            FETCH_ACTIVATION0: begin
                controller_busy = 0;
                w_trigger[0]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data0[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000001;     
                enable = 1;
            end

            WAIT_ACTIVATION0: begin
                controller_busy = 0;
                w_trigger[0] = 1;
                enable = 1;
            end
            FETCH_ACTIVATION1: begin
                controller_busy = 0;
                w_trigger[1]=1;
                w_trigger[0] = 0;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data1[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000010;   
                enable = 1;
            end
            WAIT_ACTIVATION1: begin
                controller_busy = 0;
                w_trigger[1]=0;
                enable = 1;

            end            
            FETCH_ACTIVATION2: begin
                controller_busy = 0;
                w_trigger[2]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data2[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000100;   
                enable = 1;
            end
            WAIT_ACTIVATION2: begin
                controller_busy = 0;
                w_trigger[2]=0;
                enable = 1;
            end            
            FETCH_ACTIVATION3: begin
                controller_busy = 0;
                w_trigger[3]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data3[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00001000;   
                enable = 1;
            end
            WAIT_ACTIVATION3: begin
                controller_busy = 0;
                w_trigger[3]=0;
                enable = 1;

            end            
            FETCH_ACTIVATION4: begin
                controller_busy = 0;
                w_trigger[4]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data4[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00010000;   
                enable = 1;
            end
            WAIT_ACTIVATION4: begin
                controller_busy = 0;
                w_trigger[4]=0;
                enable = 1;

            end            
            FETCH_ACTIVATION5: begin
                controller_busy = 0;
                w_trigger[5]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data5[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00100000;   
                enable = 1;
            end
            WAIT_ACTIVATION5: begin
                controller_busy = 0;
                w_trigger[5]=0;
                enable = 1;
            end            
            FETCH_ACTIVATION6: begin
                controller_busy = 0;
                w_trigger[6]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data6[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b01000000;   
                enable = 1;
            end
            WAIT_ACTIVATION6: begin
                controller_busy = 0;
                w_trigger[6]=0;
                enable = 1;
            end            
            FETCH_ACTIVATION7: begin
                controller_busy = 0;
                w_trigger[7]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                write_data7[63:0] = activations_delay[63:0];
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b10000000;   
                enable = 1;
            end
            WAIT_ACTIVATION7: begin
                controller_busy = 0;
                w_trigger[7]=0;
                enable = 1;
            end            
            READ_ACTIVATION0: begin
                controller_busy =1;
                r_trigger[0]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000001;

            end
            READ_ACTIVATION1: begin
                controller_busy =1;
                r_trigger[1]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000010;
                
           
            end
            READ_ACTIVATION2: begin
                controller_busy =1;
                r_trigger[2]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00000100;
            
            end
            READ_ACTIVATION3: begin
                controller_busy =1;
                r_trigger[3]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00001000;            
            end
            READ_ACTIVATION4: begin
                controller_busy =1;
                r_trigger[4]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00010000;    

                           
            end
            READ_ACTIVATION5: begin
                r_trigger[5]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b00100000;  

                controller_busy = 0;
                // start_array =1;
                output_reg[63:0] = read_data0[63:0];
                data_ready = 1;
                             
            end
            READ_ACTIVATION6: begin
                r_trigger[6]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b01000000;   
                data_ready = 1;
                controller_busy = 0;
                output_reg[63:0] = read_data1[63:0];
                            
            end
            READ_ACTIVATION7: begin
                controller_busy =1;
                r_trigger[7]=1;
                addr[9:0] = SRAM_ACTIVATION_BASE + 10'h0;
                {cs7, cs6, cs5, cs4, cs3, cs2, cs1, cs0} = 8'b10000000; 
                data_ready = 1;
                controller_busy = 0;
                output_reg[63:0] = read_data2[63:0];
                              
            end
            WAIT_ACTIVATION8: begin
                controller_busy = 0;
                output_reg[63:0] = read_data3[63:0];
                data_ready = 1;
            end
            WAIT_ACTIVATION9: begin
                controller_busy = 0;
                output_reg[63:0] = read_data4[63:0];
                data_ready = 1;
            end
            WAIT_ACTIVATION10: begin
                data_ready = 1;
                controller_busy = 0;
                output_reg[63:0] = read_data5[63:0];
            end
            WAIT_ACTIVATION11: begin
                data_ready = 1;
                controller_busy = 0;
                output_reg[63:0] = read_data6[63:0];
                
            end
            WAIT_ACTIVATION12: begin
                controller_busy = 0;
                output_reg[63:0] = read_data7[63:0];
                data_ready = 1;
            end
            ERR: begin
                occupancy_err = 1'b1;
            end

            default: begin
            end
    endcase
 end

 


endmodule
