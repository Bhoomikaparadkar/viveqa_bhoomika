`timescale 1ns / 1ps


module uart_tx#(parameter CLKS_PER_BIT=2500,
                parameter PARITY_EN=1,
                parameter PARITY_TYPE=0)//0 even/1 odd
(clk,rst,tx_start,tx_data,tx,tx_busy,tx_done);

input wire clk,rst;
input wire  tx_start;
input [7:0]tx_data;
output reg tx,tx_busy,tx_done;

//state encoding
localparam S_IDLE=3'd0,S_START=3'd1,S_DATA=3'd2,
           S_PARITY=3'd3,S_STOP=3'd4;

//to hold current state
reg [2:0]state;
reg [2:0]bit_idx; //used for shifting the bits
reg [7:0]tx_shift; //register used to shift data
reg parity_bit;//used to compute the parity
reg [$clog2(CLKS_PER_BIT):0]baud_cnt;

always@(posedge clk)begin
      if(rst)begin
	state <=S_IDLE;
        tx <=1'b1;
        tx_busy <=1'b0;
        tx_done <=1'b0;
        baud_cnt <=0;
        bit_idx <=0;
        tx_shift <=0;
        parity_bit <=1'b0;
      end else begin
        tx_done <=1'b0; //Pulse (asserted in stop state)
        case (state)
	S_IDLE:begin
               tx <=1'b1;
               tx_busy <=1'b0;
               baud_cnt <=0;
               bit_idx <=0;
               if(tx_start)begin
                  tx_shift <= tx_data;
                  parity_bit <=PARITY_TYPE?~^tx_data:^tx_data;
                  tx_busy <=1'b1;
                  state <=S_START;
               end
end

       S_START:begin
               tx <=1'b0;
               if(baud_cnt==CLKS_PER_BIT-1)begin
                  baud_cnt <=0;
                  state <=S_DATA;
               end else baud_cnt<=baud_cnt+1;
       end
       
       S_DATA:begin
              tx <=tx_shift[bit_idx];
             if(baud_cnt==CLKS_PER_BIT-1)begin
                  baud_cnt <=0;
                  if(bit_idx==7)begin
                    bit_idx<=0;
                    state <= PARITY_EN?S_PARITY:S_STOP;
                  end else bit_idx<=bit_idx+1;
               end else baud_cnt<=baud_cnt+1;
        end
                        
        S_PARITY: begin
               tx<=parity_bit;
               if(baud_cnt==CLKS_PER_BIT-1)begin
                  baud_cnt <=0;
                  state <=S_STOP;
               end else baud_cnt<=baud_cnt+1;
        end
 
       S_STOP:begin
	      tx <=1'b1;
              if(baud_cnt==CLKS_PER_BIT-1)begin
                  baud_cnt <=0;
                  tx_busy <=1'b0;
		  tx_done <=1'b1;
                  state <=S_IDLE;
               end else baud_cnt<=baud_cnt+1;
       end
 
       default: state <=S_IDLE;

       endcase
       end
end
endmodule