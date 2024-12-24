`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2024 20:10:02
// Design Name: 
// Module Name: security_controller
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

`include "design_constant.vh"

module security_controller
    (
        input security_control_valid_i,                         // güvenliğin aktifleştirilmesi izni
        input [`PERSON_COUNTER_DATA_WIDTH-1:0] person_count_i,  // evdeki kişisayısı
        output lock_doors_o, lock_windows_o                     // kilit kontrol
    );
    
    wire security_mode_on = security_control_valid_i & (person_count_i == 0); // there is no person in the home, so lock everything
    
    assign lock_doors_o = security_mode_on;
    assign lock_windows_o = security_mode_on;
    
endmodule

module security_controller_bhv
    (
        input security_control_valid_i,                         // Güvenliğin aktifleştirilmesi izni
        input [`PERSON_COUNTER_DATA_WIDTH-1:0] person_count_i,  // Evdeki kişi sayısı
        output reg lock_doors_o,                                // Kapı kilit kontrol
        output reg lock_windows_o                               // Pencere kilit kontrol
    );

    always @(*) begin
        if (security_control_valid_i && (person_count_i == 0)) begin
            lock_doors_o = 1'b1;     // Kapıları kilitle
            lock_windows_o = 1'b1;  // Pencereleri kilitle
        end else begin
            lock_doors_o = 1'b0;     // Kapıları aç
            lock_windows_o = 1'b0;  // Pencereleri aç
        end
    end

endmodule


















