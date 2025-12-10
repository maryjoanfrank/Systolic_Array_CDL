`timescale 1ns / 10ps

module top #(
    // parameters
) (
    input clk, n_rst,
    input logic hsel, hwrite,
    input logic [9:0] haddr,
    input logic [1:0] htrans, 
    input logic [63:0] hwdata,
    input logic [2:0] hburst, hsize,
    output logic hready, hresp,
    output logic [63:0] hrdata
);

logic controller_busy;
logic data_ready;
logic [63:0] output_reg;
logic buffer_error, weight_done, input_done, systolic_done;
logic [63:0]  input_data;
logic [63:0]  weight;
logic weight_write_en;
logic input_write_en;
logic  start_inference, load_weights;
logic [1:0] activation_mode;
logic [63:0] bias;


AHB_CDL bus (.*);

peripheral accelerator (.clk(clk), .n_rst(n_rst),
   .load_weights(load_weights),
   .start_inference(start_inference),
   .load_weights_en(weight_write_en),
   .load_inputs_en(input_write_en),
   .input_reg(input_data),
   .weight_reg(weight),
   .bias_vec(bias),
   .activation_mode(activation_mode),
   .controller_busy(controller_busy),
   .data_ready(data_ready),
   .weights_done(weight_done),
   .inputs_done(input_done),
   .occupancy_err(buffer_error),
   .systolic_done(systolic_done),
   .output_reg(output_reg)
);



endmodule

