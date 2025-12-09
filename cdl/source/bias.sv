`timescale 1ns / 10ps

// 8x8-bit vector bias adder
module bias (
    input clk, n_rst,
    input logic enable,
    input logic [63:0] array_output, bias_vec,
    output logic [63:0] bias_output
);

// logic [63:0] bias_output_n, temp;
logic [7:0] [8:0] temp;
logic [7:0] [7:0] bias_output_n;


logic [8:0] INT8_MAX;
assign INT8_MAX = 9'd127;
logic [8:0] INT8_MIN;
assign INT8_MIN = -9'd128;

always_ff @( negedge n_rst, posedge clk ) begin
    if (!n_rst) begin
        bias_output <= 0;
    end else if (enable) begin
        bias_output <= bias_output_n;
    end
end

generate
    genvar i;
    for (i = 0; i < 8; i++) begin : adders
        adder_nbit #(.SIZE(8)) biasAdd (.a(array_output[(8*i + 7) : 8*i]), .b(bias_vec[(8*i + 7) : 8*i]), .carry_in(0), .carry_out(), .sum(temp[i][7:0])) ;
        // assign temp[i] = $signed(array_output[(8*i + 7) : 8*i]) + $signed(bias_vec[(8*i + 7) : 8*i]);
        assign temp[i][8] = temp[i][7];

        always_comb begin : clipping
            if ($signed(temp[i]) > $signed(INT8_MAX)) begin : check_overflow
                bias_output_n[i] = INT8_MAX[7:0];
            end else if($signed(temp[i]) < $signed(INT8_MIN)) begin : check_underflow
                bias_output_n[i]  = INT8_MIN[7:0];
            end else begin : no_error
                bias_output_n[i] = temp[i][7:0];
            end
        end
    end    
endgenerate


endmodule

