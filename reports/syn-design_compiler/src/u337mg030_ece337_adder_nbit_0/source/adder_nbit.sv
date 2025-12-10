`timescale 1ns / 10ps

module adder_nbit #(SIZE = 16) (
    input logic [SIZE - 1:0] a, b,
    input logic carry_in,
    output logic [SIZE - 1:0] sum,
    output logic carry_out
    );

logic [SIZE - 2:0] carry;

generate
    genvar i;
    if (SIZE == 1) begin : condition_for_a_single_bit_adder
        full_adder u0(
                    .a(a), 
                    .b(b), 
                    .carry_in(carry_in), 
                    .carry_out(carry_out),
                    .sum(sum)
                    );
    end else begin : connected_adder
        for (i = 0; i < SIZE; i++) begin : gen_for_loop
            if (i == 0) begin : first_adder
                full_adder u0(
                    .a(a[i]), 
                    .b(b[i]), 
                    .carry_in(carry_in), 
                    .carry_out(carry[i]),
                    .sum(sum[i])
                    );
            end else if (i != SIZE - 1) begin : middle_adders
                full_adder u1(
                    .a(a[i]), 
                    .b(b[i]), 
                    .carry_in(carry[i-1]), 
                    .carry_out(carry[i]),
                    .sum(sum[i])
                    );
            end else begin : last_adder
                full_adder u2(
                    .a(a[i]), 
                    .b(b[i]), 
                    .carry_in(carry[i - 1]), 
                    .carry_out(carry_out),
                    .sum(sum[i])
                    );
            end
        end
    end

endgenerate

endmodule
