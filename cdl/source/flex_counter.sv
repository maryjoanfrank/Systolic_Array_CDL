`timescale 1ns / 10ps

module flex_counter #(
    SIZE = 4) (
    input logic clk, n_rst, clear, count_enable,
    input logic [SIZE - 1: 0] rollover_val,
    output logic [SIZE - 1: 0] count_out,
    output logic rollover_flag
);
    logic [SIZE - 1 : 0] next_count;
    logic next_flag;

    always_ff @( negedge n_rst, posedge clk ) begin : ff
        if (~n_rst) begin
            count_out <= 0;
            rollover_flag <= 0;
        end else begin
            count_out <= next_count;
            rollover_flag <= next_flag;
        end
    end

    always_comb begin : next_state_logic
        if (clear) begin
            next_count = 0;
        end else begin
            if (count_enable) begin
                if (count_out >= rollover_val) begin
                    next_count = 1;
                end else begin
                    next_count = count_out + 1;
                end
            end else begin
                next_count = count_out;
            end
        end
    end

    // assign rollover_flag = (count_out == rollover_val);

    // output logic
    // assign next_flag = (count_out == rollover_val - 1) && (count_enable) && (~clear);
    assign next_flag = (next_count == rollover_val);
endmodule

