`timescale 1ns / 1ps
module fourbitadder_sub_tb();
reg [3:0]a,b;
reg m;
wire [3:0]sum;
wire carry;
fourbitadder dut(a,b,m,sum,carry);
initial begin
m=1'b0;a=4'd1;b=4'd2;
#10 m=1'b1;a=4'd5;b=4'd5;
#10  m=1'b0;a=4'd0;b=4'd15;
#10 a=4'd15;b=4'd15;
#10 a=4'd5;b=4'd9;
#10 a=4'd10;b=4'd0;
#10 a=4'd5;b=4'd7;
#10 $finish;
end

initial begin
$monitor("Mode=%b A=%d B=%d Result=%d Carry=%b",m,a,b,sum,carry);
end

endmodule
