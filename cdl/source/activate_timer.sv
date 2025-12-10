`timescale 1ns / 10ps

module activate_timer #(
    // parameters
) (
    input clk, n_rst,
    input logic [6:0] num_inputs,
    input logic trigger_array, stall,
    output logic activated
);

typedef enum logic[1:0] {  
    IDLE = 0, COMPUTING = 1, ACTIVATED = 2
} state_t;

state_t state, state_n;

logic clear, computing, rollover_flag;
logic [6:0] count;

logic temp_activated;

/*verilator lint_off PINCONNECTEMPTY*/
flex_counter #(.SIZE(7)) counter (.clk(clk), .n_rst(n_rst), .clear(clear), .count_enable((~stall) && computing), .rollover_val(7'd16 + num_inputs), .count_out(count), .rollover_flag(rollover_flag));
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
            if (trigger_array) begin
                state_n = COMPUTING;
            end else begin
                state_n = IDLE;
            end
        end 
        
        COMPUTING: begin
            if (count == 7'd15) begin
                state_n = ACTIVATED;
            end else begin
                state_n = COMPUTING;
            end
        end

        ACTIVATED: begin
            if (rollover_flag) begin
                state_n = IDLE;
            end else begin
                state_n = ACTIVATED;
            end
        end
        default: ;
    endcase
end

always_comb begin : output_logic
    case (state)
        IDLE: begin
           clear = 1;
           computing = 0;
            temp_activated = 0;
        end

        COMPUTING: begin
            clear = 0;
            computing = 1;
            temp_activated = 0;
        end

        ACTIVATED: begin
            clear = 0;
            computing = 1;
            temp_activated = 1;
        end
        default: ;
    endcase
end

assign activated = temp_activated && (~stall);

endmodule

