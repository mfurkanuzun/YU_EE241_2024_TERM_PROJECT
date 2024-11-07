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
        // Register Konrol (Kumanda ile mesela)
        input command_valid_i,
        input [`COMMAND_CONTROL_TYPE_WIDTH-1:0] command_type_i,
        input [`COMMAND_CONTROL_DATA_WIDTH-1:0] command_data_i,
        
        // Sensor Verileri
        input[`TEMPERATURE_SENSOR_DATA_WIDTH-1:0] temparature_i,
        input [`HOME_WINDOW_COUNT-1:0] WINDOW_STATUS_i,
        input [`HOME_DOOR_COUNT-1:0] DOOR_STATUS_i,
        
        // Kontrol Çıkışları
        output AC_heat_o, AC_cool_o,
        output lock_doors_o, lock_windows_o
    );
    
    // CONTROL REGISTER LIST
    reg ECO_mod_valid_r;
    reg [1:0] ac_working_mode_r;
    reg [`PERSON_COUNTER_DATA_WIDTH-1:0] person_count_r;
    reg security_control_valid_r;
    //=======================================
    
    wire TEMPCONTROLLER_ac_heat_w;
    wire TEMPCONTROLLER_ac_cool_w;
    
    wire NOWASTE_ac_energy_w;
    
    /*
            If the energy-saving module turns off the air conditioner for saving,
        signals from the air conditioner controller are disabled.
    */
    assign AC_heat_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_heat_w;
    assign AC_cool_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_cool_w;
    
    // AC temp Controller
    ac_temp_controller AC_TEMP_CONTROLLER
    (
        .ac_working_mode_i(ac_working_mode_r),
        .temparature_i(temparature_i),
        
        .heater_mode_active_o(TEMPCONTROLLER_ac_heat_w),
        .cooler_mode_active_o(TEMPCONTROLLER_ac_cool_w)
    );
    
    // Economy Controller
    ac_economy_mode AC_ECO_CONTROLLER
    (  
        .eco_mode_valid_i(ECO_mod_valid_r),
        .WINDOW_STATUS_i(WINDOW_STATUS_i),
        .DOOR_STATUS_i(DOOR_STATUS_i),
        .close_ac_o(NOWASTE_ac_energy_w)
    );
    
    // SECURTY CONTOLLER
    security_controller SECURTY_CONTOLLER
    (
        .security_control_valid_i(security_control_valid_r),
        .person_count_i(person_count_r),
        .lock_doors_o(lock_doors_o),
        .lock_windows_o(lock_windows_o)
    );
    
endmodule
















