`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_AHB_CDL ();

    localparam CLK_PERIOD = 10ns;
    localparam TIMEOUT = 1000;

    localparam BURST_SINGLE = 3'd0;
    localparam BURST_INCR   = 3'd1;
    localparam BURST_WRAP4  = 3'd2;
    localparam BURST_INCR4  = 3'd3;
    localparam BURST_WRAP8  = 3'd4;
    localparam BURST_INCR8  = 3'd5;
    localparam BURST_WRAP16 = 3'd6;
    localparam BURST_INCR16 = 3'd7;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    //inputs
    logic clk, n_rst;
    logic controller_busy;
    logic data_ready;
    logic [63:0] output_reg;
    logic buffer_error, weight_done, input_done;

    //outputs
    logic [63:0]  input_data;
    logic [63:0]  weight;
    logic weight_write_en;
    logic input_write_en;
    logic  start_inference, load_weights;
    logic [2:0] activation_mode;
    logic [63:0] bias;

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

    logic hsel;
    logic [9:0] haddr;
    logic [2:0] hsize;
    logic [2:0] hburst;
    logic [1:0] htrans;
    logic hwrite;
    logic [63:0] hwdata;
    logic [63:0] hrdata;
    logic hresp;
    logic hready;

    // bus model connections
    ahb_model_updated #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8)
    ) BFM ( .clk(clk),
        // AHB-Subordinate Side
        .hsel(hsel),
        .haddr(haddr),
        .hsize(hsize),
        .htrans(htrans),
        .hburst(hburst),
        .hwrite(hwrite),
        .hwdata(hwdata),
        .hrdata(hrdata),
        .hresp(hresp),
        .hready(hready)
    );

    // Supporting Tasks
    task reset_model;
        BFM.reset_model();
    endtask

    // Read from a register without checking the value
    task enqueue_poll ( input logic [9:0] addr, input logic [1:0] size );
    logic [63:0] data [];
        begin
            data = new [1];
            data[0] = {64'hXXXX};
            //              Fields: hsel,  R/W, addr, data, exp err,         size, burst, chk prdata or not
            BFM.enqueue_transaction(1'b1, 1'b0, addr, data,    1'b0, {1'b0, size},  3'b0,            1'b0);
        end
    endtask

    // Read from a register until a requested value is observed
    task poll_until ( input logic [9:0] addr, input logic [1:0] size, input logic [63:0] data);
        int iters;
        begin
            for (iters = 0; iters < TIMEOUT; iters++) begin
                enqueue_poll(addr, size);
                execute_transactions(1);
                if(BFM.get_last_read() == data) break;
            end
            if(iters >= TIMEOUT) begin
                $error("Bus polling timeout hit.");
            end
        end
    endtask

    // Read Transaction, verifying a specific value is read
    task enqueue_read ( input logic [9:0] addr, input logic [1:0] size, input logic [63:0] exp_read );
        logic [63:0] data [];
        begin
            data = new [1];
            data[0] = exp_read;
            BFM.enqueue_transaction(1'b1, 1'b0, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b1);
        end
    endtask

    // Write Transaction
    task enqueue_write ( input logic [9:0] addr, input logic [1:0] size, input logic [63:0] wdata );
        logic [63:0] data [];
        begin
            data = new [1];
            data[0] = wdata;
            BFM.enqueue_transaction(1'b1, 1'b1, addr, data, 1'b0, {2'b0, size}, 3'b0, 1'b0);
        end
    endtask

    // Write Transaction Intended for a different subordinate from yours
    task enqueue_fakewrite ( input logic [9:0] addr, input logic [1:0] size, input logic [63:0] wdata );
        logic [63:0] data [];
        begin
            data = new [1];
            data[0] = wdata;
            BFM.enqueue_transaction(1'b0, 1'b1, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b0);
        end
    endtask

    // Create a burst read of size based on the burst type.
    // If INCR, burst size dependent on dynamic array size
    task enqueue_burst_read ( input logic [9:0] base_addr, input logic [1:0] size, input logic [2:0] burst, input logic [63:0] data [] );
        BFM.enqueue_transaction(1'b1, 1'b0, base_addr, data, 1'b0, {1'b0, size}, burst, 1'b1);
    endtask

    // Create a burst write of size based on the burst type.
    task enqueue_burst_write ( input logic [9:0] base_addr, input logic [1:0] size, input logic [2:0] burst, input logic [63:0] data [] );
        BFM.enqueue_transaction(1'b1, 1'b1, base_addr, data, 1'b0, {1'b0, size}, burst, 1'b1);
    endtask

    // Run n transactions, where a k-beat burst counts as k transactions.
    task execute_transactions (input int num_transactions);
        BFM.run_transactions(num_transactions);
    endtask

    // Finish the current transaction
    task finish_transactions();
        BFM.wait_done();
    endtask

    task automatic test_weight_reg(
        input logic [9:0] addr,
        input logic [1:0] size,
        input logic [63:0] wdata
    );
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);

        // write
        enqueue_write(addr, size, wdata);
        execute_transactions(1);

        // read
        enqueue_read(addr, size, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);
    endtask

    task automatic RAW(
        input logic [9:0] addr,
        input logic [1:0] size,
        input logic [63:0] wdata
    );
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        
        
        enqueue_write(addr, size, wdata);
        enqueue_read(addr, 2'd0, 64'd0);
        execute_transactions(2);
        repeat(5) @(negedge clk);

        enqueue_write(addr, size, wdata);
        enqueue_read(addr, 2'd1, 64'd0);
        execute_transactions(2);
        repeat(5) @(negedge clk);

        enqueue_write(addr, size, wdata);
        enqueue_read(addr, 2'd2, 64'd0);
        execute_transactions(2);
        repeat(5) @(negedge clk);

        enqueue_write(addr, size, wdata);
        enqueue_read(addr, 2'd3, 64'd0);
        execute_transactions(2);
        repeat(5) @(negedge clk);
    endtask

    logic [63:0] data [];


    AHB_CDL DUT (.clk(clk), .n_rst(n_rst), .hsel(hsel), .haddr(haddr), .htrans(htrans), 
                .hsize(hsize), .hwrite(hwrite), .hwdata(hwdata), .hburst(hburst),.hready(hready),
                .hrdata(hrdata), .hresp(hresp), 

                .controller_busy(controller_busy), .data_ready(data_ready), .output_reg(output_reg), //inputs
                .buffer_error(buffer_error), .weight_done(weight_done), .input_done(input_done), //inputs
                .input_data(input_data), .weight(weight), .weight_write_en(weight_write_en),  //outputs
                .input_write_en(input_write_en), .start_inference(start_inference), .load_weights(load_weights), //outputs
                .activation_mode(activation_mode), .bias(bias)); // outputs

    string testcase;
    string reset_done;
    initial begin
         /****** EXAMPLE CODE ******/
        // Always put data LSB-aligned. The model will automagically move bytes to their proper position.
        // enqueue_read(3'h1, 1'b0, 31'h00BB);
        // enqueue_write(3'h2, 1'b1, 31'h00BB);

        testcase = "reset";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();

        reset_done = "Here 1";

        // ----- TEST 1: WRITE REGISTER 0 & INVALID READ-----
        testcase = "Write weight register at addr 4'h0 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 2";

        enqueue_write(10'd0, 2'd3, 64'd1);
        execute_transactions(1);

        // Read back
        enqueue_read(10'd0, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h0 @ hsize = 2";
        test_weight_reg(10'd0, 2'd2, 64'd2147483648);

        testcase = "Write weight register at addr 4'h0 @ hsize = 1";
        test_weight_reg(10'd0, 2'd1, 64'd32768);

        testcase = "Write weight register at addr 4'h0 @ hsize = 0";
        test_weight_reg(10'd0, 2'd0, 64'd128);

        // ----- TEST 2: WRITE REGISTER 1 & INVALID READ -----
        testcase = "Write weight register at addr 4'h001 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 3";

        enqueue_write(10'h001, 2'd3, 64'd32768); 
        execute_transactions(1);


        // Read back
        enqueue_read(10'h001, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h001 @ hsize = 2";
        test_weight_reg(10'h001, 2'd2, 64'd549755813890); // ensures written in middle 32 bits

        testcase = "Write weight register at addr 4'h001 @ hsize = 1";
        test_weight_reg(10'h001, 2'd1, 64'd8388608); // middle 16 bits write  

        testcase = "Write weight register at addr 4'h001 @ hsize = 0";
        test_weight_reg(10'h001, 2'd0, 64'd32768); // lowest 8 bit write

        // ----- TEST 3: WRITE REGISTER 2 & INVALID READ -----
        testcase = "Write weight register at addr 4'h002 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 4";

        enqueue_write(10'h002, 2'd3, 64'd32768); 
        execute_transactions(1);

        // Read back
        enqueue_read(10'h002, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h002 @ hsize = 2";
        test_weight_reg(10'h002, 2'd2, 64'd140737488360000); // ensures written in middle 32 bits

        testcase = "Write weight register at addr 4'h002 @ hsize = 1";
        test_weight_reg(10'h002, 2'd1, 64'd2147483648); // middle 16 bits write  

        testcase = "Write weight register at addr 4'h002 @ hsize = 0";
        test_weight_reg(10'h002, 2'd0, 64'd8388608); // middle 8 bit write

        // ----- TEST 4: WRITE REGISTER 3 & INVALID READ -----
        testcase = "Write weight register at addr 4'h003 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 5";

        enqueue_write(10'h003, 2'd3, 64'd32768); 
        execute_transactions(1);

        // Read back
        enqueue_read(10'h003, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h003 @ hsize = 2";
        test_weight_reg(10'h003, 2'd2, 64'd36028797019000000); // ensures written in middle 32 bits

        testcase = "Write weight register at addr 4'h003 @ hsize = 1";
        test_weight_reg(10'h003, 2'd1, 64'd549755813890); // middle 16 bits write  

        testcase = "Write weight register at addr 4'h003 @ hsize = 0";
        test_weight_reg(10'h003, 2'd0, 64'd2147483648); // middle 8 bit write


        // ----- TEST 5: WRITE REGISTER 4 & INVALID READ -----
        testcase = "Write weight register at addr 4'h004 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 6";

        enqueue_write(10'h004, 2'd3, 64'd9223372036900000000); // highest 64 bit
        execute_transactions(1);

        // Read back
        enqueue_read(10'h004, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h004 @ hsize = 2";
        test_weight_reg(10'h004, 2'd2, 64'd9223372036900000000); // ensures written in middle 32 bits

        testcase = "Write weight register at addr 4'h004 @ hsize = 1";
        test_weight_reg(10'h004, 2'd1, 64'd140737488360000); // middle 16 bits write  

        testcase = "Write weight register at addr 4'h004 @ hsize = 0";
        test_weight_reg(10'h004, 2'd0, 64'd549755813890); // middle 8 bit write


        // ----- TEST 6: WRITE REGISTER 5 & INVALID READ -----
        testcase = "Write weight register at addr 4'h005 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 7";

        enqueue_write(10'h005, 2'd3, 64'd9223372036900000000); // highest 64 bit
        execute_transactions(1);

        // Read back
        enqueue_read(10'h005, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h005 @ hsize = 2";
        test_weight_reg(10'h005, 2'd2, 64'd9223372036900000000); // ensures written in middle 32 bits

        testcase = "Write weight register at addr 4'h005 @ hsize = 1";
        test_weight_reg(10'h005, 2'd1, 64'd36028797019000000); // middle 16 bits write  

        testcase = "Write weight register at addr 4'h005 @ hsize = 0";
        test_weight_reg(10'h005, 2'd0, 64'd140737488360000); // middle 8 bit write

        // ----- TEST 7: WRITE REGISTER 6 & INVALID READ -----
        testcase = "Write weight register at addr 4'h006 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 8";

        enqueue_write(10'h006, 2'd3, 64'd9223372036900000000); // highest 64 bit
        execute_transactions(1);

        // Read back
        enqueue_read(10'h006, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h006 @ hsize = 2";
        test_weight_reg(10'h006, 2'd2, 64'd9223372036900000000); // ensures written in middle 32 bits

        testcase = "Write weight register at addr 4'h006 @ hsize = 1";
        test_weight_reg(10'h006, 2'd1, 64'd9223372036900000000); // middle 16 bits write  

        testcase = "Write weight register at addr 4'h006 @ hsize = 0";
        test_weight_reg(10'h006, 2'd0, 64'd36028797019000000); // middle 8 bit write

        // ----- TEST 8: WRITE REGISTER 7 & INVALID READ -----
        testcase = "Write weight register at addr 4'h007 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 9";

        enqueue_write(10'h007, 2'd3, 64'd9223372036900000000); // highest 64 bit
        execute_transactions(1);

        // Read back
        enqueue_read(10'h007, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write weight register at addr 4'h007 @ hsize = 2";
        test_weight_reg(10'h007, 2'd2, 64'd9223372036900000000); // ensures written in middle 32 bits

        testcase = "Write weight register at addr 4'h007 @ hsize = 1";
        test_weight_reg(10'h007, 2'd1, 64'd9223372036900000000); // middle 16 bits write  

        testcase = "Write weight register at addr 4'h007 @ hsize = 0";
        test_weight_reg(10'h007, 2'd0, 64'd9223372036900000000); // middle 8 bit write

        // ----- TEST 9: WRITE REGISTER 8 & INVALID READ-----
        testcase = "Write Input register at addr 4'h008 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 10";

        enqueue_write(10'h008, 2'd3, 64'd9223372036900000000);
        execute_transactions(1);

        // Read back
        enqueue_read(10'h008, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write Input register at addr 4'h008 @ hsize = 2";
        test_weight_reg(10'h008, 2'd2, 64'd1073741824); // ensures written in middle 32 bits

        testcase = "Write Input register at addr 4'h008 @ hsize = 1";
        test_weight_reg(10'h008, 2'd1, 64'd2147483648); // middle 16 bits write  

        testcase = "Write Input register at addr 4'h008 @ hsize = 0";
        test_weight_reg(10'h008, 2'd0, 64'd32768); // lowest 8 bit write

        // ----- TEST 10: WRITE REGISTER 9 & INVALID READ-----
        testcase = "Write Input register at addr 4'h009 @ hsize = 3";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 11";

        enqueue_write(10'h009, 2'd3, 64'd9223372036900000000); 
        execute_transactions(1);

        // Read back
        enqueue_read(10'h009, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        testcase = "Write Input register at addr 4'h009 @ hsize = 2";
        test_weight_reg(10'h009, 2'd2, 64'd1073741824); // ensures written in middle 32 bits

        testcase = "Write Input register at addr 4'h009 @ hsize = 1";
        test_weight_reg(10'h009, 2'd1, 64'd8388608); // middle 16 bits write  

        testcase = "Write Input register at addr 4'h009 @ hsize = 0";
        test_weight_reg(10'h009, 2'd0, 64'd32768); // lowest 8 bit write
        
        // ----- TEST 11: WRITE/READ REGISTER 10 -----
        testcase = "Write bias register at addr 4'h010 @ hsize_reg = 3,2,1";
        RAW(10'h010, 2'd3, 64'd9223372036900000000);

        RAW(10'h010, 2'd2, 64'd2147483648);

        RAW(10'h010, 2'd1, 64'd32768);

        RAW(10'h010, 2'd0, 64'd128);


        // ----- TEST 12: WRITE/READ REGISTER 11 -----
        testcase = "Write bias register at addr 4'h011 @ hsize_reg = 3,2,1";
        RAW(10'h011, 2'd3, 64'd9223372036900000000);

        RAW(10'h011, 2'd2, 64'd549755813890);

        RAW(10'h011, 2'd1, 64'd8388608);

        RAW(10'h011, 2'd0, 64'd32768);

        // ----- TEST 12: WRITE/READ REGISTER 12 -----
        testcase = "Write bias register at addr 4'h012 @ hsize_reg = 3,2,1";
        RAW(10'h012, 2'd3, 64'd9223372036900000000);

        RAW(10'h012, 2'd2, 64'd140737488360000);

        RAW(10'h012, 2'd1, 64'd2147483648);

        RAW(10'h012, 2'd1, 64'd8388608);

        // ----- TEST 13: WRITE/READ REGISTER 13 -----
        testcase = "Write bias register at addr 4'h013 @ hsize_reg = 3,2,1";
        RAW(10'h013, 2'd3, 64'd9223372036900000000);

        RAW(10'h013, 2'd2, 64'd36028797019000000);

        RAW(10'h013, 2'd1, 64'd549755813890);

        RAW(10'h013, 2'd1, 64'd2147483648);

        // ----- TEST 13: WRITE/READ REGISTER 14 -----
        testcase = "Write bias register at addr 4'h014 @ hsize_reg = 3,2,1";
        RAW(10'h014, 2'd3, 64'd9223372036900000000);

        RAW(10'h014, 2'd2, 64'd9223372036900000000);

        RAW(10'h014, 2'd1, 64'd140737488360000);

        RAW(10'h014, 2'd1, 64'd549755813890);

        // ----- TEST 14: WRITE/READ REGISTER 15 -----
        testcase = "Write bias register at addr 4'h015 @ hsize_reg = 3,2,1";
        RAW(10'h015, 2'd3, 64'd9223372036900000000);

        RAW(10'h015, 2'd2, 64'd9223372036900000000);

        RAW(10'h015, 2'd1, 64'd36028797019000000);

        RAW(10'h015, 2'd1, 64'd140737488360000);

        // ----- TEST 15: WRITE/READ REGISTER 16 -----
        testcase = "Write bias register at addr 4'h016 @ hsize_reg = 3,2,1";
        RAW(10'h016, 2'd3, 64'd9223372036900000000);

        RAW(10'h016, 2'd2, 64'd9223372036900000000);

        RAW(10'h016, 2'd1, 64'd9223372036900000000);

        RAW(10'h016, 2'd1, 64'd36028797019000000);

        // ----- TEST 16: WRITE/READ REGISTER 17 -----
        testcase = "Write bias register at addr 4'h017 @ hsize_reg = 3,2,1";
        RAW(10'h017, 2'd3, 64'd9223372036900000000);

        RAW(10'h017, 2'd2, 64'd9223372036900000000);

        RAW(10'h017, 2'd1, 64'd9223372036900000000);

        RAW(10'h017, 2'd1, 64'd36028797019000000);

        // Example Burst Setup - Dynamic Array Required
        testcase = "BURST Write weight register at addr 4'h000";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 12";

        data = new [8];
        // data = {64'h8888_8888_8888, 64'h7777_7777_7777,64'h6666_6666_6666,64'h5555_5555_5555,64'h4444_4444_4444,64'h3333_3333_3333,64'h2222_2222_2222,64'h1111_1111_1111};
        data = {64'h8888_8888_8888, 64'h7777_7777_7777,64'h6666_6666_6666,64'h5555_5555_5555};
        enqueue_burst_write(10'h000, 2'd3, 3'd2, data); // 32 bits 
        execute_transactions(4); // Burst counts as 8 transactions for 8 beats
        finish_transactions();

        // Read Output register
        testcase = "Read Output register h018";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 13";

        output_reg = 64'd8792;

        enqueue_read(10'h018, 2'd3, 64'd0);
        enqueue_read(10'h018, 2'd2, 64'd0);
        enqueue_read(10'h018, 2'd1, 64'd0);
        enqueue_read(10'h018, 2'd0, 64'd0);
        execute_transactions(4);
        repeat(5) @(negedge clk);

        // enqueue_read(10'h018, 2'd3, 64'd0);
        // execute_transactions(1);
        // enqueue_read(10'h018, 2'd2, 64'd0);
        // execute_transactions(1);
        // enqueue_read(10'h018, 2'd1, 64'd0);
        // execute_transactions(1);
        // enqueue_read(10'h018, 2'd0, 64'd0);
        // execute_transactions(1);
        // repeat(5) @(negedge clk);

        // Read Output register
        testcase = "Read Output register h019";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 14";

        output_reg = 64'd5000500;
        // enqueue_read(10'h019, 2'd3, 64'd0);
        // execute_transactions(1);
        // enqueue_read(10'h019, 2'd2, 64'd0);
        // execute_transactions(1);
        // enqueue_read(10'h019, 2'd1, 64'd0);
        // execute_transactions(1);
        // enqueue_read(10'h019, 2'd0, 64'd0);
        // execute_transactions(1);
        // repeat(5) @(negedge clk);
        enqueue_read(10'h019, 2'd3, 64'd0);
        enqueue_read(10'h019, 2'd2, 64'd0);
        enqueue_read(10'h019, 2'd1, 64'd0);
        enqueue_read(10'h019, 2'd0, 64'd0);
        execute_transactions(4);
        repeat(5) @(negedge clk);

        // Read Error register
        testcase = "Read Error register h020 & h021";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 14";

        buffer_error = 1'b1;

        enqueue_read(10'h020, 2'd2, 64'd0);
        execute_transactions(1);
        enqueue_read(10'h021, 2'd1, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read Error register
        testcase = "Check error clearing";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 14";

        enqueue_write(10'h001, 2'd3, 64'd70);
        execute_transactions(1);
        enqueue_read(10'h001, 2'd3, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read/write control register
        testcase = "Read/write control register h0222";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 15";

        enqueue_write(10'h022, 2'd0, 64'd254);
        execute_transactions(1);
        enqueue_read(10'h022, 2'd0, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read/write control register
        testcase = "Read/write control register h0222";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 15";

        enqueue_write(10'h022, 2'd1, 64'd254);
        execute_transactions(1);
        enqueue_read(10'h022, 2'd1, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read/write control register
        testcase = "Read/write control register h0222";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 15";

        enqueue_write(10'h022, 2'd2, 64'd254);
        execute_transactions(1);
        enqueue_read(10'h022, 2'd2, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read/write control register
        testcase = "Read/write control register h0222";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 15";

        enqueue_write(10'h022, 2'd3, 64'd254);
        execute_transactions(1);
        enqueue_read(10'h022, 2'd3, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read/write control register
        testcase = "Read status register h023";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 16";

        controller_busy = 1'b1;
        data_ready = 1'b1;

        // enqueue_read(10'h023, 2'd3, 64'd3);
        enqueue_read(10'h023, 2'd3, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read/write Activation register
        testcase = "Read/write Activation register h024";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 17";


        enqueue_write(10'h024, 2'd0, 64'd255);
        execute_transactions(1);
        enqueue_read(10'h024, 2'd0, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

         // Read/write Activation register
        testcase = "Read/write Activation register h024";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 17";


        enqueue_write(10'h024, 2'd1, 64'd255);
        execute_transactions(1);
        enqueue_read(10'h024, 2'd1, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

         // Read/write Activation register
        testcase = "Read/write Activation register h024";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 17";


        enqueue_write(10'h024, 2'd2, 64'd255);
        execute_transactions(1);
        enqueue_read(10'h024, 2'd2, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        // Read/write Activation register
        testcase = "Read/write Activation register h024";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 17";


        enqueue_write(10'h024, 2'd3, 64'd255);
        execute_transactions(1);
        enqueue_read(10'h024, 2'd3, 64'd0);
        execute_transactions(1);
        repeat(5) @(negedge clk);

        testcase = "stalling";
        n_rst = 1;
        controller_busy = 1'b0;
        data_ready = 1'b0;
        output_reg = 64'd0;
        buffer_error = 1'b0;
        weight_done = 1'b0;
        input_done = 1'b0;
        reset_model();
        reset_dut();
        @(negedge clk);
        reset_done = "Here 18";

        weight_done = 1'b1;

        enqueue_write(10'h024, 2'd3, 64'd3);
        execute_transactions(1);
        enqueue_read(10'h024, 2'd3, 64'd0);
        execute_transactions(1);


        weight_done = 1'b0;
        enqueue_write(10'h024, 2'd3, 64'd3);
        execute_transactions(1);
        enqueue_read(10'h024, 2'd3, 64'd0);
        execute_transactions(1);

        repeat(5) @(negedge clk);

        $finish;
    end
endmodule

/* verilator coverage_on */

