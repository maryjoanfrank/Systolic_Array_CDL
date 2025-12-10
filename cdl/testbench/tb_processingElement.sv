`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_processingElement ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end
    
    // signals

    logic clk, n_rst;
    logic load;
    logic [7:0] input_byte, operand_out, partial_in, partial_out;

    
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

    // task  (arguments);
        
    // endtask //

    processingElement #() DUT (.*);

    initial begin
        n_rst = 1;
        input_byte = 0;
        partial_in = 0;
        load = 0;

        reset_dut;

        @(negedge clk);
        input_byte = 8'h02;
        load = 1;
        @(negedge clk);
        
        if (partial_out == 8'b0) begin
            $display("first partial_out correct");
        end else begin
            $display("ERROR: first partial_out nonzero");
        end

        if (operand_out == 8'b0) begin
            $display("first operand_out correct");
        end else begin
            $display("ERROR: first operand_out nonzero");
        end

        load = 0;
        input_byte = 8'h05;
        partial_in = 8'h06;
        @(posedge clk);
        @(negedge clk);

        if (partial_out == 8'h10) begin
            $display("second partial_out correct");
        end else begin
            $display("ERROR: second partial_out incorrect result");
        end

        if (operand_out == 8'd5) begin
            $display("second operand_out correct");
        end else begin
            $display("ERROR: second operand_out incorrect result");
        end

        load = 1;
        partial_in = 0;
        input_byte = 8'hff;

        @(negedge clk);
        load = 0;
        input_byte = 8'd7;
        partial_in = 8'd6;

        @(negedge clk);
        if (partial_out == 8'hff) begin
            $display("third partial_out correct");
        end else begin
            $display("ERROR: third partial_out incorrect result");
        end

        if (operand_out == 8'd7) begin
            $display("third operand_out correct");
        end else begin
            $display("ERROR: third operand_out incorrect result");
        end

        load = 1;
        partial_in = 0;
        input_byte = -8'd5;

        @(negedge clk);
        load = 0;
        input_byte = 8'd6;
        partial_in = -8'd7;

        @(negedge clk);

        if (partial_out == 8'h80) begin
            $display(" overflow partial_out correct");
        end else begin
            $display("ERROR: overflow partial_out incorrect result");
        end

        if (operand_out == 8'd25) begin
            $display("overflow operand_out correct");
        end else begin
            $display("ERROR: overflow operand_out incorrect result");
        end

        load = 1;
        input_byte = 8'd4;
        partial_in = 0;

        @(negedge clk);

        load = 0;
        input_byte = -8'd4;
        partial_in = 8'd14;

        @(negedge clk);
        input_byte = -8'd10;
        partial_in = 8'd14;

        @(negedge clk);
        input_byte = -8'd15;
        partial_in = 8'd2;

        @(negedge clk);
        input_byte = 8'd50;
        partial_in = -8'd10;
        
        @(negedge clk);
        load = 0;
        input_byte = -8'd42;
        partial_in = 8'd17;
        @(negedge clk);
        input_byte = 8'd41;
        partial_in = 8'd25;
        @(negedge clk);
        input_byte = -8'd80;
        partial_in = -8'd45;

        @(negedge clk);
        load = 1;
        input_byte = -8'd128;
        partial_in = 0;

        @(negedge clk);
        load = 0;
        input_byte = -8'd128;
        partial_in = 8'd100;

        @(negedge clk);
        input_byte = 8'd127;
        partial_in = 8'd3;

        repeat (3) @(negedge clk);

        $finish;
    end
endmodule

/* verilator coverage_on */

