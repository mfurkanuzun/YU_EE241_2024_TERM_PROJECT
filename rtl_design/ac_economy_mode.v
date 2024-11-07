`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2024 19:57:38
// Design Name: 
// Module Name: ace_conomy_mode
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

module ac_economy_mode
  (  
input eco_mode_valid_i,
input [`HOME_WINDOW_COUNT-1:0] WINDOW_STATUS_i,
input [`HOME_DOOR_COUNT-1:0] DOOR_STATUS_i,
output close_ac_o 
  );
  wire close_ac_w = (|WINDOW_STATUS_i) | (|DOOR_STATUS_i);
  assign  close_ac_o = close_ac_w & eco_mode_valid_i;
  
  
  
  
  
endmodule
