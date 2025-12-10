`timescale 1ns / 10ps

module HBURST (
    input logic clk, n_rst,
    input  logic hsel,
    input  logic [9:0] haddr,
    input  logic [1:0] htrans,
    input  logic [2:0] hsize,
    input  logic hwrite,
    input logic [2:0]hburst,
    input logic hready,

    output logic burst_active_reg, 
    output logic [9:0] burst_addr_reg
);

    // External inputs registered
    logic hsel_reg;
    logic [9:0] haddr_reg;
    logic [1:0] htrans_reg;
    logic [2:0] hsize_reg;
    logic hwrite_reg;
    logic [63:0] hwdata_reg;
    logic [2:0] hburst_reg;

    //burst related logic
    logic        burst_active, burst_active_reg;
    logic [9:0]  burst_addr_reg, burst_addr_next;
    logic [9:0]  burst_base_addr_reg, burst_base_addr_next;
    logic [9:0]  burst_beats_reg, burst_beats_next;
    logic [2:0]  burst_type_reg, burst_type_next; 

    logic [9:0] burst_length; 
    logic [9:0] burst_increment; 
    logic [2:0] beat_shift;
    logic [9:0] boundary; 
    logic [9:0] wrap_mask;
    logic [9:0] align_mask;
    logic [9:0] wrap_align_mask;

    // external inputs register
    always_ff @(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            hsel_reg <= 1'b0;
            haddr_reg <= 10'd0;
            htrans_reg <= 2'd0;
            hsize_reg <= 3'd0;
            hwrite_reg <= 1'b0;
            hwdata_reg <= 64'd0;
            hburst_reg <= 3'd0;
            hrdata <= 64'd0;
        end 
        else begin
            hsel_reg <= hsel;
            haddr_reg <= haddr;
            htrans_reg <= htrans;
            hsize_reg <= hsize;
            hwrite_reg <= hwrite;
            hwdata_reg <= hwdata;
            hburst_reg <= hburst;
            hrdata <= store_hrdata;
        end
    end

    // bursting register
    always_ff@(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            burst_active_reg      <= 1'b0;
            burst_type_reg        <= 3'd0;
            burst_addr_reg        <= 10'd0;
            burst_base_addr_reg   <= 10'd0;
            burst_beats_reg       <= 4'd0;
        end
        else begin
            burst_active_reg      <= burst_active;
            burst_type_reg        <= burst_type_next;
            burst_addr_reg        <= burst_addr_next;
            burst_base_addr_reg   <= burst_base_addr_next;
            burst_beats_reg       <= burst_beats_next;
        end
    end

    // bursting comb
    always_comb begin
        burst_active        = burst_active_reg; // there's a burst
        burst_type_next     = burst_type_reg; // what's teh burst type? (INCR/WRAP)
        burst_addr_next     = burst_addr_reg;  // what address of the AHB reguister is the burst occuring at?
        burst_base_addr_next = burst_base_addr_reg; // where is our next burst address at? depening on the byte-size
        burst_beats_next    = burst_beats_reg;  // by how much are we jumping?

        case(hsize_reg) // basically how much are jumping after one burst? depends on size
            3'd0: beat_shift  = 3'd0;  // 1 byte
            3'd1: beat_shift  = 3'd1;  // 2 bytes
            3'd2: beat_shift  = 3'd2;  // 4 bytes
            3'd3: beat_shift  = 3'd3;  // 8 bytes
            default: beat_shift  = 3'd0;
        endcase
 
        burst_increment  = 4'd1 << beat_shift; // used when saying we start at addreass 0 and if size is 1/2/4/8 bytes it moves by that 

        case (burst_type_reg)
            3'd0: burst_length = 4'd1;   // SINGLE
            3'd1: burst_length = 4'd0;  // unlimited
            3'd2, 3'd3: burst_length = 4'd4;   // INCR4/WRAP4
            3'd4, 3'd5: burst_length = 4'd8;   // INCR8/WRAP8
            3'd6, 3'd7: burst_length = 4'd16;  // INCR16/WRAP16
            default:    burst_length = 4'd0;   // INCR (unlimited)
        endcase

        boundary = burst_length << beat_shift;  // total bytes in a burst
        wrap_mask = boundary - 1;

        if(~hsel) burst_active = 1'b0;
        if((htrans == 2'd0) && hsel) burst_active = 1'b0;

        // if in slave, in first burst and not a single transfer
        if(hsel_reg && htrans_reg == 2'b10) begin // do we want to use current hburst? // first beat of a burst or ind. transfer
            burst_active        = 1'b1;
            burst_type_next     = hburst_reg; // captures the burst type
            burst_beats_next    = 1; // reset beat counter

            // BEAT-SIZE alignment mask
            align_mask = ~(burst_increment - 1);  // beat alignment mask that clears lower bits

            // WRAP boundary alignment mask
            wrap_align_mask = ~(boundary - 1);

            if (hburst_reg == 3'd2 || hburst_reg == 3'd4 || hburst_reg == 3'd6) begin
                // WRAP burst: align to WRAP boundary
                burst_base_addr_next = (haddr_reg & wrap_align_mask);
                burst_addr_next      = haddr_reg & align_mask;
            end
            else begin
                // NON-WRAP burst: align to beat size
                burst_base_addr_next = haddr_reg & align_mask;
                burst_addr_next      = haddr_reg & align_mask;
            end
        end
        else if(burst_active_reg && hready && htrans_reg == 2'b11 ) begin
            burst_beats_next = burst_beats_reg + 1;
            burst_base_addr_next = burst_base_addr_reg;

            case(burst_type_reg)
                3'd1: begin 
                    burst_addr_next = burst_addr_reg + burst_increment;
                    burst_active = 1'b1;
                end

                3'd3, 3'd5, 3'd7: begin
                    burst_addr_next = burst_addr_reg + burst_increment;
                    if (burst_beats_next >= burst_length)
                        burst_active = 1'b0;
                end
                3'd2, 3'd4, 3'd6: begin
                    burst_addr_next = burst_base_addr_reg +
                        (((burst_addr_reg - burst_base_addr_reg) + burst_increment) & wrap_mask);

                    if (burst_beats_next >= burst_length)
                        burst_active = 1'b0;
                end
                default:  burst_active = 1'b0;
            endcase
        end
    end
endmodule