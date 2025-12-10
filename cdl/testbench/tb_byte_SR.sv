`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_byte_SR ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic shift_enable, load_enable;
    logic [7:0] byte_in, byte_out;
    logic [55:0] parallel_in;

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

    byte_SR #(.SIZE(7), .MSB_FIRST(0)) DUT (.*);

    initial begin
        n_rst = 1;
        load_enable = 0;
        shift_enable = 0;
        byte_in = 0;
        parallel_in = 0;

        reset_dut;

        @(negedge clk);
        shift_enable = 1;
        byte_in = 8'hAA;

        @(negedge clk);
        byte_in = 8'b0;

        repeat (6) @(negedge clk);

        if (byte_out == 8'hAA) begin
            $display("single byte shifitng correct");
        end else begin
            $display("SINGLE BYTE SHIFTING ERROR");
        end

        byte_in = 8'h11;

        @(negedge clk);

        byte_in = 8'h22;

        @(negedge clk);

        byte_in = 8'h33;

        @(negedge clk);
        byte_in = 8'h44;

        @(negedge clk);
        byte_in = 8'h55;

        @(negedge clk);
        byte_in = 8'h66;

        @(negedge clk);
        byte_in = 8'h77;

        @(negedge clk);
        byte_in = 8'h88;

        @(negedge clk);
        byte_in = 8'h99;

        repeat (10) @(negedge clk);
        

        $finish;
    end
endmodule

/* verilator coverage_on */

