`timescale 1ns / 10ps

module AHB_CDL (
    input logic clk, n_rst,
    input  logic hsel,
    input  logic [9:0] haddr,
    input  logic [1:0] htrans,
    input  logic [2:0] hsize,
    input  logic hwrite,
    input  logic [63:0] hwdata,
    input  logic [2:0]hburst,
    input  logic controller_busy,
    input  logic data_ready,
    input logic [63:0] output_reg,
    input logic buffer_error, weight_done, input_done, systolic_done,

    output logic [63:0]  hrdata,
    output logic hready, hresp,
    output logic [63:0]  input_data,
    output logic [63:0]  weight,
    output logic weight_write_en,
    output logic input_write_en,
    output logic  start_inference, load_weights,
    output logic [1:0] activation_mode,
    output logic [63:0] bias
);
    typedef enum logic [1:0] {IDLE = 0, ERROR1 = 1, ERROR2 = 2} err_state_t;
    err_state_t current_state, next_state;

    // External inputs registered
    logic hsel_reg;
    logic [9:0] haddr_reg;
    logic [1:0] htrans_reg;
    logic [2:0] hsize_reg;
    logic hwrite_reg;
    logic [2:0] hburst_reg;

    // internal registers var
    logic [63:0] weight_reg;
    logic [63:0] input_reg;
    logic [63:0] bias_reg;
    // latch to remember that weights have been loaded; cleared when data_ready asserted
    logic weight_done_latched;
    logic load_weights_latched;
    logic [63:0] control_reg, control;
    logic [63:0] act_control_reg, act_control; 
    logic [1:0]controller_reg;
    logic [63:0] store_hrdata;

     //burst related logic
    logic        burst_active, burst_active_reg;
    logic [9:0]  burst_addr_reg, burst_addr_next;
    logic [9:0]  burst_base_addr_reg, burst_base_addr_next;
    logic [9:0]  burst_beats_reg, burst_beats_next;
    logic [2:0]  burst_type_reg, burst_type_next; 

    logic [9:0] burst_length; 
    logic [9:0] burst_increment; 
    logic [2:0] beat_shift;
    logic [9:0] boundary; 
    logic [9:0] wrap_mask;
    logic [9:0] align_mask;
    logic [9:0] wrap_align_mask;

    //error stuff
    logic error_flag_reg;
    logic error_detected_now;
    logic error_flag_next;
    logic stall_active;
    logic device_busy;

    logic [9:0] effective_addr;
    logic raw_hazard;

    logic clear_error;
    logic valid_transfer;


    assign activation_mode = act_control[1:0];
    assign controller_reg = control[1:0];
    
    always_comb begin
        device_busy = 1'b0;

        if(htrans == 2'd1) device_busy = 1'b1;
        else device_busy = 1'b0;
    end

    // external inputs register
    always_ff @(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            hsel_reg <= 1'b0;
            haddr_reg <= 10'd0;
            htrans_reg <= 2'd0;
            hsize_reg <= 3'd0;
            hwrite_reg <= 1'b0;
            hburst_reg <= 3'd0;
            hrdata <= 64'd0;
        end 
        else begin
            hsel_reg <= hsel;
            haddr_reg <= haddr;
            htrans_reg <= htrans;
            hsize_reg <= hsize;
            hwrite_reg <= hwrite;
            hburst_reg <= hburst;
            hrdata <= store_hrdata;
        end
    end

    // internal registers(weight, input, bias, control, act_control)
    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            weight_reg <= 64'd0;
            input_reg <= 64'd0;
            bias_reg <= 64'd0;
            control_reg <= 64'd0;
            act_control_reg <= 64'd0;
            weight_done_latched <= 1'b0;
            load_weights_latched <= 1'b0;
        end
        else begin
            weight_reg <= weight;
            input_reg <= input_data;
            bias_reg <= bias;
            control_reg <= control;
            act_control_reg <= act_control;
        end
    end

    // latch weight_done and load_weights until data_ready clears them
    // logic load_weights_latched;
    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            weight_done_latched <= 1'b0;
            load_weights_latched <= 1'b0;
        end else begin
            if (data_ready) begin
                weight_done_latched <= 1'b0;
                load_weights_latched <= 1'b0;
            end else begin
                if (weight_done) weight_done_latched <= 1'b1;
                else weight_done_latched <= weight_done_latched;

                if (load_weights) load_weights_latched <= 1'b1;
                else load_weights_latched <= load_weights_latched;
            end
        end
    end

    ///----------------------------------------------------------
    // BURSTING Logic
    //----------------------------------------------------------

    // bursting register
    always_ff@(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            burst_active_reg      <= 1'b0;
            burst_type_reg        <= 3'd0;
            burst_addr_reg        <= 10'd0;
            burst_base_addr_reg   <= 10'd0;
            burst_beats_reg       <= 10'd0;
        end
        else begin
            burst_active_reg      <= burst_active;
            burst_type_reg        <= burst_type_next;
            burst_addr_reg        <= burst_addr_next;
            burst_base_addr_reg   <= burst_base_addr_next;
            burst_beats_reg       <= burst_beats_next;
        end
    end

    // bursting comb
    always_comb begin
    burst_addr_next = 10'd0;
    burst_active = 1'd0;
    burst_beats_next = 10'd0;
    burst_type_next = 3'd0;
    beat_shift = 3'd0;
    burst_increment = 10'b0;
    wrap_align_mask = 10'd0;
    align_mask = 10'd0;
    wrap_mask = 10'd0;
    burst_base_addr_next = 10'd0;
    boundary = 10'd0;

        if((stall_active == 1'b0) ) begin
            burst_active        = burst_active_reg; // there's a burst
            burst_type_next     = burst_type_reg; // what's teh burst type? (INCR/WRAP)
            burst_addr_next     = burst_addr_reg;  // what address of the AHB reguister is the burst occuring at?
            burst_base_addr_next = burst_base_addr_reg; // where is our next burst address at? depening on the byte-size
            burst_beats_next    = burst_beats_reg;  // by how much are we jumping?

            beat_shift      = 3'd0;
            burst_increment = 10'd0;
            burst_length    = 10'd0;
            boundary        = 10'd0;
            wrap_mask       = 10'd0;
            align_mask      = 10'd0;
            wrap_align_mask = 10'd0;

            case(hsize_reg) // basically how much are jumping after one burst? depends on size
                3'd0: beat_shift  = 3'd0;  // 1 byte
                3'd1: beat_shift  = 3'd1;  // 2 bytes
                3'd2: beat_shift  = 3'd2;  // 4 bytes
                3'd3: beat_shift  = 3'd3;  // 8 bytes
                default: beat_shift  = 3'd0;
            endcase
    
            burst_increment  = 4'd1 << beat_shift; // used when saying we start at addreass 0 and if size is 1/2/4/8 bytes it moves by that 

            case (burst_type_reg)
                3'd0: burst_length = 10'd1;   // SINGLE
                3'd1: burst_length = 10'd0;  // unlimited
                3'd2, 3'd3: burst_length = 10'd4;   // INCR4/WRAP4
                3'd4, 3'd5: burst_length = 10'd8;   // INCR8/WRAP8
                3'd6, 3'd7: burst_length = 10'd16;  // INCR16/WRAP16
                default:    burst_length = 10'd0;   // INCR (unlimited)
            endcase

            boundary = burst_length << beat_shift;  // total bytes in a burst
            wrap_mask = boundary - 1;

            if(~hsel) burst_active = 1'b0;
            else if((htrans == 2'd0) && hsel) burst_active = 1'b0;


            // if in slave, in first burst and not a single transfer
                if(hsel_reg && htrans_reg == 2'b10 && hready) begin // do we want to use current hburst? // first beat of a burst or ind. transfer
                    burst_active        = 1'b1;
                    burst_type_next     = hburst_reg; // captures the burst type
                    burst_beats_next    = 1; // reset beat counter

                    // BEAT-SIZE alignment mask
                    align_mask = ~(burst_increment - 1);  // beat alignment mask that clears lower bits

                    // WRAP boundary alignment mask
                    wrap_align_mask = ~(boundary - 1);

                    if (hburst_reg == 3'd2 || hburst_reg == 3'd4 || hburst_reg == 3'd6) begin
                        // WRAP burst: align to WRAP boundary
                        burst_base_addr_next = (haddr_reg & wrap_align_mask);
                        burst_addr_next      = haddr_reg & align_mask;
                    end
                    else begin
                        // NON-WRAP burst: align to beat size
                        burst_base_addr_next = haddr_reg & align_mask;
                        burst_addr_next      = haddr_reg & align_mask;
                    end
                end
                else if(burst_active_reg && hready && htrans_reg == 2'b11 ) begin
                    burst_beats_next = burst_beats_reg + 1;
                    burst_base_addr_next = burst_base_addr_reg;

                    case(burst_type_reg)
                        3'd1: begin 
                            burst_addr_next = burst_addr_reg + burst_increment;
                            burst_active = 1'b1;
                        end

                        3'd3, 3'd5, 3'd7: begin
                            burst_addr_next = burst_addr_reg + burst_increment;
                            if (burst_beats_next >= burst_length)
                                burst_active = 1'b0;
                        end
                        3'd2, 3'd4, 3'd6: begin
                            burst_addr_next = burst_base_addr_reg +
                                (((burst_addr_reg - burst_base_addr_reg) + burst_increment) & wrap_mask);

                            if (burst_beats_next >= burst_length)
                                burst_active = 1'b0;
                        end
                        default:  burst_active = 1'b0;
                    endcase
                end
                else begin
                    burst_active        = burst_active_reg; // there's a burst
                    burst_type_next     = burst_type_reg; // what's teh burst type? (INCR/WRAP)
                    burst_addr_next     = burst_addr_reg;  // what address of the AHB reguister is the burst occuring at?
                    burst_base_addr_next = burst_base_addr_reg; // where is our next burst address at? depening on the byte-size
                    burst_beats_next    = burst_beats_reg;  // by how much are we jumping?
                end
        end
    end

    // effective haddr
    always_comb begin
        if(hburst_reg != 3'd0) begin
            effective_addr = burst_addr_reg;
        end
        else effective_addr = haddr_reg;
    end

    // assign effective_addr = (burst_active_reg ? burst_addr_reg : haddr_reg);
    assign valid_transfer =  hsel_reg && (htrans_reg == 2'b10 || htrans_reg == 2'b11 || burst_active_reg);

    ///----------------------------------------------------------
    // RAW Hazard
    //----------------------------------------------------------
    // raw hazard flag
    always_comb begin
        raw_hazard = 1'b0;
        // if(valid_transfer && hwrite_reg &&  // prev was write
        //             hsel && !hwrite &&              // current is read (effective_addr checks prev anyway)
        //             (haddr == haddr_reg)) raw_hazard = 1'b1;
        if(valid_transfer && hwrite_reg && hsel && !hwrite && (haddr >= 10'h010 && haddr <= 10'h017) && (haddr_reg >= 10'h010 && haddr_reg <= 10'h017) &&
                                                                    ((hsize == 3'd3 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd3) ||
                                                                    (hsize == 3'd2 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd2) || 
                                                                    (hsize == 3'd1 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd1))) raw_hazard = 1'b1;
        else if(valid_transfer && hwrite_reg && hsel && !hwrite && (haddr == 10'h022) && (haddr_reg  == 10'h022) &&
                                                                    ((hsize == 3'd3 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd3) ||
                                                                    (hsize == 3'd2 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd2) || 
                                                                    (hsize == 3'd1 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd1)))  raw_hazard = 1'b1;
        else if(valid_transfer && hwrite_reg && hsel && !hwrite && (haddr == 10'h024) && (haddr_reg  == 10'h024) &&
                                                                    ((hsize == 3'd3 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd3) || (hsize == 3'd3 && hsize_reg == 3'd3) ||
                                                                    (hsize == 3'd2 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd2) || (hsize == 3'd2 && hsize_reg == 3'd2) || 
                                                                    (hsize == 3'd1 && hsize_reg == 3'd0) || (hsize == 3'd0 && hsize_reg == 3'd1) || (hsize == 3'd1 && hsize_reg == 3'd1))) raw_hazard = 1'b1;                                                                                                                                                                                                                                                                                                    
        else raw_hazard = 1'b0;
    end

    ///----------------------------------------------------------
    // Stall Active
    //----------------------------------------------------------
    // stall active assertion
    always_comb begin
        stall_active = 1'b0;

        // if(controller_busy) stall_active = 1'b1;
        // if(weight_done || input_done) stall_active = 1'b1;
        if(buffer_error) stall_active = 1'b1;
        // else begin
        //     if((effective_addr == 10'h018 || effective_addr == 10'h019) && ~data_ready && ~hwrite) stall_active = 1'b1;
        // end
    end
    
    ///----------------------------------------------------------
    // Detect ERROR
    //----------------------------------------------------------
    //error_detected_now assertion (invalid addresses access)
    always_comb begin
        error_detected_now  = 1'b0; 
        
        if(hsel && (htrans == 2'b10 || htrans == 2'b11 || burst_active_reg) && hwrite && ~stall_active) begin
            if(haddr == 10'h018 || haddr == 10'h019 || haddr == 10'h01A || haddr == 10'h01B || haddr == 10'h01C || haddr == 10'h01D || haddr == 10'h01D ||haddr == 10'h01E || haddr == 10'h01F ||   
                haddr == 10'h020 || haddr == 10'h021 || haddr == 10'h023)  error_detected_now = 1'b1;
        end

        if(hsel && (htrans == 2'b10 || htrans == 2'b11 || burst_active_reg) && ~hwrite && ~stall_active) begin
            if (~(haddr >= 10'h010 && haddr <= 10'h024)) begin
                error_detected_now = 1'b1;
            end
        end
    end
    logic new_error;
    assign new_error = error_detected_now && !error_flag_reg;

    // FSM register for hresp and hready
    always_ff @(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            current_state <= IDLE;
            error_flag_reg <= 1'b0;
        end
        else begin
            current_state <= next_state;
            error_flag_reg <= error_flag_next;
        end
    end

    logic clear_here;
    assign clear_here = clear_error;
    // hresp && hready next state logic
    always_comb begin
        next_state = current_state;
        error_flag_next = error_flag_reg;

        if(clear_here) error_flag_next = 1'b0;
        else error_flag_next = error_flag_reg;

        case (current_state)
            IDLE: begin
                if (new_error) begin
                    next_state = ERROR1;
                    error_flag_next = 1'b1;   
                end
            end
            ERROR1: begin
                next_state = ERROR2;
            end
            ERROR2: begin 
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
        // next_state = current_state;
    end
    // hresp && hready output logic
    always_comb begin
        hresp = 1'b0;
        hready = 1'b1;
        clear_error = 1'b0;

        case(current_state)
            IDLE: begin
                clear_error = 1'b1;
                hresp = 1'b0;
                hready = 1'b1;
            end
            ERROR1: begin
                hresp = 1'b1;
                hready = 1'b0;
                clear_error = 1'b0;
            end
            ERROR2: begin 
                hresp = 1'b1;
                hready = 1'b1;
                clear_error = 1'b0;
            end
            default: begin
                hresp = 1'b0;
                hready = 1'b1;
                clear_error = 1'b0;
            end
        endcase
    end


    ///----------------------------------------------------------
    // WRITING
    //----------------------------------------------------------
    // weight register write
    always_comb begin
        weight = weight_reg; 
        weight_write_en = 1'b0;

//made a change here
        if((hwrite_reg && hsel_reg && (htrans_reg == 2'b10 || htrans_reg == 2'b11 || burst_active_reg)) && ~weight_done_latched && ~load_weights_latched && ~controller_busy && hready) begin
            case(effective_addr)
                10'h000:begin
                    weight_write_en = 1'b1;
                    if(hsize_reg == 3'd3) begin 
                        weight = hwdata;
                    end
                    else if(hsize_reg == 3'd2) begin
                        weight = {weight[63:32], hwdata[31:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        weight = {weight[63:16],hwdata[15:0]};
                    end
                    else begin
                        weight = {weight[63:8], hwdata[7:0]};
                    end
                end
                10'h001: begin
                    weight_write_en = 1'b1;
                    if (hsize_reg == 3'd3) weight = hwdata; 
                    else if (hsize_reg == 3'd2)  weight = {weight[63:40], hwdata[31:0], weight[7:0]};  
                    else if (hsize_reg == 3'd1)  weight = {weight[63:24], hwdata[15:0], weight[7:0]};   
                    else weight = {weight[63:16], hwdata[7:0], weight[7:0]};
                end
                10'h002: begin
                    weight_write_en = 1'b1;
                    if (hsize_reg == 3'd3) weight = hwdata; 
                    else if(hsize_reg == 3'd2) begin
                        weight = {weight[63:48], hwdata[31:0], weight[15:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        weight = {weight[63:32], hwdata[15:0], weight[15:0]};
                    end
                    else begin
                        weight = {weight[63:24], hwdata[7:0], weight[15:0]};
                    end
                end
                10'h003:begin
                    weight_write_en = 1'b1;
                    if (hsize_reg == 3'd3) weight = hwdata;
                    else if(hsize_reg == 3'd2)  begin
                        weight = {weight[63:56], hwdata[31:0], weight[23:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        weight = {weight[63:40], hwdata[15:0], weight[23:0]}; 
                    end
                    else begin
                        weight = {weight[63:32], hwdata[7:0], weight[23:0]}; 
                    end
                end
                10'h004:begin
                    weight_write_en = 1'b1;
                    if (hsize_reg == 3'd3) weight = hwdata;
                    else if(hsize_reg == 3'd2) begin
                        weight = {hwdata[31:0], weight[31:0]};       
                    end 
                    else if(hsize_reg == 3'd1) begin
                        weight = {weight[63:48], hwdata[15:0], weight[31:0]};
                    end
                    else begin
                        weight = {weight[63:40], hwdata[7:0], weight[31:0]}; 
                    end
                end
                10'h005: begin
                    weight_write_en = 1'b1;
                    if (hsize_reg == 3'd3) weight = hwdata;
                    else if (hsize_reg == 3'd2)  weight = {hwdata[31:0], weight[31:0]};               // 4B @ bytes[6:3] (overlap case handled by steering)
                    else if (hsize_reg == 3'd1)  weight = {weight[63:56], hwdata[15:0], weight[39:0]}; 
                    else begin
                        weight = {weight[63:48], hwdata[7:0], weight[39:0]};
                    end
                end
                10'h006: begin
                    weight_write_en = 1'b1;
                    if (hsize_reg == 3'd3) weight = hwdata;
                    else if (hsize_reg == 3'd2)  weight = {hwdata[31:0], weight[31:0]};
                    else if(hsize_reg == 3'd1) begin
                        weight = {hwdata[15:0],weight[47:0]};
                    end
                    else begin
                        weight = {weight[63:56], hwdata[7:0],weight[47:0]};
                    end
                end
                10'h007: begin
                    weight_write_en = 1'b1;
                    if (hsize_reg == 3'd3) weight = hwdata;
                    else if(hsize_reg == 3'd2) weight = {hwdata[31:0], weight[31:0]};   
                    else if(hsize_reg == 3'd1)  weight = {hwdata[15:0], weight[47:0]};  
                    else weight = {hwdata[7:0], weight[55:0]};
                end
                default:begin
                    weight = weight_reg;
                    weight_write_en = 1'b0;
                end
            endcase
        end
    end

    // input register write
    always_comb begin
        input_data = input_reg; 
        input_write_en = 1'b0;

        if((hwrite_reg && hsel_reg && (htrans_reg == 2'b10 || htrans_reg == 2'b11 || burst_active_reg)) && ~input_done && ~controller_busy && hready) begin
            case(effective_addr)
                10'h008:begin
                    input_write_en = 1'b1;
                    if(hsize_reg == 3'd3) begin 
                        input_data = hwdata;
                    end
                    else if(hsize_reg == 3'd2) begin
                        input_data = {input_data[63:32], hwdata[31:0]}; // do I need to register the input data from the controller?
                    end 
                    else if(hsize_reg == 3'd1) begin
                        input_data = {input_data[63:16], hwdata[15:0]};
                    end
                    else begin
                        input_data = {input_data[63:8], hwdata[7:0]};
                    end
                end
                10'h009: begin
                    input_write_en = 1'b1;
                    if (hsize_reg == 3'd3) input_data = hwdata;
                    else if(hsize_reg == 3'd2)  begin
                        input_data =  {input_data[63:40], hwdata[31:0], input_data[7:0]}; 
                    end 
                    else if(hsize_reg == 3'd1) begin
                        input_data = {input_data[63:24], hwdata[15:0], input_data[7:0]};
                    end
                    else begin
                        input_data = {input_data[63:16], hwdata[7:0], input_data[7:0]}; 
                    end
                end
                10'h00A: begin
                    input_write_en = 1'b1;
                    if (hsize_reg == 3'd3) input_data = hwdata; 
                    else if(hsize_reg == 3'd2) begin
                        input_data = {input_data[63:48], hwdata[31:0], input_data[15:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        input_data = {input_data[63:32], hwdata[15:0], input_data[15:0]};
                    end
                    else begin
                        input_data = {input_data[63:24], hwdata[7:0], input_data[15:0]};
                    end
                end
                10'h00B: begin
                    input_write_en = 1'b1;
                    if (hsize_reg == 3'd3) input_data = hwdata;
                    else if(hsize_reg == 3'd2)  begin
                        input_data = {input_data[63:56], hwdata[31:0], input_data[23:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        input_data = {input_data[63:40], hwdata[15:0], input_data[23:0]}; 
                    end
                    else begin
                        input_data = {input_data[63:32], hwdata[7:0], input_data[23:0]}; 
                    end
                end
                10'h00C:begin
                    input_write_en = 1'b1;
                    if (hsize_reg == 3'd3) input_data = hwdata;
                    else if(hsize_reg == 3'd2) begin
                        input_data = {hwdata[31:0], input_data[31:0]};       
                    end 
                    else if(hsize_reg == 3'd1) begin
                        input_data = {input_data[63:48], hwdata[15:0], input_data[31:0]};
                    end
                    else begin
                        input_data = {input_data[63:40], hwdata[7:0], input_data[31:0]}; 
                    end
                end
                10'h00D:begin
                    input_write_en = 1'b1;
                    if (hsize_reg == 3'd3) input_data = hwdata;
                    else if (hsize_reg == 3'd2)  input_data = {hwdata[31:0], input_data[31:0]};               // 4B @ bytes[6:3] (overlap case handled by steering)
                    else if (hsize_reg == 3'd1)  input_data = {input_data[63:56], hwdata[15:0], input_data[39:0]}; 
                    else begin
                        input_data = {input_data[63:48], hwdata[7:0], input_data[39:0]};
                    end
                end
                10'h00E:begin
                    input_write_en = 1'b1;
                    if (hsize_reg == 3'd3) input_data = hwdata;
                    else if (hsize_reg == 3'd2)  input_data = {hwdata[31:0], input_data[31:0]};
                    else if(hsize_reg == 3'd1) begin
                        input_data = {hwdata[15:0],input_data[47:0]};
                    end
                    else begin
                        input_data = {input_data[63:56], hwdata[7:0],input_data[47:0]};
                    end
                end
                10'h00F:begin 
                    input_write_en = 1'b1;
                    if (hsize_reg == 3'd3) input_data = hwdata;
                    else if(hsize_reg == 3'd2) input_data = {hwdata[31:0], input_data[31:0]};   
                    else if(hsize_reg == 3'd1)  input_data = {hwdata[15:0], input_data[47:0]};  
                    else input_data = {hwdata[7:0], input_data[55:0]};
                end
                default: begin 
                    input_data = input_reg;
                    input_write_en = 1'b0;
                end
            endcase
        end
    end

    // bias register write
    always_comb begin
        bias = bias_reg; 

        if((hwrite_reg && hsel_reg && (htrans_reg == 2'b10 || htrans_reg == 2'b11 || burst_active_reg)) && hready) begin
            case(effective_addr)
                10'h010:begin
                    if(hsize_reg == 3'd3) bias = hwdata;
                    else if(hsize_reg == 3'd2) begin
                        bias = {bias[63:32], hwdata[31:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        bias = {bias[63:16], hwdata[15:0]};
                    end
                    else begin
                        bias = {bias[63:8], hwdata[7:0]};
                    end
                end
                10'h011: begin
                    if (hsize_reg == 3'd3) bias = hwdata;
                    else if(hsize_reg == 3'd2)  begin
                        bias = {bias[63:40], hwdata[31:0], bias[7:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        bias = {bias[63:24], hwdata[15:0], bias[7:0]};
                    end
                    else begin
                        bias = {bias[63:16], hwdata[7:0], bias[7:0]};
                    end
                end
                10'h012: begin
                    if (hsize_reg == 3'd3)  bias = hwdata;
                    else if(hsize_reg == 3'd2) begin
                        bias = {bias[63:48], hwdata[31:0], bias[15:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        bias = {bias[63:32], hwdata[15:0], bias[15:0]};
                    end
                    else begin
                        bias = {bias[63:24], hwdata[7:0],  bias[15:0]};
                    end
                end
                10'h013:begin
                    if (hsize_reg == 3'd3) bias = hwdata;
                    else if(hsize_reg == 3'd2)  begin
                        bias = {bias[63:56], hwdata[31:0], bias[23:0]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        bias = {bias[63:40], hwdata[15:0], bias[23:0]};
                    end
                    else begin
                        bias = {bias[63:32], hwdata[7:0],  bias[23:0]};
                    end
                end
                10'h014: begin
                    if (hsize_reg == 3'd3) bias = hwdata;
                    else if (hsize_reg == 3'd2)  bias = {hwdata[31:0], bias[31:0]};
                    else if (hsize_reg == 3'd1)  bias = {bias[63:48], hwdata[15:0], bias[31:0]};
                    else bias = {bias[63:40], hwdata[7:0], bias[31:0]};
                end

                10'h015: begin
                    if (hsize_reg == 3'd3) bias = hwdata;
                    else if (hsize_reg == 3'd2)  bias = {hwdata[31:0], bias[31:0]};
                    else if (hsize_reg == 3'd1)  bias = {bias[63:56], hwdata[15:0], bias[39:0]};
                    else bias = {bias[63:48], hwdata[7:0], bias[39:0]};
                end

                10'h016: begin
                    if (hsize_reg == 3'd3) bias = hwdata;
                    else if (hsize_reg == 3'd2)  bias = {hwdata[31:0], bias[31:0]};
                    else if (hsize_reg == 3'd1)  bias = {hwdata[15:0], bias[47:0]};
                    else bias = {bias[63:56], hwdata[7:0], bias[47:0]};
                end

                10'h017: begin
                    if (hsize_reg == 3'd3) bias = hwdata;
                    else if(hsize_reg == 3'd2)  bias = {hwdata[31:0], bias[31:0]};              
                    else if(hsize_reg == 3'd1)  bias = {hwdata[15:0], bias[47:0]};             
                    else  bias = {hwdata[7:0], bias[55:0]}; 
                    end

                default: bias = bias_reg;
            endcase
        end
    end

    //control register write && Activation control
    always_comb begin
        control = control_reg; 
        act_control = act_control_reg;

        if((hwrite_reg && hsel_reg && (htrans_reg == 2'b10 || htrans_reg == 2'b11 || burst_active_reg)) && hready) begin
            case(effective_addr)
                10'h022:begin
                   if(hsize_reg == 3'd3) begin 
                        control = {control[63:48], hwdata[63:16]};
                    end
                    else if(hsize_reg == 3'd2) begin
                        control = {control[63:32], hwdata[47:16]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        control = {control[63:16], hwdata[31:16]};
                    end
                    else begin
                        control = {control[63:8], hwdata[23:16]};
                    end
                end
                10'h024: begin
                    if(hsize_reg == 3'd3) begin 
                        act_control = {act_control[63:32],hwdata[63:32]};
                    end
                    else if(hsize_reg == 3'd2) begin
                        act_control = {act_control[63:32], hwdata[63:32]};
                    end 
                    else if(hsize_reg == 3'd1) begin
                        act_control = {act_control[63:16], hwdata[47:32]};
                    end
                    else begin
                        act_control = {act_control[63:8], hwdata[39:32]};
                    end
                end
                default: begin
                    control = control_reg; 
                    act_control = act_control_reg;
                end
            endcase
        end
    end

    //load weights and start inference controlled
    always_comb begin
        load_weights = controller_reg[1];
        start_inference = controller_reg[0];

        if(systolic_done) load_weights = 1'b0;
        else load_weights = controller_reg[1];

        if(data_ready) start_inference  = 1'b0;
        else start_inference = controller_reg[0];
    end

    ///----------------------------------------------------------
    // READING
    //----------------------------------------------------------
    // resgister read
    logic [5:0] sh1;
    logic [5:0] sh2;
    always_comb begin
        sh1 = ({3'b0, haddr[2:0]} << 3);
        sh2 = ({4'b0, haddr[1:0]} << 3);
    end

    // old memory
    logic [63:0] old_mem_data;
    always_comb begin
        case (haddr_reg)
            10'h010, 10'h011, 10'h012, 10'h013, 10'h014, 10'h015, 10'h016, 10'h17: old_mem_data = bias_reg;
            10'h022: old_mem_data = control_reg;
            10'h024: old_mem_data = act_control_reg;
            default: old_mem_data = 64'd0; // 0x0 and 0x2 are read-only
        endcase
    end

    always_comb begin
        store_hrdata = 64'd0; 

        if((~hwrite_reg && hsel_reg && (htrans_reg == 2'b10 || htrans_reg == 2'b11 || burst_active_reg) && hready)) begin
            if(raw_hazard) begin
                if(hsize_reg == 3'd3 && hsize == 3'd3) begin 
                    store_hrdata = hwdata; // only testcase tb tests for
                end
                else if(hsize_reg == 3'd3 && hsize == 3'd2) begin
                    if (haddr[2] == 1'b0) // Reading lower 4 bytes
                        store_hrdata = {32'd0, hwdata[31:0]};
                    else // Reading upper 4 bytes
                        store_hrdata = {hwdata[63:32], 32'd0};
                end
                else if (hsize_reg == 3'd3 && hsize == 3'd1) begin
                    case (haddr[2:1])
                        2'b00: store_hrdata = {48'd0, hwdata[15:0]};
                        2'b01: store_hrdata = {32'd0, hwdata[31:16], 16'd0};
                        2'b10: store_hrdata = {16'd0, hwdata[47:32], 32'd0};
                        2'b11: store_hrdata = {hwdata[63:48], 48'd0};
                    endcase
                end
                else if (hsize_reg == 3'd3 && hsize == 3'd0) begin
                    case (haddr[2:0])
                        3'd0: store_hrdata = {56'd0, hwdata[7:0]}; // at address 10
                        3'd1: store_hrdata = {48'd0, hwdata[15:8], 8'd0}; // addr 11
                        3'd2: store_hrdata = {40'd0, hwdata[23:16], 16'd0}; // addr 12
                        3'd3: store_hrdata = {32'd0, hwdata[31:24], 24'd0}; // addr 13
                        3'd4: store_hrdata = {24'd0, hwdata[39:32], 32'd0};
                        3'd5: store_hrdata = {16'd0, hwdata[47:40], 40'd0};
                        3'd6: store_hrdata = { 8'd0, hwdata[55:48], 48'd0};
                        3'd7: store_hrdata = {hwdata[63:56], 56'd0};
                    endcase
                end
                else if (hsize_reg == 3'd2 && hsize == 3'd3) begin
                    // store_hrdata = {32'd0, hwdata[31:0]};
                    if(haddr_reg[2] == 1'b0) store_hrdata = {old_mem_data[63:32], hwdata[31:0]};
                    else store_hrdata = {hwdata[63:32], weight_reg[31:0]};
                end
                else if (hsize_reg == 3'd2 && hsize == 3'd2) begin   // should I use memory or clear it?
                    if(haddr[2] == haddr_reg[2]) begin
                        if(haddr[2] == 1'b0) store_hrdata = {32'd0, hwdata[31:0]};
                        else store_hrdata = {hwdata[63:32], 32'd0};
                    end
                    else begin
                        if(haddr[2] == 1'b0) store_hrdata = {32'd0, old_mem_data[31:0]};
                        else store_hrdata = {old_mem_data[63:32], 32'd0};
                    end
                end
                else if (hsize_reg == 3'd2 && hsize == 3'd1) begin
                    if(haddr_reg[2] == 1'b0) begin
                            case(haddr[2:1])
                                2'b00: store_hrdata = {48'd0, hwdata[15:0]};
                                2'b01: store_hrdata = {32'd0, hwdata[31:16], 16'd0};
                                default: store_hrdata = {16'd0, old_mem_data[47:32], 32'd0};
                            endcase
                        end
                    else begin
                        case(haddr[2:1])
                            2'b10: store_hrdata = {16'd0, hwdata[47:32], 32'd0};
                            2'b11: store_hrdata = {hwdata[63:48], 48'd0};
                            default: store_hrdata = {48'd0, old_mem_data[15:0]};
                        endcase
                    end
                end
                else if (hsize_reg == 3'd2 && hsize == 3'd0) begin
                    store_hrdata = {56'd0, (hwdata[7:0] << sh1)};
                end
            else if (hsize_reg == 3'd1 && hsize == 3'd3) begin
                case(haddr_reg[2:1])
                    2'b00: store_hrdata = {old_mem_data[63:16], hwdata[15:0]};
                    2'b01: store_hrdata = {old_mem_data[63:32], hwdata[31:16], old_mem_data[15:0]};
                    2'b10: store_hrdata = {old_mem_data[63:48], hwdata[47:32], old_mem_data[31:0]};
                    2'b11: store_hrdata = {hwdata[63:48], old_mem_data[47:0]};
                endcase
            end
            else if (hsize_reg == 3'd1 && hsize == 3'd2) begin
                if(haddr_reg[2] == 1'b0 && haddr[2] == 1'b0) begin // read and wrote into lower 4 bytes
                    if(haddr_reg[1] == 1'b0) store_hrdata = {32'd0, old_mem_data[31:16], hwdata[15:0]};
                    else store_hrdata = {32'd0, hwdata[31:16], old_mem_data[15:0]};
                end
                else if(haddr_reg[2] == 1'b1 && haddr[2] == 1'b1) begin
                    if(haddr_reg[1] == 1'b0) store_hrdata = {old_mem_data[63:48], hwdata[47:32], 32'd0};
                    else store_hrdata = {hwdata[63:48], old_mem_data[47:32], 32'd0};
                end
                else begin
                    if(haddr[2] == 1'b0) store_hrdata = {32'd0, old_mem_data[31:0]};
                    else store_hrdata = {old_mem_data[63:32], 32'd0};
                end
            end
            else if (hsize_reg == 3'd1 && hsize == 3'd1) begin
                if(haddr[2:1] == haddr_reg[2:1]) begin
                    case(haddr[2:1])
                        2'b00: store_hrdata = {48'd0, hwdata[15:0]};
                        2'b01: store_hrdata = {32'd0, hwdata[31:16], 16'd0};
                        2'b10: store_hrdata = {16'd0, hwdata[47:32], 32'd0};
                        2'b11: store_hrdata = {hwdata[63:48], 48'd0};
                    endcase
                end
                else begin
                    case(haddr[2:1])
                        2'b00: store_hrdata = {48'd0, old_mem_data[15:0]};
                        2'b01: store_hrdata = {32'd0, old_mem_data[31:16], 16'd0};
                        2'b10: store_hrdata = {16'd0, old_mem_data[47:32], 32'd0};
                        2'b11: store_hrdata = {old_mem_data[63:48], 48'd0};
                    endcase
                end
            end
            else if (hsize_reg == 3'd1 && hsize == 3'd0) begin
                store_hrdata = {56'd0, (hwdata[7:0] << sh1)};
            end
            else if (hsize_reg == 3'd0 && hsize == 3'd3) begin
                case(haddr_reg[2:0])
                    3'd0: store_hrdata = {old_mem_data[63:8], hwdata[7:0]};
                    3'd1: store_hrdata = {old_mem_data[63:16], hwdata[15:8], old_mem_data[7:0]};
                    3'd2: store_hrdata = {old_mem_data[63:24], hwdata[23:16], old_mem_data[15:0]};
                    3'd3: store_hrdata = {old_mem_data[63:32], hwdata[31:24], old_mem_data[23:0]};
                    3'd4: store_hrdata = {old_mem_data[63:40], hwdata[39:32], old_mem_data[31:0]};
                    3'd5: store_hrdata = {old_mem_data[63:48], hwdata[47:40], old_mem_data[39:0]};
                    3'd6: store_hrdata = {old_mem_data[63:56], hwdata[55:48], old_mem_data[47:0]};
                    3'd7: store_hrdata = {hwdata[63:56], old_mem_data[55:0]};
                endcase
            end
            else if (hsize_reg == 3'd0 && hsize == 3'd2) begin
                store_hrdata = {48'd0, (hwdata[15:0] << sh2)};
            end
            else if (hsize_reg == 3'd0 && hsize == 3'd1) begin
                if (haddr_reg[0] == 0) store_hrdata = {48'd0, hwdata[15:0]};
                else store_hrdata = {32'd0, hwdata[31:16], 16'd0};
            end
            else if(hsize_reg == 0 && hsize == 0) begin  
                if(haddr[0] == haddr_reg[0]) begin
                    if(haddr[0] == 1'b0) store_hrdata = {56'd0, hwdata[7:0]};
                    else store_hrdata = {48'd0, hwdata[15:8], 8'd0};
                end
                else begin
                    if(haddr[0] == 1'b0) store_hrdata = {56'd0, old_mem_data[7:0]};
                    else store_hrdata = {48'd0, old_mem_data[15:8], 8'd0};
                end
            end
            else store_hrdata = old_mem_data;
            end
            else begin
                case(effective_addr)
                    10'h010:begin
                        if(hsize_reg == 3'd3) store_hrdata = bias;
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {32'd0, bias[31:0]};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {48'd0,bias[15:0]};
                        end
                        else begin
                            store_hrdata = {56'd0, bias[7:0]};
                        end
                    end
                    10'h011: begin
                        if(hsize_reg == 3'd3) store_hrdata = bias;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {24'd0, bias[39:8], 8'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {40'd0, bias[23:8], 8'd0};
                        end
                        else begin
                            store_hrdata = {48'd0, bias[15:8], 8'd0};
                        end
                    end
                    10'h012: begin
                        if(hsize_reg == 3'd3) store_hrdata = bias;
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {16'd0, bias[47:16], 16'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {32'd0, bias[31:16], 16'd0};
                        end
                        else begin
                            store_hrdata = {40'd0, bias[23:16],  16'd0};
                        end
                    end
                    10'h013:begin
                        if(hsize_reg == 3'd3) store_hrdata = bias;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {8'd0, bias[55:24], 24'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {24'd0, bias[39:24], 24'd0};
                        end
                        else begin
                            store_hrdata = {32'd0, bias[31:24], 24'd0};
                        end
                    end
                    10'h014:begin
                        if(hsize_reg == 3'd3) store_hrdata = bias;
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {bias[63:32], 32'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata =  {16'd0, bias[47:32], 32'd0};
                        end
                        else begin
                            store_hrdata = {24'd0, bias[39:32],  32'd0};
                        end
                    end
                    10'h015: begin
                        if (hsize_reg == 3'd3) store_hrdata = bias;
                        else if (hsize_reg == 3'd2)  store_hrdata = {bias[63:32], 32'd0};
                        else if (hsize_reg == 3'd1)  store_hrdata = {8'd0, bias[55:40], 40'd0};
                        else store_hrdata = {16'd0,bias[47:40], 40'd0};
                    end
                    10'h016: begin
                        if (hsize_reg == 3'd3) store_hrdata = bias;
                        else if (hsize_reg == 3'd2)  store_hrdata = {bias[63:32], 32'd0};
                        else if (hsize_reg == 3'd1)  store_hrdata = {bias[63:48],48'd0};
                        else store_hrdata = {8'd0, bias[55:48],48'd0};
                    end
                    10'h017:begin
                        if (hsize_reg == 3'd3) store_hrdata = bias;
                        else if(hsize_reg == 3'd2)  store_hrdata = {bias[63:32], 32'd0};              
                        else if(hsize_reg == 3'd1)  store_hrdata = {bias[63:48], 48'd0};       
                        else store_hrdata = {bias[63:56], 56'd0};
                    end
                    10'h018:begin
                            if(hsize_reg == 3'd3) store_hrdata = output_reg;
                            else if(hsize_reg == 3'd2) begin
                                store_hrdata = {32'd0, output_reg[31:0]};
                            end 
                            else if(hsize_reg == 3'd1) begin
                                store_hrdata = {48'd0, output_reg[15:0]};
                            end
                            else begin
                                store_hrdata = {56'd0, output_reg[7:0]};
                            end
                    end
                    10'h019: begin
                            if(hsize_reg == 3'd3) store_hrdata = output_reg;
                            else if(hsize_reg == 3'd2)  begin
                                store_hrdata = {24'd0, output_reg[39:8], 8'd0};
                            end 
                            else if(hsize_reg == 3'd1) begin
                                store_hrdata = {40'd0, output_reg[23:8], 8'd0};
                            end
                            else begin
                                store_hrdata = {48'd0, output_reg[15:8], 8'd0};
                            end
                    end
                    10'h01A: begin
                        if(hsize_reg == 3'd3) store_hrdata = output_reg;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {16'd0, output_reg[47:16], 16'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {32'd0, output_reg[31:16], 16'd0};
                        end
                        else begin
                            store_hrdata = {40'd0, output_reg[23:16], 16'd0};
                        end
                    end
                    10'h01B: begin
                        if(hsize_reg == 3'd3) store_hrdata = output_reg;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {8'd0, output_reg[55:24], 24'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {24'd0, output_reg[39:24], 24'd0};
                        end
                        else begin
                            store_hrdata = {32'd0, output_reg[31:24], 24'd0};
                        end
                    end
                    10'h01C:begin
                        if(hsize_reg == 3'd3) store_hrdata = output_reg;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {output_reg[63:32], 32'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {16'd0, output_reg[47:32], 32'd0};
                        end
                        else begin
                            store_hrdata = {24'd0, output_reg[39:32], 32'd0};
                        end
                    end
                    10'h01D:begin
                        if(hsize_reg == 3'd3) store_hrdata = output_reg;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {output_reg[63:32], 32'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {8'd0, output_reg[55:40], 40'd0};
                        end
                        else begin
                            store_hrdata = {16'd0, output_reg[47:40], 40'd0};
                        end
                    end
                    10'h01E:begin
                        if(hsize_reg == 3'd3) store_hrdata = output_reg;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {output_reg[63:32], 32'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {output_reg[63:48], 48'd0};
                        end
                        else begin
                            store_hrdata = {8'd0, output_reg[55:48], 48'd0};
                        end
                    end
                    10'h01F:begin
                        if(hsize_reg == 3'd3) store_hrdata = output_reg;
                        else if(hsize_reg == 3'd2)  begin
                            store_hrdata = {output_reg[63:32], 32'd0};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {output_reg[63:48], 48'd0};
                        end
                        else begin
                            store_hrdata = {output_reg[63:56], 56'd0};
                        end
                    end
                    10'h020:begin
                        if(hsize_reg == 3'd3) begin
                            store_hrdata = {55'd0, device_busy, 7'd0, buffer_error};
                        end
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {55'd0, device_busy, 7'd0,buffer_error};
                        end
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata ={55'd0, device_busy, 7'd0, buffer_error};
                        end
                        else begin
                            store_hrdata = {63'd0, buffer_error};
                        end
                    end
                    10'h021: begin
                        if(hsize_reg == 3'd3) begin
                            store_hrdata = {55'd0, device_busy, 8'd0};
                        end
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {55'd0, device_busy, 8'd0};
                        end
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata ={55'd0, device_busy, 8'd0};
                        end
                        else begin
                            store_hrdata = 64'd0;
                        end
                    end
                    10'h22: begin
                        // if(hsize_reg == 3'd3) begin
                        //     store_hrdata = {62'd0, control[1:0]};
                        // end
                        // else if(hsize_reg == 3'd2) begin
                        //     store_hrdata = {62'd0, control[1:0]};
                        // end
                        // else if(hsize_reg == 3'd1) begin
                        //     store_hrdata = {62'd0, control[1:0]};
                        // end
                        // else begin
                        //     store_hrdata = {62'd0, control[1:0]};
                        // end
                        if(hsize_reg == 3'd3) store_hrdata = control;
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {32'd0, control[31:0]};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {48'd0,control[15:0]};
                        end
                        else begin
                            store_hrdata = {56'd0, control[7:0]};
                        end
                    end
                    10'h023: begin 
                        if(hsize_reg == 3'd3) begin
                            store_hrdata = {62'd0, controller_busy, data_ready};
                        end
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {62'd0, controller_busy, data_ready};
                        end
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {62'd0, controller_busy, data_ready};
                        end
                        else begin
                            store_hrdata = {62'd0, controller_busy, data_ready};
                        end
                    end
                    10'h024: begin
                        if(hsize_reg == 3'd3) store_hrdata = act_control;
                        else if(hsize_reg == 3'd2) begin
                            store_hrdata = {32'd0, act_control[31:0]};
                        end 
                        else if(hsize_reg == 3'd1) begin
                            store_hrdata = {48'd0,act_control[15:0]};
                        end
                        else begin
                            store_hrdata = {56'd0, act_control[7:0]};
                        end
                        // if(hsize_reg == 3'd3) begin
                        //     store_hrdata = {61'd0, activation_mode};
                        // end
                        // else if(hsize_reg == 3'd2) begin
                        //     store_hrdata = {61'd0, activation_mode};
                        // end
                        // else if(hsize_reg == 3'd1) begin
                        //     store_hrdata = {61'd0, activation_mode};
                        // end
                        // else begin
                        //     store_hrdata = {61'd0, activation_mode};
                        // end
                    end
                    default: store_hrdata = 64'd0;
                endcase
            end
        end            
    end


endmodule

