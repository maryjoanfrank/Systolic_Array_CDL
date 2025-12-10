`timescale 1ns / 10ps
// 8-bit int processing element

// TODO: no handling or detecting for 8-bit overflow withing multiply and accumulate, clipping occurs after bias adding, an overflow w/in the wallace tree will output an invalid product 
// note: verilator will throw two warnings: 
    // unused operand bytes, this is the right-most column of the array where the operands no longer need to be passed along
    // unused sum_out bytes: wallace tree discards upper bits, this is correct operation
module processingElement (
    input clk, n_rst,
    input logic [7:0] input_byte, partial_in,
    input logic load, PE_enable,
    output logic[7:0] operand_out, partial_out
);

logic [15:0] INT8_MAX;
assign INT8_MAX = 16'd127;
logic [15:0] INT8_MIN;
assign INT8_MIN = -16'd128;

logic [7:0] clipped_partial; //final clipped multiplay and add value

// partial_out reg
    always_ff @( posedge clk, negedge n_rst ) begin
        if (!n_rst) begin
            partial_out <= 0;
        end else if (PE_enable) begin
            partial_out <= clipped_partial;
        end
    end


// weight register && operand_out reg (horizontal output on RTL)
    logic [7:0] weight, weight_n;

    always_comb begin 
        if (load) begin
            weight_n = input_byte;
        end else begin
            weight_n = weight;
        end    
    end

    always_ff @( posedge clk, negedge n_rst ) begin
        if (!n_rst) begin
            weight <= 0;
            operand_out <= 0;
        end else if (PE_enable) begin
            weight <= weight_n;
            operand_out <= input_byte;
        end
    end


// wallace tree multiplier
    // sign-extended weight
    logic [15:0] weight_ext;
    assign weight_ext = {{8{weight[7]}}, weight};

    // sign-extended input
    logic [15:0] input_ext;
    assign input_ext = {{8{input_byte[7]}}, input_byte};

    // intermediate signals
    logic [15:0] [15:0] temp_add;
    logic [7:0] [16:0] temp_sum;
    logic [3:0] [17:0] temp_sum1;
    logic [1:0] [18:0] temp_sum2;

    // multiplier output
    /*verilator lint_off UNUSEDSIGNAL*/
    logic [19:0] tree_out; // extended adder outputs
    /*verilator lint_on UNUSEDSIGNAL*/
    logic [15:0] mult_true; // accurate multiplier output 

    logic [15:0] sum_out; // multiplier output + partial_in
    

    generate
        genvar i;
        for (i = 0; i < 8; i++) begin : multiplier_layer_1
            mux21 #(.SIZE(16)) mux0 (.a(input_ext << (i *2)), .b(0), .sel(weight_ext[i * 2]), .out(temp_add[i * 2]));
            mux21 #(.SIZE(16)) mux1 (.a(input_ext << ((i * 2) + 1)), .b(0), .sel(weight_ext[(i * 2) + 1]), .out(temp_add[(i * 2) + 1]));
            adder_nbit #(.SIZE(16)) adder1 (.a(temp_add[i * 2]), .b(temp_add[(i * 2) + 1]), .carry_in(0), .sum(temp_sum[i] [15:0]), .carry_out(temp_sum[i] [16]));
        end
    endgenerate

    generate
        genvar j;
        for (j = 0;j < 4;j++ ) begin : multiplier_layer_2
            adder_nbit #(.SIZE(17)) adder2 (.a(temp_sum[2 * j]), .b(temp_sum[(2 * j) + 1]), .carry_in(0), .sum(temp_sum1[j] [16:0]), .carry_out(temp_sum1[j] [17]));
        end
    endgenerate

    generate
        genvar k;
        for (k = 0;k < 2;k++ ) begin : multiplier_layer_3
            adder_nbit #(.SIZE(18)) adder3 (.a(temp_sum1[2 * k]), .b(temp_sum1[(2 * k) + 1]), .carry_in(0), .sum(temp_sum2[k] [17:0]), .carry_out(temp_sum2[k] [18]));
        end
    endgenerate

    // multiplier layer 4
    adder_nbit #(.SIZE(19)) adder4 (.a(temp_sum2[0]), .b(temp_sum2[1]), .carry_in(0), .sum(tree_out[18:0]), .carry_out(tree_out[19]));

    // truncate for accurate multiplier result
    assign mult_true = tree_out[15:0];
    
    // add multiplter output with partial sum input
    always_comb begin 
        sum_out = mult_true + {{8{partial_in[7]}},partial_in};
    end

    // clip potential 8-bit overflow
    always_comb begin
        if ($signed(sum_out) > $signed(INT8_MAX)) begin
            clipped_partial = INT8_MAX[7:0];
        end else if ($signed(mult_true) < $signed(INT8_MIN)) begin
            clipped_partial = INT8_MIN[7:0];
        end else begin
            clipped_partial = sum_out[7:0];
        end
    end

          
endmodule
