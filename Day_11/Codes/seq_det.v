module seq_det(clk,rst,ip,op);
input clk,rst;
input ip;
output reg op;

wire d1;
wire q0,qb0,q1,qb1;

dff dff0(clk,rst,~ip,q0,qb0);

assign d1=ip&q0;

dff dff1(clk,rst,d1,q1,qb1);

always @(posedge clk)begin
if(rst)op<=1'b0;
else op <=ip&q1;
end

endmodule

