`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_sram_controller ();

    localparam CLK_PERIOD = 10ns;

    // logic clk, n_rst;
    // logic load_weights;
    // logic start_inference;
    // logic load_weights_en;
    // logic load_inputs_en;
    // logic [63:0] input_reg;
    // logic [63:0] weight_reg;
    // logic activation_ready;
    // logic [63:0] activations;
    // logic controller_busy;
    // logic data_ready;
    // logic [63:0] output_reg;
    // logic start_array;
    // logic start_weights;
    // logic [63:0] systolic_data;
    // logic weights_done;
    // logic inputs_done;
    // logic activated;

    logic clk, n_rst;
    logic load_weights;
    logic start_inference;
    logic load_weights_en; 
    logic load_inputs_en; 

    logic [63:0] input_reg;
    logic [63:0] weight_reg;
    logic [63:0] read_data0, read_data1, read_data2, read_data3,read_data4, read_data5, read_data6, read_data7;
    
     logic [63:0] activations;
     logic activated;

    logic controller_busy;
     logic data_ready;
    logic [7:0] r_trigger, w_trigger;
    logic start_weights;
    logic  start_array;
    logic [63:0]  output_reg;
    logic weights_done;
    // output logic invalid, 
    // output logic enable,
    logic [63:0] write_data0, write_data1, write_data2, write_data3,  write_data4, write_data5, write_data6, write_data7; 
    logic cs0,cs1,cs2,cs3, cs4,cs5,cs6,cs7; 
    logic [9:0] addr;
    logic [63:0] systolic_data;
    logic inputs_done;
    // output logic occupancy_err, 
    // output logic [6:0] num_input     
    



    // sram_controller DUT (
    //     .clk(clk),
    //     .n_rst(n_rst),
    //     .load_weights(load_weights),
    //     .start_inference(start_inference),
    //     .load_weights_en(load_weights_en),
    //     .load_inputs_en(load_inputs_en),
    //     .input_reg(input_reg),
    //     .weight_reg(weight_reg),
    //     .activation_ready(activation_ready),
    //     .activations(activations),
    //     .activated(activated),
    //     .controller_busy(controller_busy),
    //     .data_ready(data_ready),
    //     .start_array(start_array),
    //     .start_weights(start_weights),
    //     .systolic_data(systolic_data),
    //     .weights_done(weights_done),
    //     .inputs_done(inputs_done),
    //     .output_reg(output_reg),
    //     .occupancy_err(occupancy_err),
    //     .num_input(num_input)
    // );
task do_weight_write(input logic [63:0] w);
    begin
        load_weights_en = 1;
        weight_reg = w;
        @(posedge clk);
        load_weights_en = 0;
    end
endtask

task do_weight_read();
    begin
        @(negedge clk);
        @(negedge clk);
    end
endtask 

task do_input_write(input logic [63:0] i);
    begin
        load_inputs_en = 1;
        input_reg = i;
        @(posedge clk);
        load_inputs_en = 0;
    end
endtask

task do_input_read();
    begin
        @(negedge clk);
        @(negedge clk);
    end
endtask 
task do_output_write(input logic [63:0] a);
    begin
        activated = 1;
        // output_reg = o;
        activations = a;
        @(posedge clk);
        activated = 0;
    end
endtask

task do_output_read();
    begin
        @(negedge clk);
        @(negedge clk);
    end
endtask 




task initialize_dut;
    begin
        load_weights = 0;
        load_weights_en = 0;
        weight_reg = 0;
        start_inference = 0;
        load_inputs_en = 0;
        input_reg = 0;
        activated = 0;

    end
endtask

    sram_controller #() DUT (.*);

    // clockgen
    always begin
        clk = 0;
        // $display("clock0");
        #(CLK_PERIOD / 2.0);
        // #5;
        clk = 1;
        // $display("clock1");
        #(CLK_PERIOD / 2.0);
        // #5;
    end



    task reset_dut;
    begin
        n_rst = 0;   
        // $display("reset asserted");    
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(negedge clk);
        @(negedge clk);
        // $display("reset deasserted");
    end
    endtask

    initial begin

        initialize_dut();
        n_rst = 1;
        reset_dut();
        // $display("[%0t]test case 1: for 8 weight writes to sram and 8 weight reads from", $time);
        @(posedge clk);
        // weight_reg = 64'h1111_2222_3333_4444;
        // load_weights_en = 1;
        // @(posedge clk);
        // load_weights_en = 0;
        // @(posedge clk);
        // load_weights_en = 1;
        // weight_reg = 64'h2222_3333_4444_5555;
        // @(posedge clk);
        // load_weights_en = 0;
        // @(posedge clk);
        // @(posedge clk);
        // @(posedge clk);
        do_weight_write(64'h1111_2222_3333_4444);
        do_weight_write(64'h2222_3333_4444_5555);  
        do_weight_write(64'h1111_2222_3333_4444);  
        do_weight_write(64'h2222_3333_4444_5555); 
        do_weight_write(64'h1111_2222_3333_4444);  
        do_weight_write(64'h2222_3333_4444_5555);  
        do_weight_write(64'h1111_2222_3333_4444);  
        do_weight_write(64'h4444_5555_2222_3333);  
        // do_weight_write(64'h2222_3333_4444_5555); 
        // repeat (4) @(posedge clk); 
        load_weights = 1;
        @(posedge clk);
        load_weights = 0;
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();

        $display("[%0t]test case 2: for 8 input writes to sram and 8 input reads from", $time);
        @(posedge clk);
        // input_reg = 64'h1111_2222_3333_4444;
        // load_inputs_en = 1;
        // @(posedge clk);
        // load_weights_en = 0;
        // @(posedge clk);
        // load_inputs_en = 1;
        // input_reg = 64'h2222_3333_4444_5555;
        // @(posedge clk);
        // load_weights_en = 0;
        // @(posedge clk);
        // @(posedge clk);
        // @(posedge clk);
        do_input_write(64'h1111_2222_3333_4444);
        do_input_write(64'h2222_3333_4444_5555);  
        do_input_write(64'h1111_2222_3333_4444);  
        do_input_write(64'h2222_3333_4444_5555); 
        do_input_write(64'h1111_2222_3333_4444);  
        do_input_write(64'h2222_3333_4444_5555);  
        do_input_write(64'h1111_2222_3333_4444);  
        do_input_write(64'h4444_5555_2222_3333);  
        do_input_write(64'h2222_3333_4444_5555); 
        // repeat (4) @(posedge clk); 
        start_inference = 1;
        @(posedge clk);
        start_inference = 0;
        do_input_read();
        do_input_read();
        do_input_read();
        do_input_read();
        do_input_read();
        do_input_read();
        do_input_read();
        do_input_read();


        $display("[%0t]test case 5: for 8 activation writes to sram and 8 output writes to subordinate", $time);
        do_output_write(64'h1212_1212_1212_1212);  
        do_output_write(64'h2222_2222_2222_2222);  
        do_output_write(64'h3333_3333_3333_3333);  
        do_output_write(64'h4444_4444_4444_4444); 
        do_output_write(64'h5454_5454_5454_5454);  
        do_output_write(64'h6666_6666_6666_6666);  
        do_output_write(64'h7777_7777_7777_7777);  
        do_output_write(64'h8888_8888_8888_8888);  


        #1000;
        $finish;
    end
endmodule

// /* verilator coverage_on */
