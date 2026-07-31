module controller_fsm(

input clk,
input reset_n,

input start,

input error,
input [31:0] read_data,

output reg cs,
output reg we,
output reg [7:0] address,
output reg [31:0] write_data,

output reg done,

output reg [255:0] digest

);