`timescale 1ns / 10ps

module sram_buffer #(
    // parameters
) (
    input logic clk, n_rst, 
    input logic [7:0] r_trigger, w_trigger, 
    input logic [9:0] addr,
    input logic [63:0] write_data0, write_data1, write_data2, write_data3, write_data4, write_data5, write_data6, write_data7,
    input logic [7:0] chip_select,
    output logic [63:0] read_data0, read_data1, read_data2, read_data3, read_data4, read_data5, read_data6, read_data7
);


        typedef struct packed { //struct???  -> make this a packed array?
            logic [31:0] rdata;
            logic [1:0]  state;   // 0=FREE,1=BUSY,2=ACCESS,3=ERROR
            logic [31:0] wdata;
        } bank_out_t;

        bank_out_t bank_outlo [7:0];
        bank_out_t bank_outhi [7:0];

        logic latched_ren [7:0];
        logic latched_wen [7:0];
        logic [9:0] latched_addr [7:0];
        logic [31:0]  latched_wdatalo [7:0];
        logic [31:0]  latched_wdatahi [7:0];
        logic bank_free[7:0];

        localparam LAT = 4;   // 4-cycle latency
        // logic prev_both_access [3:0];


        logic busy  [7:0];
        logic [2:0] countdown  [7:0];    
        assign bank_outlo[0].wdata = write_data0[31:0];
        assign bank_outhi[0].wdata = write_data0[63:32];
        assign bank_outlo[1].wdata = write_data1[31:0];
        assign bank_outhi[1].wdata = write_data1[63:32];
        assign bank_outlo[2].wdata = write_data2[31:0];
        assign bank_outhi[2].wdata = write_data2[63:32];
        assign bank_outlo[3].wdata = write_data3[31:0];
        assign bank_outhi[3].wdata = write_data3[63:32];
        assign bank_outlo[4].wdata = write_data4[31:0];
        assign bank_outhi[4].wdata = write_data4[63:32];
        assign bank_outlo[5].wdata = write_data5[31:0];
        assign bank_outhi[5].wdata = write_data5[63:32];
        assign bank_outlo[6].wdata = write_data6[31:0];
        assign bank_outhi[6].wdata = write_data6[63:32];
        assign bank_outlo[7].wdata = write_data7[31:0];
        assign bank_outhi[7].wdata = write_data7[63:32];
    genvar b;
        generate
            for (b = 0; b < 8; b++) begin 
            assign bank_free[b] = (!busy[b] && countdown[b] == 0);
            
                always_ff @(posedge clk or negedge n_rst) begin
                    if (!n_rst) begin
                        busy[b]        <= 0;
                        countdown[b]   <= 0;
                        latched_ren[b]   <= 1'b0;
                        latched_wen[b]   <= 1'b0;
                        latched_addr[b]  <= '0;
                        latched_wdatalo[b] <= '0;
                        latched_wdatahi[b] <= '0;

                    end
                    else begin                    
                    if (busy[b]) begin
                        if (countdown[b] == 1) begin
                            busy[b] <= 0;   // release bank 
                            countdown[b] <= 0;     
                            latched_ren[b] <= 1'b0;
                            latched_wen[b] <= 1'b0;
                        end else begin
                            countdown[b] <= countdown[b]-1;
                        end
                    end

                    if (chip_select[b] && bank_free[b]) begin
                        if (r_trigger[b] && !w_trigger[b]) begin
                            latched_ren[b]  <= 1'b1;
                            latched_wen[b]  <= 1'b0;
                            latched_addr[b] <= addr;
                            busy[b]        <= 1;
                            countdown[b]   <= LAT;                            
                        end

                        if (w_trigger[b] && !r_trigger[b]) begin
                            latched_wen[b]  <= 1'b1;
                            latched_ren[b]  <= 1'b0;
                            latched_addr[b] <= addr;
                            latched_wdatalo[b] <= bank_outlo[b].wdata[31:0]; 
                            latched_wdatahi[b] <= bank_outhi[b].wdata[31:0]; 
                            busy[b]        <= 1;
                            countdown[b]   <= LAT;
                        
                        end
                    end

                end
            end
    sram1024x32_wrapper SRAM_LO (
                    .clk          (clk),
                    .n_rst        (n_rst),
                    .address      (latched_addr[b]),
                    .read_enable  (latched_ren[b]),
                    .write_enable (latched_wen[b]),
                    .write_data   (latched_wdatalo[b]),
                    .read_data    (bank_outlo[b].rdata),
                    .sram_state   (bank_outlo[b].state)
                );

    sram1024x32_wrapper SRAM_HI (
        .clk          (clk),
        .n_rst        (n_rst),
        .address      (latched_addr[b]),
        .read_enable  (latched_ren[b]),
        .write_enable (latched_wen[b]),
        .write_data   (latched_wdatahi[b]),
        .read_data    (bank_outhi[b].rdata),
        .sram_state   (bank_outhi[b].state)
    );

        end
    endgenerate

    assign read_data0 = { bank_outhi[0].rdata, bank_outlo[0].rdata };
    assign read_data1 = { bank_outhi[1].rdata, bank_outlo[1].rdata };
    assign read_data2 = { bank_outhi[2].rdata, bank_outlo[2].rdata };
    assign read_data3 = { bank_outhi[3].rdata, bank_outlo[3].rdata };
    assign read_data4 = { bank_outhi[4].rdata, bank_outlo[4].rdata };
    assign read_data5 = { bank_outhi[5].rdata, bank_outlo[5].rdata };
    assign read_data6 = { bank_outhi[6].rdata, bank_outlo[6].rdata };
    assign read_data7 = { bank_outhi[7].rdata, bank_outlo[7].rdata };    
    
    // 0=FREE,1=BUSY,2=ACCESS,3=ERROR

endmodule


