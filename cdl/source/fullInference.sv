`timescale 1ns / 10ps

module fullInference #(
    // parameters
) (
    input clk, n_rst,
    input logic start_weights, /*start_array,*/ enable,
    input logic [63:0] systolic_data, bias_vec,
    /*input logic [6:0] num_inputs,*/
    input logic [1:0] activation_mode,
    output logic [63:0] activations/*,
    output logic activation_ready*/
);

// logic /*trigger_weight,*/ trigger_array;

// logic a, b/*, x, y*/;

// always_ff @( negedge n_rst, posedge clk ) begin : weight_array_delay
//     if (~n_rst) begin
//         trigger_array <= 0;
//         a <= 0;
//         b <= 0;
//         /*trigger_weight <= 0;
//         x <= 0;
//         y <= 0;*/
//     end else begin
//         trigger_array <= b;
//         b <= a;
//         a <= start_array;
//         /*trigger_weight <= y;
//         y <= x;
//         x <= start_weights;*/
//     end
// end


// systolic array
    logic load;
    logic [63:0] array_input;
    logic [63:0] array_output;

    array systolicArray (.clk(clk), .n_rst(n_rst), .array_input(array_input), .load(load || start_weights), .enable(enable), .array_output(array_output));

weight_counter load_timing (.clk(clk), .n_rst(n_rst), .trigger_weight(start_weights), .load(load));

// triangular FIFOs
    logic [6:0] [7:0] temp_in;
    // input staggering
    assign array_input[63:56] = systolic_data[63:56];
    byte_SR #(.SIZE(1)) row1 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(systolic_data[55:48]), .parallel_in(0), .byte_out(temp_in[0]));
    mux21 #(.SIZE(8)) muxR1 (.a(systolic_data[55:48]), .b(temp_in[0]), .sel(load||start_weights), .out(array_input[55:48]));

    byte_SR #(.SIZE(2)) row2 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(systolic_data[47:40]), .parallel_in(0), .byte_out(temp_in[1]));
    mux21 #(.SIZE(8)) muxR2 (.a(systolic_data[47:40]), .b(temp_in[1]), .sel(load||start_weights), .out(array_input[47:40]));

    byte_SR #(.SIZE(3)) row3 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(systolic_data[39:32]), .parallel_in(0), .byte_out(temp_in[2]));
    mux21 #(.SIZE(8)) muxR3 (.a(systolic_data[39:32]), .b(temp_in[2]), .sel(load||start_weights), .out(array_input[39:32]));

    byte_SR #(.SIZE(4)) row4 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(systolic_data[31:24]), .parallel_in(0), .byte_out(temp_in[3]));
    mux21 #(.SIZE(8)) muxR4 (.a(systolic_data[31:24]), .b(temp_in[3]), .sel(load||start_weights), .out(array_input[31:24]));

    byte_SR #(.SIZE(5)) row5 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(systolic_data[23:16]), .parallel_in(0), .byte_out(temp_in[4]));
    mux21 #(.SIZE(8)) muxR5 (.a(systolic_data[23:16]), .b(temp_in[4]), .sel(load||start_weights), .out(array_input[23:16]));

    byte_SR #(.SIZE(6)) row6 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(systolic_data[15:8]), .parallel_in(0), .byte_out(temp_in[5]));
    mux21 #(.SIZE(8)) muxR6 (.a(systolic_data[15:8]), .b(temp_in[5]), .sel(load||start_weights), .out(array_input[15:8]));

    byte_SR #(.SIZE(7)) row7 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(systolic_data[7:0]), .parallel_in(0), .byte_out(temp_in[6]));
    mux21 #(.SIZE(8)) muxR7 (.a(systolic_data[7:0]), .b(temp_in[6]), .sel(load||start_weights), .out(array_input[7:0]));

    
    // output staggering
    logic [63:0] output_vector;

    byte_SR #(.SIZE(7)) col0 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(array_output[63:56]), .parallel_in(0), .byte_out(output_vector[63:56]));
    byte_SR #(.SIZE(6)) col1 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(array_output[55:48]), .parallel_in(0), .byte_out(output_vector[55:48]));
    byte_SR #(.SIZE(5)) col2 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(array_output[47:40]), .parallel_in(0), .byte_out(output_vector[47:40]));
    byte_SR #(.SIZE(4)) col3 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(array_output[39:32]), .parallel_in(0), .byte_out(output_vector[39:32]));
    byte_SR #(.SIZE(3)) col4 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(array_output[31:24]), .parallel_in(0), .byte_out(output_vector[31:24]));
    byte_SR #(.SIZE(2)) col5 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(array_output[23:16]), .parallel_in(0), .byte_out(output_vector[23:16]));
    byte_SR #(.SIZE(1)) col6 (.clk(clk), .n_rst(n_rst), .shift_enable((~(load || start_weights) && enable)), .load_enable(0), .byte_in(array_output[15:8]), .parallel_in(0), .byte_out(output_vector[15:8]));
    assign output_vector[7:0] = array_output[7:0];


// bias adder
    logic [63:0] bias_output;
    bias bias_adder (.clk(clk), .n_rst(n_rst), .array_output(output_vector), .bias_vec(bias_vec), .bias_output(bias_output), .enable((~(load || start_weights) && enable)));

// activation function
    activations neuron_activation (.clk(clk), .n_rst(n_rst), .func(activation_mode), .bias_output(bias_output), .enable((~(load || start_weights) && enable)), .activation_out(activations));

endmodule

