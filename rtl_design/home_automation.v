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
        output AC_heat_o, AC_cool_o
    );
    
    wire TEMPCONTROLLER_ac_heat_w;
    wire TEMPCONTROLLER_ac_cool_w;
    
    wire NOWASTE_ac_energy_w;
    
    /*
            If the energy-saving module turns off the air conditioner for saving,
        signals from the air conditioner controller are disabled.
    */
    assign AC_heat_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_heat_w;
    assign AC_cool_o = ~NOWASTE_ac_energy_w & TEMPCONTROLLER_ac_cool_w;
    
endmodule
















