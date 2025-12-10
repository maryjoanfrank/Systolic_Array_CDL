// $Id: $
// File name:   ahb_model_updated.sv
// Created:     4/9/2025
// Author:      Aidan Prendergast
// Lab Section: 9999
// Version:     1.2  Design Updates
// Description: AHB Functional Model

`timescale 1ns / 10ps

module ahb_model_updated
#(
  parameter DATA_WIDTH = 2,
  parameter ADDR_WIDTH = 4
)
(
  // General System signals
  input  logic clk,
  // AHB-Subordinate side signals
  output logic hsel,
  output logic [(ADDR_WIDTH - 1):0] haddr,
  output logic [2:0] hsize,
  output logic [1:0] htrans,
  output logic [2:0] hburst,
  output logic hwrite,
  output logic [((DATA_WIDTH*8) - 1):0] hwdata,
  input  logic [((DATA_WIDTH*8) - 1):0] hrdata,
  input  logic hresp,
  input logic hready
);

localparam DATA_SELECT_WIDTH = $clog2(DATA_WIDTH);
localparam DATA_WIDTH_BITS = DATA_WIDTH * 8;
localparam DATA_MAX_BIT    = DATA_WIDTH_BITS - 1;
localparam ADDR_MAX_BIT    = ADDR_WIDTH - 1;
localparam BUS_DELAY       = 800ps;

// HTRANS Codes
localparam TRANS_IDLE = 2'd0;
localparam TRANS_BUSY = 2'd1;
localparam TRANS_NSEQ = 2'd2;
localparam TRANS_SEQ  = 2'd3;

// HBURST Codes
localparam BURST_SINGLE = 3'd0;
localparam BURST_INCR   = 3'd1;
localparam BURST_WRAP4  = 3'd2;
localparam BURST_INCR4  = 3'd3;
localparam BURST_WRAP8  = 3'd4;
localparam BURST_INCR8  = 3'd5;
localparam BURST_WRAP16 = 3'd6;
localparam BURST_INCR16 = 3'd7;

logic [((DATA_WIDTH*8) - 1):0] last_hrdata_read;
int num_transactions_left;

typedef struct {
  logic       fake;
  logic       write_mode;
  logic [ADDR_MAX_BIT:0] address;
  logic [DATA_MAX_BIT:0] data;
  logic       expect_error;
  logic [2:0] size;
  logic [1:0] trans;
  logic [2:0] burst;
  logic       verify;
} transaction_info;

// Declare the transaction queue
transaction_info transaction_queue[$];
transaction_info new_transaction;

struct { 
  logic addr_active;
  logic data_active;
  integer current_addr_transaction_num;
  integer current_data_transaction_num;
  transaction_info current_addr_transaction;
  transaction_info current_data_transaction;
} bus_state;

function void bus_idleize_addr;
  begin
    haddr   = 0;
    hsize   = 0;
    htrans  = TRANS_IDLE;
    hburst  = BURST_SINGLE;
    hwrite  = 1'b0;
  end
endfunction

function void bus_idleize_data;
  hwdata  = '0;
endfunction

function void bus_idleize;
  begin
    hsel    = 1'b0;
    bus_idleize_addr();
    bus_idleize_data();
  end
endfunction

function automatic void clear_trans(ref transaction_info target_transaction);
  begin
    target_transaction.fake         = 0;
    target_transaction.write_mode   = 0;
    target_transaction.address      = 0;
    target_transaction.size         = 0;
    target_transaction.data         = '0;
    target_transaction.expect_error = 0;
    target_transaction.trans        = TRANS_IDLE;
    target_transaction.burst        = BURST_SINGLE;
    target_transaction.verify       = 0;
  end
endfunction

// Clear model state
function void reset_model; begin
    // Empty the queue
    while(0 < transaction_queue.size()) begin
      // Remove an entry since there still is one in it
      void'(transaction_queue.pop_front());
    end
    // Clear the bus state
    bus_state.addr_active                  = '0;
    bus_state.current_addr_transaction_num = '0;
    clear_trans(bus_state.current_addr_transaction);
    bus_state.data_active                  = '0;
    bus_state.current_data_transaction_num = '0;
    clear_trans(bus_state.current_data_transaction);
    last_hrdata_read = 'X;
    num_transactions_left = 0;
  end
endfunction

// Enqueue a new transaction
function void enqueue_transaction (
  input logic sel,
  input logic write,
  input logic [(ADDR_WIDTH - 1):0] addr,
  input logic [((DATA_WIDTH*8) - 1):0] data [],
  input logic exp_error,
  input logic [2:0] size,
  input logic [2:0] burst,
  input logic verify
);
  integer i;
  logic wrap;
  integer burst_size;
  integer offset;
  begin
    new_transaction.write_mode   = write;
    new_transaction.fake         = ~sel;
    new_transaction.size         = size;
    new_transaction.burst        = burst;
    new_transaction.expect_error = exp_error;
    new_transaction.verify       = verify;

    if(burst == BURST_SINGLE) begin
      offset = addr - (ADDR_WIDTH'('1 << DATA_SELECT_WIDTH) & addr);
      // $display("BFM Offset: %h", offset);
      new_transaction.address      = addr;
      // $display("BFM Addr: %h", addr);
      new_transaction.trans        = sel ? TRANS_NSEQ : TRANS_IDLE;
      new_transaction.data = DATA_WIDTH_BITS'((~('1 << 8 * 2**size) & data[0]) << (8 * offset));
      // $display("BFM Data: %h", new_transaction.data);
      transaction_queue.push_back(new_transaction);
    end
    else begin // Burst Transfer Handling
      case(burst)
        BURST_INCR :   begin burst_size = data.size(); wrap = 1'b0; end
        BURST_WRAP4 :  begin burst_size = 4;  wrap = 1'b1; end
        BURST_INCR4 :  begin burst_size = 4;  wrap = 1'b0; end
        BURST_WRAP8 :  begin burst_size = 8;  wrap = 1'b1; end
        BURST_INCR8 :  begin burst_size = 8;  wrap = 1'b0; end
        BURST_WRAP16 : begin burst_size = 16; wrap = 1'b1; end
        BURST_INCR16 : begin burst_size = 16; wrap = 1'b0; end
      endcase
      for(i=0; i< burst_size; i++) begin
        new_transaction.address  = (wrap) ? (addr & ('1 << $clog2((2**size)*burst_size))) + ((addr + (i * 2 ** size)) % (burst_size * 2 ** size)) : addr + (i * 2 ** size);
        offset = new_transaction.address - (ADDR_WIDTH'('1 << DATA_SELECT_WIDTH) & new_transaction.address);

        new_transaction.trans    = sel ? (i==0) ? TRANS_NSEQ : TRANS_SEQ : TRANS_IDLE;
        new_transaction.data     = DATA_WIDTH_BITS'((~('1 << 8 * 2**size) & data[i]) << (8 * offset));
        transaction_queue.push_back(new_transaction);
      end
    end
  end
endfunction

// Execute n transactions from the queue
task run_transactions (
  input int num_transactions
); 
  begin
    @(negedge clk);
    num_transactions_left = num_transactions;
    @(negedge clk); // Dump out during addr phase of first transaction
  end
endtask

always @ (posedge clk) begin : DISPATCH_TRANSACTION
  if(!(!hready && bus_state.data_active)) begin // STALL CONDITION
    bus_state.data_active                   = bus_state.addr_active;
    bus_state.current_data_transaction      = bus_state.current_addr_transaction;
    bus_state.current_data_transaction_num  = bus_state.current_addr_transaction_num;

    if((0 < transaction_queue.size()) && 0 < num_transactions_left) begin
      num_transactions_left--;
      bus_state.addr_active                   = 1;
      bus_state.current_addr_transaction      = transaction_queue.pop_front();
      bus_state.current_addr_transaction_num += 1;
    end
    else begin
      bus_state.addr_active                   = 0;
      clear_trans(bus_state.current_addr_transaction);
    end
  end
  else if (hresp && bus_state.addr_active) begin
    // Store the Transaction in Addr Phase to Retry it
    transaction_queue.push_front(bus_state.current_addr_transaction);
    bus_state.addr_active = 0;
    clear_trans(bus_state.current_addr_transaction);
    num_transactions_left++;
  end
end

string idle_trans_resp_fail_msg;
string idle_trans_ready_fail_msg;
string addr_trans_resp_fail_msg;
string addr_trans_ready_fail_msg;
string fake_trans_resp_fail_msg;
string fake_trans_ready_fail_msg;
string expected_error_fail_msg;
string expected_rdata_fail_msg;

int i;
int minaddr;
int maxaddr; 
always @ (negedge clk) begin : VERIFY_OUTPUT
  // Format Error Messages
  $timeformat(-9, 0, " ns", 5);
  $sformat(idle_trans_resp_fail_msg,     "Incorrect 'hresp' response from subordinate device during idle transaction. Must provide OKAY response for idle state.\n   Expected 0, got %0b." , hresp);
  $sformat(idle_trans_ready_fail_msg,    "Incorrect 'hready' response from subordinate device during idle transaction. Must provide OKAY response for idle state.\n   Expected 1, got %0b.", hready);
  $sformat(addr_trans_resp_fail_msg,     "Incorrect 'hresp' response from subordinate device during addr-only phase of transaction (transaction %0d). Errors not permitted in this phase.\n   Expected 0, got %0b." , bus_state.current_addr_transaction_num, hresp);
  $sformat(addr_trans_ready_fail_msg,    "Incorrect 'hready' response from subordinate device during addr-only phase of transaction (transaction %0d). Stalls not permitted in this phase.\n   Expected 1, got %0b.", bus_state.current_addr_transaction_num, hready);
  $sformat(fake_trans_resp_fail_msg,     "Incorrect 'hresp' response from subordinate device during fake transaction (transaction %0d). Must provide OKAY response for fake transaction.\n   Expected 0, got %0b." , bus_state.current_data_transaction_num, hresp);
  $sformat(fake_trans_ready_fail_msg,    "Incorrect 'hready' response from subordinate device during fake transaction (transaction %0d). Must provide OKAY response for fake transaction.\n   Expected 1, got %0b.", bus_state.current_data_transaction_num, hready);
  $sformat(expected_error_fail_msg,      "Incorrect 'hresp' response from subordinate device during transaction (transaction %0d).\n   Expected %0b, got %0b."    , bus_state.current_data_transaction_num, bus_state.current_data_transaction.expect_error, hresp);
  $sformat(expected_rdata_fail_msg,      "Incorrect 'hrdata' response from subordinate device during transaction (transaction %0d).\n   Expected %0h, got %0h."   , bus_state.current_data_transaction_num, bus_state.current_data_transaction.data, hrdata);
  
  // Check responses for idle bus
  if(!bus_state.data_active && !bus_state.addr_active && 0.0 != $realtime) begin
    assert(1'b0 == hresp)
    else begin
      $error(idle_trans_resp_fail_msg);
    end
    assert(1'b1 == hready)
    else begin
      $error(idle_trans_ready_fail_msg);
    end
  end

  // Check responses for addr-phase only
  if(!bus_state.data_active && bus_state.addr_active) begin
    assert(1'b0 == hresp)
    else begin
      $error(addr_trans_resp_fail_msg);
    end
    assert(1'b1 == hready)
    else begin
      $error(addr_trans_ready_fail_msg);
    end
  end

  // Check responses for an hsel low transaction
  if(bus_state.current_data_transaction.fake) begin
    assert(1'b0 == hresp)
    else begin
      $error(fake_trans_resp_fail_msg);
    end
    assert(1'b1 == hready)
    else begin
      $error(fake_trans_ready_fail_msg);
    end
  end

  // Check error for a real, data-phase transaction
  if (bus_state.data_active && 1'b1 == hready && !bus_state.current_data_transaction.fake) begin
    assert(bus_state.current_data_transaction.expect_error == hresp)
    else begin
      $error(expected_error_fail_msg);
    end
    
    // Save value read for a read transaction, check read out if we've asked for it
    if(1'b0 == bus_state.current_data_transaction.write_mode) begin
      last_hrdata_read = hrdata;
      // Verify hrdata
      if(1'b1 == bus_state.current_data_transaction.verify) begin
        // Get valid bus lanes
        int i;
        minaddr = bus_state.current_data_transaction.address[DATA_SELECT_WIDTH-1:0];
        maxaddr = minaddr + (2 ** bus_state.current_data_transaction.size);

        for(i = minaddr; i < maxaddr; i++) begin
          assert (bus_state.current_data_transaction.data[i * 8 +: 8] == hrdata[i * 8 +: 8])
          else begin
            $error(expected_rdata_fail_msg);
            break;
          end
        end
      end
    end
  end
end

// Give outside source last_hrdata_read
function logic [((DATA_WIDTH*8) - 1):0] get_last_read;
  return last_hrdata_read;
endfunction

// Handle bus pin wiggles
always @ (posedge clk) begin
  #(BUS_DELAY);
  bus_idleize();
  if(bus_state.addr_active || bus_state.data_active) begin
    hsel = (!bus_state.current_addr_transaction.fake & bus_state.addr_active)
          |(!bus_state.current_data_transaction.fake & bus_state.data_active);
  end
  if(bus_state.addr_active) begin
    haddr  = bus_state.current_addr_transaction.address;
    hwrite = bus_state.current_addr_transaction.write_mode;
    hsize  = bus_state.current_addr_transaction.size;
    htrans = bus_state.current_addr_transaction.trans;
    hburst = bus_state.current_addr_transaction.burst;
  end
  if(bus_state.data_active) begin
    hwdata = (bus_state.current_data_transaction.write_mode) ? bus_state.current_data_transaction.data : '0;
  end
end

task wait_done();
  assert(bus_state.addr_active || bus_state.data_active)
  else begin
    $error("There is no active transaction to finish.");
    return;
  end

  while(bus_state.addr_active || bus_state.data_active) begin
    @(negedge clk);
  end
endtask

endmodule