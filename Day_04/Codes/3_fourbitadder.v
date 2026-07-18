`timescale 1ns / 1ps
module fourbitadder(a,b,m,sum,carry);
input [3:0]a,b;
input m;
output [3:0]sum;
output carry;
wire c1,c2,c3;
wire b0,b1,b2,b3;
xor(b0,b[0],m);
xor(b1,b[1],m);
xor(b2,b[2],m);
xor(b3,b[3],m);
fulladder fa1(a[0],b0,m,sum[0],c1);
fulladder fa2(a[1],b1,c1,sum[1],c2);
fulladder fa3(a[2],b2,c2,sum[2],c3);
fulladder fa4(a[3],b3,c3,sum[3],carry);
endmodule
