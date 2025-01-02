`timescale 1ns / 1ps

`include "./design_constant.vh"

module home_automation
    (
        input clk, reset,
        
        // UART
        input rx,
        output tx,
        
        output warning_o, alert_o,
        
        // Buttonlar
        input AC_push_button,
        
        // Sensor Verileri
        input threat,
        
        input[`TEMPERATURE_SENSOR_DATA_WIDTH-1:0] temparature_i,
        input [`HOME_WINDOW_COUNT-1:0] WINDOW_STATUS_i,
        input [`HOME_DOOR_COUNT-1:0] DOOR_STATUS_i,
        
        input [11:0] time_i,        // [{6 bit} : {6 bit}] HH:MM
        input [7:0] sunlight_level_i,
        output blinds_status_o,
        
        input wire a,
        input wire b,    
        output wire [2:0] led_status,
        
        // water
        input water_meter_status_i,
        input [7:0] home_tap_status_i,

        // gas
        input gas_meter_i,
        input gas_detector_i,
        input [1:0] stove_status_i,
        
        // Kontrol Çıkışları
        output AC_heat_o, AC_cool_o,
        output lock_doors_o, lock_windows_o
    );
    
    wire uart_rx_done;
    wire [7:0] uart_rx_data;
    
    wire uart_send;
    wire [7:0] security_level_uart_data;
    
    uart_controller_rx
    #(.CLOCK_RATE(100_000_000), .BAUDE_RATE(9600))
    UART_RX
    (clk, reset, rx, uart_rx_done, uart_rx_data);
    
    uart_controller_tx
    #(.CLOCK_RATE(100_000_000), .BAUDE_RATE(9600))
    UART_TX
    (clk, reset, tx, uart_send, security_level_uart_data, done);
    
    /////////////////////////////////////////////////////////////////////////////////////
    wire ECO_mod_valid_r;
    wire emergency_control_valid;
    wire [1:0] ac_working_mode_r;
    wire [`PERSON_COUNTER_DATA_WIDTH-1:0] person_count_r;
    wire security_control_valid_r;
    
    panel_controller CONTROL_PANEL (clk, reset, uart_rx_done, uart_rx_data,
        emergency_control_valid, ECO_mod_valid_r, ac_working_mode_r, person_count_r, security_control_valid_r
    );
    /////////////////////////////////////////////////////////////////////////////////////
    
    wire AC_ECO_STATUS;
    
    wire TEMPCONTROLLER_ac_heat_w;
    wire TEMPCONTROLLER_ac_cool_w;
    
    wire NOWASTE_ac_energy_w;
    
    /*
            If the energy-saving module turns off the air conditioner for saving,
        signals from the air conditioner controller are disabled.
    */
    assign AC_heat_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_heat_w;
    assign AC_cool_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_cool_w;

   
    ac_control_unit AC_UNIT_CONTROLlER (AC_push_button,AC_ECO_STATUS,clk);
    
    blinds_controller BLINDS_CONTROLLER
    (
        .blinds_controller_valid_i(AC_ECO_STATUS),

        .time_i(time_i),
        .sunlight_level_i(sunlight_level_i),

        .blinds_status_o(blinds_status_o)
    );
    
    fsm_lights LIGHTS (a,b,clk,reset,led_status);
    
    secuirty_hazard_controller
    SECURTY_CONTROL
    (
        clk,
        threat,

        security_level_uart_data
    );
    
    assign uart_send = (|security_level_uart_data);
    
    emergency_control EMERGENCY
    (
        emergency_control_valid,
        warning_o, alert_o,

        // water
        water_meter_status_i,
        home_tap_status_i,

        // gas
        gas_meter_i,
        gas_detector_i,
        stove_status_i,
        (ac_working_mode_r & AC_ECO_STATUS)
    );
    
    // AC temp Controller
    ac_temp_controller AC_TEMP_CONTROLLER
    (
        .ac_working_mode_i(ac_working_mode_r & AC_ECO_STATUS),
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


 /*
    // bh form
    always @(*) begin
        // AC_heat_o çıkışı, enerji israfı yoksa ve ısıtıcı modu aktifse 1 olur
        if (~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_heat_w) begin
            AC_heat_o = 1'b1;
        end else begin
            AC_heat_o = 1'b0;
        end
        
        // AC_cool_o çıkışı, enerji israfı yoksa ve soğutma modu aktifse 1 olur
        if (~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_cool_w) begin
            AC_cool_o = 1'b1;
        end else begin
            AC_cool_o = 1'b0;
        end
    end
    */
    













