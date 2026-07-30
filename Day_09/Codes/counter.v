
module counter(clk,rst,count);
input clk,rst;
output reg[3:0]count;

always@(posedge clk)begin
      if(rst) count<=4'b0;
      else count <=count +4'b1;
end
endmodule




