`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_sram_controller ();

    localparam CLK_PERIOD = 10ns;

    logic clk, n_rst;
    logic load_weights;
    logic start_inference;
    logic load_weights_en;
    logic load_inputs_en;
    logic [63:0] input_reg;
    logic [63:0] weight_reg;
    logic activation_ready;
    logic [63:0] activations;
    logic controller_busy;
    logic data_ready;
    logic [63:0] output_reg;
    logic start_array;
    logic start_weights;
    logic [63:0] systolic_data;
    logic weights_done;
    logic inputs_done;
    logic activated;



    sram_controller DUT (
        .clk(clk),
        .n_rst(n_rst),
        .load_weights(load_weights),
        .start_inference(start_inference),
        .load_weights_en(load_weights_en),
        .load_inputs_en(load_inputs_en),
        .input_reg(input_reg),
        .weight_reg(weight_reg),
        .activation_ready(activation_ready),
        .activations(activations),
        .activated(activated),
        .controller_busy(controller_busy),
        .data_ready(data_ready),
        .start_array(start_array),
        .start_weights(start_weights),
        .systolic_data(systolic_data),
        .weights_done(weights_done),
        .inputs_done(inputs_done),
        .output_reg(output_reg),
        .occupancy_err(occupancy_err),
        .num_input(num_input)
    );

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


    task initialize_dut;
    begin
        load_weights = 0;
        start_inference = 0;
        load_weights_en = 0;
        load_inputs_en = 0;
        activation_ready = 0;
        input_reg = 0;
        weight_reg = 0;
        activations = 0; 
        // $display("initialize dut done");
    end
    endtask

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



//     //sram write thru controller
task do_weight_write(input logic [63:0] w);
    begin
        $display("[%0t] WRITE weight request: data=%h", $time, w);
        weight_reg = w;
        load_weights_en = 1;
        @(posedge clk);
        load_weights_en = 0;
        @(posedge clk);
    end
endtask

task do_input_write(input logic [63:0] i);
    begin
        $display("[%0t] WRITE input request: data=%h", $time, i);
        input_reg = i;
        load_inputs_en = 1;
        @(posedge clk);
        load_inputs_en = 0;
        @(posedge clk);
    end
endtask

task do_output_write(input logic [63:0] a);
    begin
        $display("[%0t] WRITE output request: data=%h", $time, a);

        // activation_ready = 1;
        // @(posedge clk);
        // activations =a;
        // activation_ready = 0;
        // @(posedge clk);
        // @(posedge clk);
        activations = a;
        activated= 1;
        @(posedge clk);
        activated = 0;
        @(posedge clk);        

    end
endtask
task do_weight_read();
    begin
        @(posedge clk);
        @(posedge clk);
    end
endtask 

task do_input_read();
    begin
        @(posedge clk);
        @(posedge clk);
    end
endtask 

    initial begin

        initialize_dut();
        n_rst = 1;
        reset_dut();
        $display("[%0t]test case 1: for 8 weight writes to sram and 8 weight reads from", $time);
        do_weight_write(64'h1111_2222_3333_4444);  
        do_weight_write(64'h2222_3333_4444_5555);  
        do_weight_write(64'h1111_2222_3333_4444);  
        do_weight_write(64'h2222_3333_4444_5555); 
        do_weight_write(64'h1111_2222_3333_4444);  
        do_weight_write(64'h2222_3333_4444_5555);  
        do_weight_write(64'h1111_2222_3333_4444);  
        do_weight_write(64'h2222_3333_4444_5555);  
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

        // reset_dut();
        // $display("[%0t]test case 2: for <8 weight writes to sram go back to idle", $time);
        // do_weight_write(64'h1111_1111_1111_1111);  
        // do_weight_write(64'h2222_2222_2222_2222);  
        // do_weight_write(64'h3333_3333_3333_3333);  
        // do_weight_write(64'h4444_4444_4444_4444); 
        // load_weights = 1;
        // @(posedge clk);
        // load_weights = 0;


        // reset_dut();
        // $display("[%0t]test case 3: for >8 weight writes to sram assert weights_done but load_weights_en is still high -> occupancy err", $time);
        // do_weight_write(64'h1111_1111_1111_1111);  
        // do_weight_write(64'h2222_2222_2222_2222);  
        // do_weight_write(64'h3333_3333_3333_3333);  
        // do_weight_write(64'h4444_4444_4444_4444); 
        // do_weight_write(64'h5555_5555_5555_5555);  
        // do_weight_write(64'h6666_6666_6666_6666);  
        // do_weight_write(64'h7777_7777_7777_7777);  
        // do_weight_write(64'h8888_8888_8888_8888); 
        // do_weight_write(64'h9999_9999_9999_9999); 
        // load_weights = 1;
        // @(posedge clk);
        // load_weights = 0;

        // reset_dut();
        $display("[%0t]test case 4: for 8 inputs writes to sram and 8 inputs reads to systolic array", $time);
        do_input_write(64'h1111_1111_1111_1111);  
        do_input_write(64'h2222_2222_2222_2222);  
        do_input_write(64'h3333_3333_3333_3333);  
        do_input_write(64'h4444_4444_4444_4444); 
        do_input_write(64'h5555_5555_5555_5555);  
        do_input_write(64'h6666_6666_6666_6666);  
        do_input_write(64'h7777_7777_7777_7777);  
        do_input_write(64'h8888_8888_8888_8888);  
        start_inference= 1;
        @(posedge clk);
        start_inference = 0; 



        ///////////////////////////////////////////NON MULTIPLE OF 8S NOT WORKING ATM////////////////////////////////////
        // reset_dut();
        // $display("[%0t]test case 5: for 5 inputs writes to sram and 5 inputs to systolic array", $time);
        // do_input_write(64'h1111_2222_3333_4444);  
        // do_input_write(64'h2222_3333_4444_5555);  
        // do_input_write(64'h1111_2222_3333_4444);  
        // do_input_write(64'h2222_3333_4444_5555); 
        // do_input_write(64'h1111_2222_3333_4444);  
        // start_inference= 1;
        // @(posedge clk);
        // start_inference = 0; 

        // reset_dut();
        // $display("[%0t]test case 4: for 10 inputs writes to sram and 10 inputs to systolic array", $time);
        // do_input_write(64'h1111_2222_3333_4444);  
        // do_input_write(64'h2222_3333_4444_5555);  
        // do_input_write(64'h1111_2222_3333_4444);  
        // do_input_write(64'h2222_3333_4444_5555); 
        // do_input_write(64'h1111_2222_3333_4444);  
        // do_input_write(64'h2222_3333_4444_5555);  
        // do_input_write(64'h1111_2222_3333_4444);  
        // do_input_write(64'h2222_3333_4444_5555); 
        // do_input_write(64'h2222_3333_4444_5555); 
        // do_input_write(64'h1111_2222_3333_4444); 
        // start_inference= 1;
        // @(posedge clk);
        // start_inference = 0; 

        ///////////////////////////////////////////NON MULTIPLE OF 8S NOT WORKING ATM////////////////////////////////////

        
        // reset_dut();
        // // num_input = 4'h8;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);        
        activation_ready = 1;
        @(posedge clk);
        activation_ready = 0; 
        $display("[%0t]test case 5: for 8 activation writes to sram and 8 output writes to subordinate", $time);
        do_output_write(64'h1212_1212_1212_1212);  
        do_output_write(64'h2222_2222_2222_2222);  
        do_output_write(64'h3333_3333_3333_3333);  
        do_output_write(64'h4444_4444_4444_4444); 
        do_output_write(64'h5454_5454_5454_5454);  
        do_output_write(64'h6666_6666_6666_6666);  
        do_output_write(64'h7777_7777_7777_7777);  
        do_output_write(64'h8888_8888_8888_8888);  
        // activation_ready = 0;

        #1000;
        $finish;
    end
endmodule

// /* verilator coverage_on */
