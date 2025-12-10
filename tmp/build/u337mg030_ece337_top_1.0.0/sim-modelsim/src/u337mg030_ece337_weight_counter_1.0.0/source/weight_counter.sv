`timescale 1ns / 10ps

module weight_counter #(
    // parameters
) (
    input clk, n_rst,
    input logic trigger_weight,
    output logic load, systolic_done

);

typedef enum logic[1:0] {  
    IDLE = 0, LOADING = 1, CLEAR = 2
} state_t;

state_t state, state_n;

logic clear, count_enable;
logic [2:0] count;

always_comb begin 
    systolic_done = (count == 3'd7);
end
/*verilator lint_off PINCONNECTEMPTY*/
flex_counter #(.SIZE(3)) counter (.clk(clk), .n_rst(n_rst), .clear(clear), .count_enable(count_enable), .rollover_val(3'd7), .count_out(count), .rollover_flag());
/*verilator lint_on PINCONNECTEMPTY*/

always_ff @( negedge n_rst, posedge clk ) begin : FF
    if (~n_rst) begin
        state <= IDLE;
    end else begin
        state <= state_n;
    end
end

always_comb begin : next_state_logic
    case (state)
        IDLE: begin
            if (trigger_weight) begin
                state_n = LOADING;
            end else begin
                state_n = IDLE;
            end
        end 
        
        LOADING: begin
            if (count == 3'd6) begin
                state_n = CLEAR;
            end else begin
                state_n = LOADING;
            end
        end

        CLEAR: begin
            state_n = IDLE;
        end
        default: ;
    endcase
end

always_comb begin : output_logic
    case (state)
        IDLE: begin
           count_enable = 0;
           clear = 1;
           load = 0; 
        end

        LOADING: begin
            count_enable = 1;
            clear = 0;
            load = 1;
        end

        CLEAR: begin
            count_enable = 1;
            clear = 1;
            load = 0;
        end
        default: ;
    endcase
end


endmodule

