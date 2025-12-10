`timescale 1ns / 10ps

module mux21 #(
    SIZE = 1
) (
    input logic [SIZE-1:0] a, b,
    input logic sel,
    output logic [SIZE-1:0] out
);

assign out = sel ? a : b;

endmodule

