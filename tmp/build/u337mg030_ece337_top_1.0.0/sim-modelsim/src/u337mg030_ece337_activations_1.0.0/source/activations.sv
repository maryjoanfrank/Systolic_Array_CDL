`timescale 1ns / 10ps

// Neuron Activation Functions
// 0 -> ReLU
// 1 -> Binary Activation
// 2 -> Identity Activation
// 3 -> Leaky ReLU
module activations (
    input clk, n_rst,
    input logic enable,
    input logic [1:0] func,
    input logic [63:0] bias_output,
    output logic [63:0] activation_out
);

logic [63:0] activations_n;

always_ff @( negedge n_rst, posedge clk ) begin 
    if (!n_rst) begin
        activation_out <= 0;
    end else if(enable) begin
        activation_out <= activations_n;
    end
end

generate
    genvar i;
    for (i = 0; i < 8; i++) begin
        always_comb begin : blockName
            case (func)
                0:begin
                    if (bias_output[(8 * i) + 7]) begin
                        activations_n[(8*i + 7) : 8*i] = 8'b0;
                    end else begin
                        activations_n[(8*i + 7) : 8*i] = bias_output[(8*i + 7) : 8*i];
                    end
                end

                1: begin
                    if (bias_output[(8 * i) + 7]) begin
                        activations_n[(8*i + 7) : 8*i] = 8'b0;
                    end else begin
                        activations_n[(8*i + 7) : 8*i] = 8'd1;
                    end
                end

                2: begin
                    activations_n[(8*i + 7) : 8*i] = bias_output[(8*i + 7) : 8*i];
                end

                3: begin
                    if (bias_output[(8 * i) + 7]) begin
                        activations_n[(8*i + 7) : 8*i] = bias_output[(8*i + 7) : 8*i] >>> 1;
                    end else begin
                        activations_n[(8*i + 7) : 8*i] = bias_output[(8*i + 7) : 8*i];
                    end
                end 
            endcase
        end
    end
endgenerate

endmodule

