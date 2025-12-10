`timescale 1ns / 10ps

module peripheral #(
    // parameters
) (
    input clk, n_rst,
    input logic load_weights, start_inference, load_weights_en, load_inputs_en, //from AHB sub.
    // input logic activated, //from 
    input logic [63:0] input_reg, 
    input logic [63:0] weight_reg,
    input logic [63:0] bias_vec,
    input logic [1:0] activation_mode,
    output logic controller_busy, data_ready, weights_done, inputs_done, occupancy_err, systolic_done,/* invalid,*/
    output logic [63:0] output_reg

);

logic start_weights, start_array;
// logic [6:0] num_input;
logic [63:0] systolic_data, activations;
logic enable;
logic activated;

fullInference compute (.*);


sram_controller control (.*);

endmodule

