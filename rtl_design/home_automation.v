`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2024 20:42:40
// Design Name: 
// Module Name: home_automation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module home_automation
    (
        input[`TEMPERATURE_SENSOR_DATA_WIDTH-1:0] temparature_i,
        output AC_heat_o, AC_cool_o
    );
    
    reg [1:0] ac_working_mode_r;
    
    wire TEMPCONTROLLER_ac_heat_w;
    wire TEMPCONTROLLER_ac_cool_w;
    
    wire NOWASTE_ac_energy_w;
    
    /*
            If the energy-saving module turns off the air conditioner for saving,
        signals from the air conditioner controller are disabled.
    */
    assign AC_heat_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_heat_w;
    assign AC_cool_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_cool_w;
    
    // AC temp controller
    ac_temp_controller AC_TEMP_CONTROLLER
    (
        .ac_working_mode_i(ac_working_mode_r),
        .temparature_i(temparature_i),
        
        .heater_mode_active_o(TEMPCONTROLLER_ac_heat_w),
        .cooler_mode_active_o(TEMPCONTROLLER_ac_cool_w)
    );
    
endmodule
















