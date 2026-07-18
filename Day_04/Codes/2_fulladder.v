`timescale 1ns / 1ps

module fulladder(a,b,cin,sum,carry);
input a,b,cin;
output sum,carry;
wire sum1,carry1,carry2;
halfadder ha1(a,b,sum1,carry1);
halfadder ha2(sum1,cin,sum,carry2);
or(carry,carry1,carry2);
//assign carry=carry1|carry2;
endmodule
