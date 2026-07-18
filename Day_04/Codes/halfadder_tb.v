`timescale 1ns / 1ps


module halfadder_tb();
reg a,b;
wire sum,carry;
halfadder dut(.a(a),.b(b),.sum(sum),.carry(carry));
initial begin
a=1'b0;b=1'b0;
#5
a=1'b0;b=1'b1;
#5
a=1'b1;b=1'b0;
#5
a=1'b1;b=1'b1;
#5;
end
endmodule
