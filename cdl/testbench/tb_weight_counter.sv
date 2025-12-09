`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_weight_counter ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic trigger_weight, load;
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

    weight_counter #() DUT (.*);

    initial begin
        n_rst = 1;
        trigger_weight = 0;
    
        reset_dut;
        @(negedge clk);
        trigger_weight = 1;
        @(negedge clk);
        trigger_weight = 0;
        repeat (20) @(negedge clk);
        $finish;
    end
endmodule

/* verilator coverage_on */

