`timescale 1ns / 10ps

module sram_buffer #(
    // parameters
) (
    input logic clk, n_rst, 
    input logic ren, wen, 
    input logic [9:0] addr,
    // input logic [63:0] write_data,
    input logic [63:0] write_data0, write_data1, write_data2, write_data3,
    input logic [3:0] chip_select,

    // output logic [3:0] write_done,
    // output logic [3:0] read_valid,
    output logic [63:0] read_data0, read_data1, read_data2, read_data3
);


// //TODO: 8 srams -> for each 4 (low and high)
// //each 64 =2*32 

// //need to make these packed arrays for synthesizable logic 
// logic [31:0] rdata_lo [3:0];
// logic [31:0] rdata_hi [3:0];
// logic [1:0]  state_lo [3:0];
// logic [1:0]  state_hi [3:0];
// logic [31:0] write_lo [3:0];
// logic [31:0] write_hi [3:0];


// genvar b;
//     generate
//         for (b = 0; b < 4; b++) begin
//             //each bank has 2 instances -> low and high (selected together)
//             //chooses btw the 4 

//         logic bank_sel;
//         logic lo_busy;
//         logic lo_err;
//         logic hi_busy;
//         logic hi_err;
//         logic bank_busy;
//         logic bank_err;
//         logic do_read;
//         logic do_write;
//         // logic [31:0] wr_lo;
//         // logic [31:0] wr_hi;

//         assign bank_sel = chip_select[b];

//         assign lo_busy  = (state_lo[b] == 2'd1);
//         assign lo_err   = (state_lo[b] == 2'd3);
//         assign hi_busy  = (state_hi[b] == 2'd1);
//         assign hi_err   = (state_hi[b] == 2'd3);

//         assign bank_busy = lo_busy | hi_busy;
//         assign bank_err  = lo_err  | hi_err;

//         // assign do_read  = bank_sel & ren & ~wen & ~bank_busy & ~bank_err;
//         // assign do_write = bank_sel & wen & ~ren & ~bank_busy & ~bank_err;   //write enable gets deseerted when bank busy
 
//         /* todo: 
//         assign ac = old_address != address;
//         assign dc = old_write_data != write_data; 
//         -> write data shouldn't change 
//         W0: begin
//                 if(write_enable && ~(ac || dc)) next_state = W1;
//             end
//         W1: begin
//                 if(write_enable && ~(ac || dc)) next_state = W2; 
//         -> else no state change 
//         */

//         assign do_read  = bank_sel & ren & ~wen & ~bank_err;
//         assign do_write = bank_sel & wen & ~ren & ~bank_err;   

//         //combinational logic loop hehe 
//         assign write_lo[b]= (chip_select[b] & ~bank_busy) ? write_data[31:0]: write_lo[b];
//         assign write_hi[b]= (chip_select[b] & ~bank_busy) ? write_data[63:32]: write_hi[b];


// sram1024x32_wrapper SRAM_LO (
//                 .clk          (clk),
//                 .n_rst        (n_rst),
//                 .address      (addr),
//                 .read_enable  (do_read),
//                 .write_enable (do_write),
//                 .write_data   (write_lo[b]),
//                 .read_data    (rdata_lo[b]),
//                 .sram_state   (state_lo[b])
//             );

// sram1024x32_wrapper SRAM_HI (
//                 .clk          (clk),
//                 .n_rst        (n_rst),
//                 .address      (addr),
//                 .read_enable  (do_read),
//                 .write_enable (do_write),
//                 .write_data   (write_hi[b]),
//                 .read_data    (rdata_hi[b]),
//                 .sram_state   (state_hi[b])
//             );
//         end
//     endgenerate


//     assign read_data0 = { rdata_hi[0], rdata_lo[0] };
//     assign read_data1 = { rdata_hi[1], rdata_lo[1] };
//     assign read_data2 = { rdata_hi[2], rdata_lo[2] };
//     assign read_data3 = { rdata_hi[3], rdata_lo[3] };
                               ///////////random changes along the way///////////////////////

    // //using function here for this??? -> state didnt change when using function 
    // function logic bank_freelo(input logic [1:0] b);
    //     // return (bank_outlo[b].state == 2'b00 || bank_outlo[b].state == 2'b10); 
    //     return (bank_outlo[b].state == 2'b00); //not only changing for access 
    //     // FREE or ACCESS states allow a new transaction
    // endfunction

    // function logic bank_freehi(input logic [1:0] b);
    //     // return (bank_outhi[b].state == 2'b00 || bank_outhi[b].state == 2'b10); 
    //     return (bank_outhi[b].state == 2'b00); //not only changing for access 
    //     // FREE or ACCESS states allow a new transaction
    // endfunction

    // //combined bank_free
    // function logic bank_free(input logic [1:0] b);
    //     return bank_freelo(b) && bank_freehi(b);
    // endfunction

// // sram1024x32_wrapper I0 (.clk(clk), .n_rst(n_rst), .address(addr).read_enable({cs0&ren}), .write_enable({cs0&wen}), 
// //                             .write_data(write_data), .read_data(read_data0)), sram_state(sram_state);

// // sram1024x32_wrapper I1 (.clk(clk), .n_rst(n_rst), .address(addr).read_enable({cs1&ren}), .write_enable({cs1&wen}), 
// //                             .write_data(write_data), .read_data(read_data1)), sram_state(sram_state);

// // sram1024x32_wrapper I2 (.clk(clk), .n_rst(n_rst), .address(addr).read_enable({cs2&ren}), .write_enable({cs2&wen}), 
// //                             .write_data(write_data), .read_data(read_data2)), sram_state(sram_state);

// // sram1024x32_wrapper I2 (.clk(clk), .n_rst(n_rst), .address(addr).read_enable({cs3&ren}), .write_enable({cs3&wen}), 
// //                             .write_data(write_data), .read_data(read_data3)), sram_state(sram_state);

                               ///////////////////////////////////////////////////////////////////


        typedef struct packed { //struct???  -> make this a packed array?
            logic [31:0] rdata;
            logic [1:0]  state;   // 0=FREE,1=BUSY,2=ACCESS,3=ERROR
            logic [31:0] wdata;
        } bank_out_t;

        bank_out_t bank_outlo [3:0];
        bank_out_t bank_outhi [3:0];

        logic latched_ren [3:0];
        logic latched_wen [3:0];
        logic [9:0] latched_addr [3:0];
        logic [31:0]  latched_wdatalo [3:0];
        logic [31:0]  latched_wdatahi [3:0];
        logic bank_free[3:0];

        localparam LAT = 4;   // 4-cycle latency
        // logic prev_both_access [3:0];


        logic busy  [3:0];
        logic [2:0] countdown  [3:0];    
        assign bank_outlo[0].wdata = write_data0[31:0];
        assign bank_outhi[0].wdata = write_data0[63:32];
        assign bank_outlo[1].wdata = write_data1[31:0];
        assign bank_outhi[1].wdata = write_data1[63:32];
        assign bank_outlo[2].wdata = write_data2[31:0];
        assign bank_outhi[2].wdata = write_data2[63:32];
        assign bank_outlo[3].wdata = write_data3[31:0];
        assign bank_outhi[3].wdata = write_data3[63:32];


    genvar b;
        generate
            for (b = 0; b < 4; b++) begin 
            assign bank_free[b] = (!busy[b] && countdown[b] == 0);
            // assign bank_free[b] = ((bank_outlo[b].state == 2'b00) && (bank_outhi[b].state == 2'b00));
            
                always_ff @(posedge clk or negedge n_rst) begin
                    if (!n_rst) begin
                        busy[b]        <= 0;
                        countdown[b]   <= 0;
                        latched_ren[b]   <= 1'b0;
                        latched_wen[b]   <= 1'b0;
                        latched_addr[b]  <= '0;
                        latched_wdatalo[b] <= '0;
                        latched_wdatahi[b] <= '0;
                        // prev_both_access[b] <= 1'b0;
                        // read_valid[b] <= 1'b0;
                        // write_done[b] <= 1'b0;

                    end
                    else begin
                        // end whatever is aldredy happening on ACCESS 
                        // if (bank_outlo[b].state == 2'b10 && bank_outhi[b].state == 2'b10) begin
                    // read_valid[b] <= 1'b0;
                    // write_done[b] <= 1'b0;                    
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
                        if (ren && !wen) begin
                            latched_ren[b]  <= 1'b1;
                            latched_wen[b]  <= 1'b0;
                            latched_addr[b] <= addr;
                            busy[b]        <= 1;
                            countdown[b]   <= LAT;                            
                        end

                        if (wen && !ren) begin
                            latched_wen[b]  <= 1'b1;
                            latched_ren[b]  <= 1'b0;
                            latched_addr[b] <= addr;
                            latched_wdatalo[b] <= bank_outlo[b].wdata[31:0]; 
                            latched_wdatahi[b] <= bank_outhi[b].wdata[31:0]; 
                            busy[b]        <= 1;
                            countdown[b]   <= LAT;
                        
                        end
                    end
                    // if ((bank_outlo[b].state  == 2'd2) && (bank_outhi[b].state== 2'd2) && !prev_both_access[b]) begin
                    //     if (latched_ren[b]) read_valid[b] <= 1'b1;
                    //     if (latched_wen[b]) write_done[b] <= 1'b1;
                    //     prev_both_access[b] <= 1'b1;
                    // end else if ((bank_outlo[b].state != 2'd2) || (bank_outhi[b].state  != 2'd2)) begin
                    //     prev_both_access[b] <= 1'b0;
                    // end

                    // // clear latched controls when not busy
                    // if (!busy[b]) begin
                    //     latched_ren[b] <= 1'b0;
                    //     latched_wen[b] <= 1'b0;
                    // end
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
    
    // 0=FREE,1=BUSY,2=ACCESS,3=ERROR

endmodule


//num inputs and num input chunks changes async?
//change the states similar to weights as well 
