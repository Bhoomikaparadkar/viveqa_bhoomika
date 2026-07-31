`timescale 1ns / 1ps

module uart_rx #(
    parameter CLKS_PER_BIT = 2500,
    parameter PARITY_EN    = 0,
    parameter PARITY_TYPE  = 0      //0 = Even, 1 = Odd
)(
    input wire clk,
input wire rst,
input wire rx,

output reg [7:0] rx_data,
output reg rx_done,
output reg parity_err,
output reg frame_err
);

localparam S_IDLE   = 3'd0;
localparam S_START  = 3'd1;
localparam S_DATA   = 3'd2;
localparam S_PARITY = 3'd3;
localparam S_STOP   = 3'd4;

reg [2:0] state;

reg [2:0] bit_idx;
reg [7:0] data_reg;

reg parity_calc;
reg parity_sample;

reg [$clog2(CLKS_PER_BIT)-1:0] baud_cnt;

localparam HALF_BIT = CLKS_PER_BIT/2;

reg rx_sync1, rx_sync2;

always @(posedge clk)
begin
    if(rst)
    begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end
    else
    begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
end

wire rx_in = rx_sync2;

always @(posedge clk)
begin

    if(rst)
    begin
        state <= S_IDLE;

        baud_cnt <= 0;
        bit_idx <= 0;

        data_reg <= 0;
        rx_data <= 0;

        rx_done <= 0;
        parity_err <= 0;
        frame_err <= 0;

        parity_calc <= 0;
        parity_sample <= 0;
    end

    else
    begin

        rx_done <= 1'b0;

        case(state)

        //--------------------------------------------------
        S_IDLE:
        begin
            baud_cnt <= 0;
            bit_idx <= 0;
            parity_calc <= 0;

            if(rx_in==0)
                state <= S_START;
        end

        //--------------------------------------------------
        S_START:
        begin

            if(baud_cnt == HALF_BIT-1)
            begin
                baud_cnt <= 0;

                if(rx_in==0)
                    state <= S_DATA;
                else
                    state <= S_IDLE;
            end
            else
                baud_cnt <= baud_cnt + 1;

        end

        //--------------------------------------------------
        S_DATA:
        begin

            if(baud_cnt == CLKS_PER_BIT-1)
            begin

                baud_cnt <= 0;

                data_reg[bit_idx] <= rx_in;
                parity_calc <= parity_calc ^ rx_in;

                if(bit_idx==7)
                begin

                    bit_idx <= 0;

                    if(PARITY_EN)
                        state <= S_PARITY;
                    else
                        state <= S_STOP;

                end
                else
                    bit_idx <= bit_idx + 1;

            end
            else
                baud_cnt <= baud_cnt + 1;

        end

        //--------------------------------------------------
        S_PARITY:
        begin

            if(baud_cnt == CLKS_PER_BIT-1)
            begin

                baud_cnt <= 0;

                parity_sample <= rx_in;

                if(PARITY_TYPE)
                    parity_err <= (rx_in != ~parity_calc);
                else
                    parity_err <= (rx_in != parity_calc);

                state <= S_STOP;

            end
            else
                baud_cnt <= baud_cnt + 1;

        end

        //--------------------------------------------------
        S_STOP:
        begin

            if(baud_cnt == CLKS_PER_BIT-1)
            begin

                baud_cnt <= 0;

                rx_data <= data_reg;

                frame_err <= (rx_in != 1'b1);

                rx_done <= 1'b1;

                state <= S_IDLE;

            end
            else
                baud_cnt <= baud_cnt + 1;

        end

        default:
            state <= S_IDLE;

        endcase

    end

end

endmodule