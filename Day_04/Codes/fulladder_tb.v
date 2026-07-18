`timescale 1ns / 1ps


module fulladder_tb();
reg a,b,cin;
wire sum,carry;

fulladder dut(.a(a),.b(b),.cin(cin),.sum(sum),.carry(carry));

integer i;

initial begin
for(i=0;i<8;i=i+1)
begin
{a,b,cin}=i;
#10;
end
$finish;
end
endmodule
