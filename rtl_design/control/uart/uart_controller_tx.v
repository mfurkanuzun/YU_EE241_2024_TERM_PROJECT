`timescale 1ns / 1ps

module uart_controller_tx #(parameter CLOCK_RATE=100_000_000, BAUDE_RATE=9600)(clk, reset, tx, data_valid, data_in, done);
    input clk, reset, data_valid;
    input [7:0] data_in;
    output reg tx, done;
    
    localparam COUNTER_LIMIT = (CLOCK_RATE / BAUDE_RATE);
    localparam COUNTER_WIDTH = $clog2(COUNTER_LIMIT)+1;
    localparam COUNTER_TICK_VALUE = COUNTER_LIMIT-1;
    
    localparam IDLE=0, STARTBIT=1, DATAPART=2, STOPBIT=3;
    
    reg counter_enable;
    reg [COUNTER_WIDTH-1:0] counter;
    reg [2:0] status, status_next;
    reg [3:0] dataCounter, dataCounter_next;
    reg [7:0] data, data_next;
    
    wire tick;
    
    assign tick = (counter == COUNTER_TICK_VALUE);
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if ((counter == COUNTER_LIMIT) | ~counter_enable) begin
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
        tx = 1'b1;
        done = 1'b0;
        
        case (status)
            IDLE: begin
                if (data_valid) begin
                    dataCounter_next = 0;
                    counter_enable = 1;
                    data_next = data_in;
                    
                    status_next = STARTBIT;
                end
            end
            
            STARTBIT: begin
                counter_enable = 1;
                tx = 1'b0;
                
                if (tick) begin
                    status_next = DATAPART;
                end
            end
            
            DATAPART: begin
                counter_enable = 1;
                tx = data[0];
                
                if (tick) begin
                    data_next = {1'b0, data[7:1]};
                    dataCounter_next = dataCounter + 1;
                    
                    if (dataCounter == 7) begin
                        status_next = STOPBIT;
                    end
                end
            end
            
            STOPBIT: begin
                counter_enable = 1;
                tx = 1'b1;
                
                if (tick) begin
                    done = 1'b1;
                    status_next = IDLE;
                end
            end
        endcase
    end
    
endmodule
