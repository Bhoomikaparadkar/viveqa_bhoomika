`timescale 1ns / 1ps

module seg_counter_4digit(
    input  wire clk_24mhz,
    output reg  seg_cs  = 1,
    output reg  seg_clk = 0,
    output reg  seg_din = 0
);

    //---------------------------------------------------------
    // 1 MHz SPI Tick
    //---------------------------------------------------------
    reg [4:0] div = 0;
    wire tick = (div == 23);

    always @(posedge clk_24mhz)
    begin
        if(tick)
            div <= 0;
        else
            div <= div + 1;
    end

    //---------------------------------------------------------
    // 1-Second Counter
    //---------------------------------------------------------
    reg [24:0] sec_cnt = 0;
    reg [13:0] number = 0;     // Counts 0-9999

    always @(posedge clk_24mhz)
    begin
        if(sec_cnt == 24_000_000-1)
        begin
            sec_cnt <= 0;

            if(number == 9999)
                number <= 0;
            else
                number <= number + 1;
        end
        else
            sec_cnt <= sec_cnt + 1;
    end

    //---------------------------------------------------------
    // Convert Binary Number to Decimal Digits
    //---------------------------------------------------------
    wire [3:0] ones;
    wire [3:0] tens;
    wire [3:0] hundreds;
    wire [3:0] thousands;

    assign ones      = number % 10;
    assign tens      = (number / 10) % 10;
    assign hundreds  = (number / 100) % 10;
    assign thousands = (number / 1000) % 10;

    //---------------------------------------------------------
    // SPI FSM
    //---------------------------------------------------------
    reg [5:0] state = 0;
    reg [15:0] shift = 0;
    reg [2:0] cmd = 0;

    always @(posedge clk_24mhz)
    begin
        if(tick)
        begin

            if(state == 0)
            begin
                seg_cs  <= 0;
                seg_clk <= 0;

                case(cmd)

                    // Initialization
                    3'd0: shift <= 16'h0C01; // Normal operation
                    3'd1: shift <= 16'h09FF; // Code-B decode
                    3'd2: shift <= 16'h0A08; // Intensity
                    3'd3: shift <= 16'h0B03; // Scan limit = 4 digits

                    // Digits
                    3'd4: shift <= {8'h01,4'h0,ones};
                    3'd5: shift <= {8'h02,4'h0,tens};
                    3'd6: shift <= {8'h03,4'h0,hundreds};
                    3'd7: shift <= {8'h04,4'h0,thousands};

                endcase

                state <= 1;
            end

            else if(state <= 32)
            begin
                if(state[0])
                begin
                    seg_din <= shift[15];
                    seg_clk <= 0;
                end
                else
                begin
                    seg_clk <= 1;
                    shift <= {shift[14:0],1'b0};
                end

                state <= state + 1;
            end

            else
            begin
                seg_cs  <= 1;
                seg_clk <= 0;

                if(cmd == 7)
                    cmd <= 4;
                else
                    cmd <= cmd + 1;

                state <= 0;
            end
        end
    end

endmodule