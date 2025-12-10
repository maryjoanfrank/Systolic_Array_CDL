`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_controller ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic load_weights;
    // input logic start_inference,
    logic load_weights_en; 
    // input logic load_inputs_en, 

    // input  logic [63:0] input_reg,
    logic [63:0] weight_reg;
    logic [63:0] read_data0, read_data1, read_data2, read_data3,read_data4, read_data5, read_data6, read_data7;
    
    // input logic [63:0] activations, 
    // input logic activated, 

    logic controller_busy;
    // output logic data_ready, 
    logic [7:0] r_trigger, w_trigger;
    logic start_weights;
    // output logic  start_array,
    // output logic [63:0]  output_reg,
    // output logic weights_done, 
    // output logic invalid, 
    // output logic enable,
    logic [63:0] write_data0, write_data1, write_data2, write_data3,  write_data4, write_data5, write_data6, write_data7; 
    logic cs0,cs1,cs2,cs3, cs4,cs5,cs6,cs7; 
    logic [9:0] addr;
    logic [63:0] systolic_data;
    // output logic inputs_done, 
    // output logic occupancy_err, 
    // output logic [6:0] num_input     

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

task do_weight_write(input logic [63:0] w);
    begin
        
        @(negedge clk);
        load_weights_en = 1;
        weight_reg = w;
    end
endtask

task do_weight_read();
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
    end
endtask

    controller #() DUT (.*);

    initial begin
        n_rst = 1;
        reset_dut;

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
        @(negedge clk);
        load_weights_en = 0;
        load_weights = 1;
        @(negedge clk);
        load_weights = 0;
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();
        do_weight_read();

        
        #1000;
        $finish;
    end
endmodule

/* verilator coverage_on */

