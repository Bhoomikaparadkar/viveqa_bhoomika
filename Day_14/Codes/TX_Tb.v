`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 06:18:34 AM
// Design Name: 
// Module Name: TX_Tb
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


module TX_Tb();
reg clk,rst;
reg tx_start;
reg [7:0]tx_data;

wire tx,tx_busy,tx_done;

uart_tx dut(clk,rst,tx_start,tx_data,tx,tx_busy,tx_done);

always #20.8 clk=~clk;

initial begin
clk=1'b0;
rst=1'b0;
tx_start=1'b0;
tx_data=8'b0;
#40 rst=1'b1;
#40 rst=1'b0;
#40 tx_start=1'b1; tx_data=8'hAB;
#40 tx_start=1'b0;

#1000000;
$stop;
end


endmodule

