`timescale 1ns / 1ps
module fsm_lights(a,b,clk,rst,led_status
     
);
    input wire a;   
    input wire b;      
    input wire clk;    
    input wire rst;    
    output reg [2:0] led_status;

    
    localparam
        OFF = 3'b000,
        RED_LIGHT = 3'b001,
        GREEN_LIGHT = 3'b010,
        BLUE_LIGHT = 3'b011,
        WHITE_LIGHT = 3'b100;

    reg [7:0] current_state, next_state;

    
    always @(*) begin
        case (current_state)
            OFF: begin
                if (a && ~b) next_state = RED_LIGHT;
                else if (~a && b) next_state = GREEN_LIGHT;
                else next_state = OFF;
            end
            RED_LIGHT: begin
                if (a && ~b) next_state = GREEN_LIGHT;              
                else next_state = RED_LIGHT;
            end
            GREEN_LIGHT: begin
                if (a && ~b) next_state = BLUE_LIGHT;
                else if (~a && b) next_state = WHITE_LIGHT;
                else next_state = GREEN_LIGHT;
            end
            BLUE_LIGHT: begin
                if (a && ~b) next_state = WHITE_LIGHT;
                else next_state = BLUE_LIGHT;
            end
            WHITE_LIGHT: begin
                if (a && ~b) next_state = OFF;
                else next_state = WHITE_LIGHT;
            end
            default: next_state = OFF;
        endcase
    end

    
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= OFF;
        else
            current_state <= next_state;
    end

    
    always @(*) begin
        led_status = current_state;
    end

endmodule
