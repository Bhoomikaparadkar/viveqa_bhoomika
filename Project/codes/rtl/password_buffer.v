`timescale 1ns / 1ps

module password_buffer #(
    parameter MAX_LEN = 16
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 rx_done,
    input  wire [7:0]           rx_data,

    output reg  [(MAX_LEN*8)-1:0] password,
    output reg  [4:0]            password_length,
    output reg                 password_ready
);

    reg [7:0] buffer [0:MAX_LEN-1];
    reg       clear_on_next_char;
    integer   i;

    always @(posedge clk) begin
        if (rst) begin
            password_ready     <= 1'b0;
            password_length    <= 5'd0;
            password           <= {MAX_LEN*8{1'b0}};
            clear_on_next_char <= 1'b0;
            for (i = 0; i < MAX_LEN; i = i + 1)
                buffer[i] <= 8'd0;
        end else begin
            password_ready <= 1'b0;

            if (rx_done) begin
                // 1. ENTER Pressed (0x0D or 0x0A)
                if (rx_data == 8'h0D || rx_data == 8'h0A) begin
                    // Only trigger if we typed data AND haven't triggered yet for this press
                    if (password_length > 0 && !clear_on_next_char) begin
                        for (i = 0; i < MAX_LEN; i = i + 1)
                            password[(MAX_LEN-1-i)*8 +: 8] <= buffer[i];

                        password_ready     <= 1'b1;
                        clear_on_next_char <= 1'b1; // Ignore secondary 0x0A bytes
                    end
                end
                
                // 2. BACKSPACE Pressed (0x08 or 0x7F)
                else if (rx_data == 8'h08 || rx_data == 8'h7F) begin
                    if (clear_on_next_char) begin
                        password_length    <= 5'd0;
                        clear_on_next_char <= 1'b0;
                        for (i = 0; i < MAX_LEN; i = i + 1)
                            buffer[i] <= 8'd0;
                    end else if (password_length > 0) begin
                        password_length           <= password_length - 1'b1;
                        buffer[password_length-1] <= 8'd0;
                    end
                end

                // 3. Printable Character Input
                else begin
                    if (clear_on_next_char) begin
                        // Wipes old password automatically when typing a new one
                        buffer[0]          <= rx_data;
                        password_length    <= 5'd1;
                        clear_on_next_char <= 1'b0;
                        for (i = 1; i < MAX_LEN; i = i + 1)
                            buffer[i] <= 8'd0;
                    end else if (password_length < MAX_LEN) begin
                        buffer[password_length] <= rx_data;
                        password_length         <= password_length + 1'b1;
                    end
                end
            end
        end
    end

endmodule