module top(clk);
input clk;

wire wr_en;
wire [31:0]addr,write_data,read_data;

single_port_ram ram(clk,addr,wr_en,write_data,read_data);

ila_0 ila (
	.clk(clk), // input wire clk


	.probe0(wr_en), // input wire [0:0]  probe0  
	.probe1(addr), // input wire [31:0]  probe1 
	.probe2(write_data), // input wire [31:0]  probe2 
	.probe3(read_data) // input wire [31:0]  probe3
);

vio_0 vio (
  .clk(clk),                // input wire clk
  .probe_in0(read_data),    // input wire [31 : 0] probe_in0
  .probe_out0(wr_en),  // output wire [0 : 0] probe_out0
  .probe_out1(addr),  // output wire [31 : 0] probe_out1
  .probe_out2(write_data)  // output wire [31 : 0] probe_out2
);

endmodule

