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

module ac_economy_mode_bhv
#(
  parameter HOME_WINDOW_COUNT = 8,  // Varsayılan parametre
  parameter HOME_DOOR_COUNT = 4    // Varsayılan parametre
)
(
  input eco_mode_valid_i,
  input [HOME_WINDOW_COUNT-1:0] WINDOW_STATUS_i,
  input [HOME_DOOR_COUNT-1:0] DOOR_STATUS_i,
  output reg close_ac_o
);

  // İç mantığın çalışması için her değişiklikte kontrol yap
  always @(*) begin
    // Eğer pencerelerden herhangi biri veya kapılardan herhangi biri açıksa
    if ((|WINDOW_STATUS_i) || (|DOOR_STATUS_i)) begin
      // ve ekonomi modu geçerliyse, AC'yi kapat
      if (eco_mode_valid_i) 
        close_ac_o = 1'b1;
      else 
        close_ac_o = 1'b0; // Ekonomi modu geçerli değilse kapama sinyali üretme
    end else begin
      // Pencereler ve kapılar kapalıysa kapama sinyali üretme
      close_ac_o = 1'b0;
    end
  end

endmodule

