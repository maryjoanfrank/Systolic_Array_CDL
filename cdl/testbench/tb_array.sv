`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_array ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic [63:0] array_input, array_output;
    logic load;

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

    // task singleVector;
    //     input logic [63:0] array_input, expected;

    // endtask 

    array #() DUT (.*);

    initial begin
        n_rst = 1;
        load = 0;
        array_input = 0;

        reset_dut;

        @(negedge clk)
        load = 1;
        array_input = 64'h0202020202020202;

        @(negedge clk)
        array_input = 64'h0202020202020202;
        
        @(negedge clk)
        array_input = 64'h0202020202020202;
        
        @(negedge clk)
        array_input = 64'h0202020202020202;

        @(negedge clk)
        array_input = 64'h0202020202020202;

        @(negedge clk)
        array_input = 64'h0202020202020202;

        @(negedge clk)
        array_input = 64'h0202020202020202;
        
        @(negedge clk)
        array_input = 64'h0202020202020202;

        @(negedge clk)
        load = 0;
        array_input = 64'h0500000000000000;

        @(negedge clk)
        array_input = 64'h0005000000000000;

        @(negedge clk)
        load = 0;
        array_input = 64'h0000050000000000;

        @(negedge clk)
        array_input = 64'h0000000500000000;

        @(negedge clk)
        array_input = 64'h0000000005000000;

        @(negedge clk)
        array_input = 64'h0000000000050000;

        @(negedge clk)
        array_input = 64'h0000000000000500;

        @(negedge clk)
        array_input = 64'h0000000000000005;

        repeat (10) @(negedge clk);
        
        $finish;
    end
endmodule

/* verilator coverage_on */

