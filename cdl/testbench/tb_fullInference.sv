`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_fullInference ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;

    logic start_weights, start_array, enable, activated;
    logic [63:0] systolic_data, bias_vec, activations;
    logic [6:0] num_input;
    logic [1:0] activation_mode;


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

    fullInference #() DUT (.*);

    task  taskName(arguments);
        
    endtask //
    initial begin
        n_rst = 1;
        start_array = 0;
        start_weights = 0;
        activation_mode = 2'd2;
        systolic_data = 0;
        bias_vec = 64'h0;
        num_input = 7'd3;
        enable = 0;
        
        reset_dut;

        @(negedge clk);

        // weight loading
        enable = 1;
        start_weights = 1;
        systolic_data = 64'h0202020202020202;

        @(negedge clk);
        start_weights = 0;
        // systolic_data = 64'h0404040404040404;

        repeat (7) @(negedge clk);


        // @(negedge clk);
        // systolic_data = 64'h0606060606060606;
        
        // @(negedge clk);
        // systolic_data = 64'h0808080808080808;
        
        // @(negedge clk);
        // systolic_data = 64'h0a0a0a0a0a0a0a0a;
        
        // @(negedge clk);
        // systolic_data = 64'h0c0c0c0c0c0c0c0c;
        
        // @(negedge clk);
        // systolic_data = 64'h0e0e0e0e0e0e0e0e;
        
        // @(negedge clk);
        // systolic_data = 64'h0f0f0f0f0f0f0f0f;
        
        // @(negedge clk);
        enable = 0;
        systolic_data = 64'hBAD1DEADBEEFBAD1;
        
        @(negedge clk);
        enable = 1;
        start_array = 1;
        systolic_data = 64'h0102030405060708;

        @(negedge clk);
        start_array = 0;
        systolic_data = 64'h050a050a050a050a;
        
        @(negedge clk);
        systolic_data = 64'h0408040804080408;

        @(negedge clk);
        enable = 0;

        @(negedge clk);
        enable = 1;

        repeat (40) @(negedge clk);


        $finish;
    end
endmodule

/* verilator coverage_on */

