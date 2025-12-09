`timescale 1ns / 10ps
// 8x8 8-bit int systolic array 
module array (
    input clk, n_rst,
    input logic [63:0] array_input,
    input logic load, enable,
    output logic [63:0] array_output
);

logic [63:0] [7:0] partials;

/*verilator lint_off UNUSEDSIGNAL*/
logic [63:0] [7:0] operand;
/*verilator lint_on UNUSEDSIGNAL*/

generate
    genvar x, y;
    for (y = 0;y < 8 ;y++ ) begin : vertical_loop
        for (x = 0;x < 8 ;x++ ) begin : horizontal_loop
            if (y == 0 && x == 0) begin : PE_00
                processingElement pe00 (.clk(clk), .n_rst(n_rst), 
                .input_byte(array_input[63:56]), 
                .partial_in(8'b0), 
                .load(load),
                .PE_enable(enable), 
                .operand_out(operand[0]), 
                .partial_out(partials[0]));

            end else if (y == 0 && x!= 0) begin : upper_row
                processingElement pex0 (.clk(clk), .n_rst(n_rst), 
                .input_byte(operand[x - 1]), 
                .partial_in(8'b0), 
                .load(load),
                .PE_enable(enable), 
                .operand_out(operand[x]), 
                .partial_out(partials[x]));

            end else if (y != 0 && x == 0) begin : left_column
                processingElement pe0y (.clk(clk), .n_rst(n_rst), 
                .input_byte(array_input[63 - ((y * 8)) : 56 - (y * 8)]), 
                .partial_in(partials[(y - 1) * 8]), 
                .load(load),
                .PE_enable(enable), 
                .operand_out(operand[y * 8]), 
                .partial_out(partials[y * 8]));

            end else begin : PE_XY
                processingElement pex0 (.clk(clk), .n_rst(n_rst), 
                .input_byte(operand[((y) * 8) + (x - 1)]), 
                .partial_in(partials[((y - 1) * 8) + x]), 
                .load(load),
                .PE_enable(enable), 
                .operand_out(operand[(y * 8) + x]), 
                .partial_out(partials[(y * 8) + x]));

            end
        end
    end
endgenerate

assign array_output = {partials[56], partials[57], partials[58], partials[59], partials[60], partials[61], partials[62], partials[63] };

endmodule

