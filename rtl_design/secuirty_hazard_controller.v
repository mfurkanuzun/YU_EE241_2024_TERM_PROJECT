

module moduleName #(parameter CLOCK_RATE = 100_000_000; parameter COUNTER_LIMIT_IN_SEC = 10;) (
        input clk,
        input threat,

        output reg [1:0] security_level
    );

    localparam COUNTER_LIMIT = CLOCK_RATE * COUNTER_LIMIT_IN_SEC;
    localparam COUNTER_WIDTH = $clog2(COUNTER_LIMIT)+1;

    wire tick;
    reg counter_enable;
    reg [COUNTER_WIDTH-1:0] tick_counter;

    reg [3:0] status, status_next;
    reg [7:0] hazard_counter, hazard_counter_next;
    reg [1:0] security_level_next;

    initial begin
        counter_enable = 1'b0;
        tick_counter = 'b0;
        status = 'b0;
    end

    always @(posedge clk) begin
        if (counter_enable | (tick_counter != 0))
            tick_counter <= tick_counter + 1;
        
        if (tick_counter >= COUNTER_LIMIT)
            tick_counter <= 0;
    end

    assign tick = (tick_counter >= COUNTER_LIMIT);

    always @(posedge clk) begin
        status <= status_next;
        hazard_counter <= hazard_counter_next;
        security_level <= security_level_next;
    end

    always @(*) begin
        status_next = status;
        counter_enable = 1'b0;
        hazard_counter_next = hazard_counter;
        security_level_next = security_level;

        case (status)
            0: begin
                if (threat) begin
                    status_next = 1;
                    counter_enable = 1;
                end
            end
            
            1: begin
                if (threat)
                    hazard_counter_next = hazard_counter + 1;
                
                if (tick) begin
                    status_next = 0;

                    if (hazard_counter < 3)
                        security_level_next = 0;
                    else if (hazard_counter < 7)
                        security_level_next = 1;
                    else if (hazard_counter < 11)
                        security_level_next = 2;
                    else
                        security_level_next = 3;
                end
            end
        endcase
    end
    
endmodule