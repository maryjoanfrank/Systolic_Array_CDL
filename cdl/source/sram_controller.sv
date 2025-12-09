`timescale 1ns / 10ps

module sram_controller #(
    // parameters
) (
    input clk, n_rst,

    //subordinate inputs
    input logic load_weights,
    input logic start_inference,
    input logic load_weights_en,
    input logic load_inputs_en,

    //activation block inputs
    input logic activation_ready,
    input logic activated,
    // input logic num_outputs,

    //datapath
    input  logic [63:0]  input_reg,
    input  logic [63:0]  weight_reg,
    input  logic [63:0]  activations,   // from activation block
    
    //subordinate outputs 
    output logic controller_busy,
    output logic data_ready,
    output logic [63:0] output_reg,
    output logic weights_done,
    output logic inputs_done,
    output logic occupancy_err,
    output logic invalid,

    //systolic array outputs 
    output logic start_weights,
    output logic start_array,
    output logic [7:0] num_input,
    output logic [63:0] systolic_data

);

//internal controller sram_buffer signals 
    logic ren, wen;
    logic [9:0] addr;
    // logic [63:0] write_data;
    logic [63:0] write_data0, write_data1, write_data2, write_data3;
    logic [63:0] read_data0, read_data1, read_data2, read_data3;

    logic cs0, cs1, cs2, cs3;

    logic [3:0] chip_select;
    assign chip_select = {cs3, cs2, cs1, cs0};

controller inst_controller (
        .clk            (clk),
        .n_rst          (n_rst),
        .load_weights   (load_weights),
        .start_inference(start_inference),
        .load_weights_en(load_weights_en),
        .load_inputs_en (load_inputs_en),
        .activation_ready (activation_ready), 
        .input_reg      (input_reg),
        .weight_reg     (weight_reg),
        .read_data0     (read_data0),
        .read_data1     (read_data1),
        .read_data2     (read_data2),
        .read_data3     (read_data3),
        .activations    (activations),
        .invalid (invalid),
        .activated(activated),
        // .num_outputs (num_outputs),
        .controller_busy(controller_busy),
        .data_ready     (data_ready),
        .ren            (ren),
        .wen            (wen),
        .start_array           (start_array),
        .start_weights    (start_weights),
        .output_reg     (output_reg),
        .occupancy_err(occupancy_err),
        .num_input(num_input),
        .weights_done   (weights_done),
        // .write_data     (write_data),
        .write_data0 (write_data0),
        .write_data1(write_data1),
        .write_data2 (write_data2),
        .write_data3 (write_data3),
        .cs0            (cs0),
        .cs1            (cs1),
        .cs2            (cs2),
        .cs3            (cs3),
        .addr           (addr),
        .systolic_data  (systolic_data),
        .inputs_done    (inputs_done)
    );


sram_buffer inst_sram_buffer (
        .clk (clk),
        .n_rst (n_rst),
        .ren (ren),
        .wen (wen),
        .addr (addr),
        // .write_data (write_data),
        .write_data0 (write_data0),
        .write_data1(write_data1),
        .write_data2 (write_data2),
        .write_data3 (write_data3),
        .chip_select (chip_select),
        .read_data0 (read_data0),
        .read_data1 (read_data1),
        .read_data2 (read_data2),
        .read_data3 (read_data3)
    );
endmodule

