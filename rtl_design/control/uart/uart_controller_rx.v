`timescale 1ns / 1ps

module uart_controller_rx #(parameter CLOCK_RATE=100_000_000, BAUDE_RATE=9600)(clk, reset, rx, data_ready, data_out);
    input clk, reset, rx;
    output reg data_ready;
    output [7:0] data_out;
    
    localparam COUNTER_LIMIT = (CLOCK_RATE / BAUDE_RATE);
    localparam COUNTER_WIDTH = $clog2(COUNTER_LIMIT)+1;
    localparam COUNTER_TICK_VALUE = (COUNTER_LIMIT/2)-1;
    
    localparam STARTBIT=0, DATAPART=1, STOPBIT=2;
    
    reg counter_enable;
    reg [COUNTER_WIDTH-1:0] counter;
    reg [2:0] status, status_next;
    reg [3:0] dataCounter, dataCounter_next;
    reg [7:0] data, data_next;
    
    wire tick;
    
    assign data_out = data;
    assign tick = (counter == COUNTER_TICK_VALUE);
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if ((counter > COUNTER_LIMIT) | ~counter_enable) begin
            counter <= 0;
        end else if (counter_enable) begin
            counter <= (counter + 1);
        end
    end
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            status <= 0;
            dataCounter <= 0;
        end else begin
            status <= status_next;
            dataCounter <= dataCounter_next;
        end
    end
    
    always @(posedge clk) begin
        data <= data_next;
    end
    
    always @* begin
        counter_enable = 0;
        status_next = status;
        dataCounter_next = dataCounter;
        data_next = data;
        data_ready = 1'b0;
        
        case (status)
            STARTBIT: begin
                if (~rx) begin
                    dataCounter_next = 0;
                    counter_enable = 1;
                    status_next = DATAPART;
                end
            end
            
            DATAPART: begin
                counter_enable = 1;
                
                if (tick) begin
                    data_next = {rx, data[7:1]};
                    dataCounter_next = dataCounter + 1;
                    
                    if (dataCounter == 8) begin
                        status_next = STOPBIT;
                    end
                end
            end
            
            STOPBIT: begin
                counter_enable = 1;
                
                if (tick) begin
                    data_ready = 1'b1;
                    status_next = STARTBIT;
                end
            end
        endcase
    end
    
endmodule
