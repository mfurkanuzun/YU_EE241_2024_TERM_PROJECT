`timescale 1ns / 1ps

`include "design_constant.vh"

module tb_top_module();
    
    localparam T = 10;
    localparam CLOCK_RATE=100_000_000, BAUDE_RATE=9600;
    localparam TRX = (CLOCK_RATE/BAUDE_RATE)*10;

    reg clk, reset;
    reg rx;
    wire tx, warning_o, alert_o;
    
    reg AC_push_button;
    
    reg threat;
    reg [`TEMPERATURE_SENSOR_DATA_WIDTH-1:0] temparature_i;
    reg [`HOME_WINDOW_COUNT-1:0] WINDOW_STATUS_i;
    reg [`HOME_DOOR_COUNT-1:0] DOOR_STATUS_i;
    
    reg [11:0] time_i;        // [{6 bit} : {6 bit}] HH:MM
    reg [7:0] sunlight_level_i;
    wire blinds_status_o;
    
    reg a;
    reg b;
    wire [2:0] led_status;
    
    // water
    reg water_meter_status_i;
    reg [7:0] home_tap_status_i;

    // gas
    reg gas_meter_i;
    reg gas_detector_i;
    reg [1:0] stove_status_i;
    
    // Kontrol Çıkışları
    wire AC_heat_o, AC_cool_o;
    wire lock_doors_o, lock_windows_o;

    home_automation DUT
    (
        clk, reset,
        
        // UART
        rx,
        tx,
        
        warning_o, alert_o,
        
        // Buttonlar
        AC_push_button,
        
        // Sensor Verileri
        threat,
        
        temparature_i,
        WINDOW_STATUS_i,
        DOOR_STATUS_i,
        
        time_i,        // [{6 bit} : {6 bit}] HH:MM
        sunlight_level_i,
        blinds_status_o,
        
        a,
        b,    
        led_status,
        
        // water
        water_meter_status_i,
        home_tap_status_i,

        // gas
        gas_meter_i,
        gas_detector_i,
        stove_status_i,
        
        // Kontrol Çıkışları
        AC_heat_o, AC_cool_o,
        lock_doors_o, lock_windows_o
    );
    
    integer i_rx;
    reg [7:0] txdata;
    task UART_RECEIVE;
        begin
            wait (tx == 1'b0); #(TRX/2); // start bit
            for (i_rx=0; i_rx<8; i_rx=i_rx+1) begin
                #(TRX);
                txdata[i_rx] = tx;
            end
            #(TRX/2); // stop bit
        end
    endtask
    
    integer i_tx;
    task UART_SEND;
        input [7:0] data;
        
        begin
            rx = 1'b0; #(TRX); // start bit
            for (i_tx=0; i_tx<8; i_tx=i_tx+1) begin
                rx = data[i_tx]; #(TRX);
            end
            rx = 1'b1; #(TRX); // stop bit
        end
    endtask
    
    task AC_TEST;
        begin
            AC_push_button = 1'b1;
            #(T);
            AC_push_button = 1'b0;
        end
    endtask
    
    task AC_TEMP_TEST;
        input mod;
        
        begin
            if (mod == 1'b0)
                temparature_i = `TEMPERATURE_SENSOR_MAX_TEMP+1;
            else
                temparature_i = `TEMPERATURE_SENSOR_MIN_TEMP-1;
            
            #(T);
            
            temparature_i = `TEMPERATURE_SENSOR_MIN_TEMP+1;
        end
    endtask

    task ECO_MOD_TEST;
        begin
            WINDOW_STATUS_i = 1;
            DOOR_STATUS_i = 1;
            #(T);
            WINDOW_STATUS_i = 0;
            DOOR_STATUS_i = 0;
        end
    endtask
    
    task BLIND_CONTROL;
        input [7:0] mod;
        begin
            if (mod == 0) begin // morning
                time_i = {6'd12, 6'd00};        // [{6 bit} : {6 bit}] HH:MM
                sunlight_level_i = 8'd200;
            end else if (mod == 1) begin // night but there is enough light
                time_i = {6'd22, 6'd00};        // [{6 bit} : {6 bit}] HH:MM
                sunlight_level_i = 8'd230;
            end else begin // night and there is no enough light
                time_i = {6'd22, 6'd00};        // [{6 bit} : {6 bit}] HH:MM
                sunlight_level_i = 8'd0;
            end
        end
    endtask
    
    task LIGHT_BUTTONS;
        input btnA;
        input btnB;
        begin
            a = btnA;
            b = btnB;
            #(T);
            a = btnA;
            b = btnB;
        end
    endtask
    
    // Light control
    initial begin
        a = 1'b0;
        b = 1'b0;
        
        #(T*3);
        
        LIGHT_BUTTONS(1,0);#(T);
        LIGHT_BUTTONS(0,1);#(T);
        LIGHT_BUTTONS(1,1);#(T);
        LIGHT_BUTTONS(1,0);#(T);
        LIGHT_BUTTONS(0,1);#(T);
    end
    
    // ac button
    initial begin
        AC_TEST(); #(T*10);
        AC_TEST(); #(T*10);
    end
    
    initial begin
        AC_TEMP_TEST(0); #(T*10);
        AC_TEMP_TEST(1); #(T*10);
    end
    
    initial begin
        ECO_MOD_TEST();
    end
    
    initial begin
        BLIND_CONTROL(0); #(T*10);
        BLIND_CONTROL(1); #(T*10);
        BLIND_CONTROL(2); #(T*10);
    end

    initial begin
        threat = 1'b0; #(T*5);
        threat = 1'b1; #(T); threat = 1'b0; #(T*5);
        threat = 1'b1; #(T); threat = 1'b0; #(T);
        threat = 1'b1; #(T); threat = 1'b0; #(T);
        threat = 1'b1; #(T); threat = 1'b0; #(T*5);
        #(10*(10**9)); // wait 10 sn for threat counter
        
        UART_RECEIVE();
    end
    
    initial begin
        #(T*5);
        UART_SEND({4'h0,  4'b1}); #(T*2); // open eco mode
        UART_SEND({4'ha,  4'd3}); #(T*2); // open ac
        UART_SEND({4'hc,  4'd7}); #(T*2); // add 7 person
        UART_SEND({4'hc, -4'd2}); #(T*2); // sub 2 person
    end
    
   always #(T/2) clk=~clk;
    
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        #(T*2);
        reset = 1'b0;
    end

endmodule
























