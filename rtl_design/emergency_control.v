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