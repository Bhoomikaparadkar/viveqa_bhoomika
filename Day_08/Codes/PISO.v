module PISO(clk,rst,data_in,load,shift,data_out);
input clk,rst;
input [3:0]data_in;
input load,shift;
output reg data_out;

reg [3:0]data_reg;
reg [1:0]cnt;
reg shift_d;
wire pos_shift;

always@(posedge clk)begin
	if(rst)begin
	 data_out <=1'b0;
         cnt<=2'b0;
         data_reg<=4'b0;
	end else begin
          if(load) data_reg <=data_in;
          else if(pos_shift)begin
          data_out<=data_reg[cnt];
          cnt <=cnt+1;
          end
	end
end

always@(posedge clk)begin
if(rst)begin
	 shift_d <=1'b0;
	end else shift_d <=shift;
end

assign pos_shift=~shift_d & shift;


endmodule


