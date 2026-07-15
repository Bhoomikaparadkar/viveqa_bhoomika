module full_adder(input a, input b, input cin, output sum, output
 cout);

 assign sum = a ^ b ^ cin;
 assign cout = (a & b) | (b & cin) | (cin & a);
  endmodule
module full_adder_tb;
 reg a, b, cin;
 
 wire sum, cout;
 integer i;
 full_adder dut(a, b, cin, sum, cout);
 initial begin
 for (i = 0; i < 8; i = i + 1) begin
 {a, b, cin} = i;
 #10;
 end
 $finish;
 end
 endmodule