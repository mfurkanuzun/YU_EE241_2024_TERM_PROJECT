`timescale 1ns / 1ps

`include "./design_constant.vh"

module panel_controller (clk, reset, uart_rx_done, uart_rx_data,
    emergency_control_valid, ECO_mod_valid_r, ac_working_mode_r, person_count_r, security_control_valid_r
);

    input clk, reset, uart_rx_done;
    input [7:0] uart_rx_data;
    
    output reg emergency_control_valid;
    output reg ECO_mod_valid_r;
    output reg [1:0] ac_working_mode_r;
    output reg [`PERSON_COUNTER_DATA_WIDTH-1:0] person_count_r;
    output reg security_control_valid_r;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            emergency_control_valid <= 1'b0;
            ECO_mod_valid_r <= 1'b0;
            security_control_valid_r <= 1'b0;
            ac_working_mode_r <= 2'b0;
            person_count_r <= 'd0;
        end else if (uart_rx_done) begin
            case (uart_rx_data[7:4])
                4'h1: emergency_control_valid <= uart_rx_data[0];
                4'h0: ECO_mod_valid_r <= uart_rx_data[0];
                4'h7: security_control_valid_r <= uart_rx_data[0];
                4'ha: ac_working_mode_r <= uart_rx_data[3:0];
                4'hc: person_count_r <= (person_count_r + $signed(uart_rx_data[3:0]));
            endcase
        end
    end
    
endmodule