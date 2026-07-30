module single_port_ram(clk,addr,wr_en,write_data,read_data);
input clk;
input [31:0]addr;
input wr_en;
input [31:0]write_data;
output reg[31:0]read_data;

reg [31:0]mem[0:63]; //created a memory structure of 32 bits and 64 locations

always@(posedge clk)begin
     if(wr_en)mem[addr] <=write_data;
     else read_data <=mem[addr];
end
endmodule

module single_port_ram_tb();
reg clk;
reg [31:0]addr;
reg wr_en;
reg [31:0]write_data;
wire [31:0]read_data;
