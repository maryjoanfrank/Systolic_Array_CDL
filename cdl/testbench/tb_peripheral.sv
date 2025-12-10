`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_peripheral ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic load_weights, start_inference, load_weights_en, load_inputs_en;
    logic [1:0] activation_mode;
    logic [63:0] input_reg, weight_reg, activations, bias_vec;
    logic controller_busy, data_ready, weights_done, inputs_done, occupancy_err, invalid;
    logic [63:0] output_reg;


    // clockgen 
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(posedge clk);
        @(posedge clk);
    end
    endtask


    task initialize_dut;
    begin
        load_weights = 0;
        start_inference = 0;
        load_weights_en = 0;
        load_inputs_en = 0;
        activation_mode = 0;
        input_reg = 0;
        weight_reg = 0;
        bias_vec = 0;
    end
    endtask

task do_weight_write(input logic [63:0] w);
    begin
        
        load_weights_en = 1;
        weight_reg = w;
        @(posedge clk);
        load_weights_en = 0;
        
        // @(posedge clk);
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

// task do_output_write(input logic [63:0] a);
//     begin
//         // activated = 1;
//         // output_reg = o;
//         activations = a;
//         @(posedge clk);
//         // activated = 0;
//     end
// endtask

task do_weight_read();
    begin
        @(negedge clk);
        @(negedge clk);
    end
endtask 

task do_input_read();
    begin
        @(negedge clk);
        @(negedge clk);
    end
endtask 

task do_output_read();
    begin
        @(negedge clk);
        @(negedge clk);
    end
endtask 


    peripheral #() DUT (.*);

    initial begin
        initialize_dut();
        n_rst = 1;
        reset_dut();

        $display("[%0t]test case 1: for 8 weight writes to sram and 8 weight reads from", $time);
        @(posedge clk);
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

        #1000;
        $finish;
    end
endmodule

/* verilator coverage_on */

