module dff_glitch(clk,rst,D,Q,Qb);
input clk,rst;
input D;
output reg Q,Qb;

always @(posedge clk)begin
  if(rst)begin
   Q<=1'b0;
   Qb<=~Q;
  end else begin
   Q <=D;
   Qb <=~Q;
  end
end
endmodule

