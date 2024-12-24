`timescale 1ns / 1ps

`include "design_constant.vh"

module blinds_controller
    (
        input blinds_controller_valid_i,

        input [11:0] time_i,        // [{6 bit} : {6 bit}] HH:MM
        input [7:0] sunlight_level_i,

        output reg blinds_status_o
    );

    always @(*) begin
        if ((6'd8 < time_i[11:6]) & (time_i[11:6] < 6'd17)) begin
            blinds_status_o = 1'b1;     // open the blinds
        end else if (sunlight_level_i > 8'd128) begin // It's night but there's enough sunlight
            blinds_status_o = 1'b1;     // open the blinds
        end else begin
            blinds_status_o = 1'b0;     // close the blinds
        end
    end

endmodule

module blinds_controller_df
    (
        input blinds_controller_valid_i,

        input [11:0] time_i,        // [{6 bit} : {6 bit}] HH:MM
        input [7:0] sunlight_level_i,

        output blinds_status_o
    );

    wire time_condition = (6'd8 < time_i[11:6]) & (time_i[11:6] < 6'd17);  // Time check between 08:00 and 17:00
    wire sunlight_condition = sunlight_level_i > 8'd128;  // Sunlight check (sufficient sunlight)

    assign blinds_status_o = blinds_controller_valid_i & (time_condition | sunlight_condition);

endmodule
