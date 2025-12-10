`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_bias ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic[63:0] array_output, bias_vec, bias_output;
    logic bias_add_en;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    bias #() DUT (.*);

    initial begin
        n_rst = 1;
        bias_add_en = 0;
        bias_vec = 64'h1111111111111111;
        array_output = 64'hDEADBEEFBAD1BAD1;

        reset_dut;

        @(negedge clk)
        bias_add_en = 1;
        repeat (3) @(negedge clk);
        $finish;
    end
endmodule

/* verilator coverage_on */

