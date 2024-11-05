`timescale 1ns / 1ps
`include "design_constant.vh" 

module ac_temp_controller(
    input[1:0] ac_working_mode_i ,
    input[`TEMPERATURE_SENSOR_DATA_WIDTH-1:0] temparature_i,
    output[0:0] heater_mode_active_o,
    output[0:0] cooler_mode_active_o
    
    );
    
    wire need_to_cool_w = (temparature_i > `TEMPERATURE_SENSOR_MAX_TEMP);
    assign cooler_mode_active_o = (need_to_cool_w & ac_working_mode_i[`AC_COOL_MODE_BIT]);
    
    wire need_to_heat_w = (temparature_i < `TEMPERATURE_SENSOR_MIN_TEMP);
    assign heater_mode_active_o =(need_to_heat_w & ac_working_mode_i[`AC_HEAT_MODE_BIT]);
    

endmodule
