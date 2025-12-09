`timescale 1ns / 10ps

// shift reg that shifts by 8 bits at a time,
// parallel input load overrides shift enable

module byte_SR #(
    SIZE = 2, // number of bytes stored
    MSB_FIRST = 0 //shifting direction
) (
    input clk, n_rst,
    input logic shift_enable, load_enable,
    input logic [7:0] byte_in,
    input logic [(SIZE * 8) - 1 : 0] parallel_in,
    output logic [7:0] byte_out
);

logic [(SIZE * 8) - 1 : 0] q, q_n;

always_ff @( negedge n_rst, posedge clk) begin 
    if (!n_rst) begin
        q <= 0;
    end else begin
        q <= q_n;
    end
end

always_comb begin : reg_update
    if (load_enable) begin : full_reg_in
        q_n = parallel_in;        
    end else if (shift_enable) begin : byte_shift
        if (SIZE == 1) begin
            /*verilator lint_off WIDTHEXPAND*/
            q_n = byte_in;
            /*verilator lint_on WIDTHEXPAND*/
        end else if (MSB_FIRST) begin
            /*verilator lint_off WIDTHTRUNC*/
            /*verilator lint_off SELRANGE*/
            q_n = {q[ ((SIZE - 1) * 8) - 1:0], byte_in};
            /*verilator lint_on SELRANGE*/ 
            /*verilator lint_on WIDTHTRUNC*/
        end else begin
            /*verilator lint_off SELRANGE*/
            /*verilator lint_off WIDTHTRUNC*/
            q_n = {byte_in, q[(SIZE * 8) - 1: 8]};
            /*verilator lint_on SELRANGE*/ 
            /*verilator lint_on WIDTHTRUNC*/
        end
    end else begin
        q_n = q;
    end
end


always_comb begin : output_logic
    if (MSB_FIRST) begin
        byte_out = q[(SIZE * 8) - 1 : ((SIZE - 1) * 8)];
    end else begin
        byte_out = q[7:0];
    end
end

endmodule

