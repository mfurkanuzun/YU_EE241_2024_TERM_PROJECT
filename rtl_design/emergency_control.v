`timescale 1ns / 1ps

`include "design_constant.vh"

module emergency_control
    (
        input emergency_control_valid_i,
        output warning_o, alert_o,

        // water
        input water_meter_status_i,
        input [7:0] home_tap_status_i,

        // gas
        input gas_meter_i,
        input gas_detector_i,
        input [1:0] stove_status_i,
        input [0:0] ac_system_status_i
    );

    assign warning_o = emergency_control_valid_i & water_meter_status_i & ~(|home_tap_status_i);
    
    assign alert_o = emergency_control_valid_i & (
            ((gas_meter_i & ~((|stove_status_i) | (|ac_system_status_i))) | gas_detector_i)
        );

endmodule

module emergency_control_bhv
    (
        input emergency_control_valid_i,   // Acil durum kontrol izni
        output reg warning_o,              // Uyarı sinyali
        output reg alert_o,                // Alarm sinyali

        // Su ile ilgili girişler
        input water_meter_status_i,        // Su sayacı durumu
        input [7:0] home_tap_status_i,     // Muslukların durumu

        // Gaz ile ilgili girişler
        input gas_meter_i,                 // Gaz sayacı durumu
        input gas_detector_i,              // Gaz dedektörü durumu
        input [1:0] stove_status_i,        // Ocak durumu
        input [0:0] ac_system_status_i     // Klima sistemi durumu
    );

    always @(*) begin
        // Uyarı sinyali kontrolü
        if (emergency_control_valid_i && water_meter_status_i && ~(|home_tap_status_i)) begin
            warning_o = 1'b1;
        end else begin
            warning_o = 1'b0;
        end

        // Alarm sinyali kontrolü
        if (emergency_control_valid_i && 
           ((gas_meter_i && ~((|stove_status_i) || (|ac_system_status_i))) || gas_detector_i)) begin
            alert_o = 1'b1;
        end else begin
            alert_o = 1'b0;
        end
    end

endmodule
