`timescale 1ns / 10ps

module full_adder #()(
    input logic a, b, carry_in,
    output logic carry_out, sum
);

    assign sum =  (~(a||b) && carry_in) || (~(b||carry_in) && a) || (~(carry_in||a) && b) || ((a && b ) && carry_in);
    assign carry_out = (a && b) || (b && carry_in) || (carry_in && a);
endmodule

