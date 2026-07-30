// 
// Module: top
// 
// Notes:
// - Top level module integrated with password_buffer
//

`timescale 1ns / 1ps

module top(
    input               clk     , // Top level system clock input.
    input               sw_0    , // Slide switches (Active-Low Reset).
    input               sw_1    , // Slide switches.
    input   wire        uart_rxd, // UART Recieve pin.
    output  wire        uart_txd, // UART transmit pin.
    output  wire [7:0]  led
);


    // Clock frequency in hertz.
    parameter CLK_HZ = 24000000;
    parameter BIT_RATE = 9600;
    parameter PAYLOAD_BITS = 8;
    
    // UART RX Wires
    wire [PAYLOAD_BITS-1:0]  uart_rx_data;
    wire        uart_rx_valid;
    wire        uart_rx_break;

    // UART TX Wires
    wire        uart_tx_busy;
    wire [PAYLOAD_BITS-1:0]  uart_tx_data;
    wire        uart_tx_en;

    // --- NEW: Password Buffer Wires ---
    wire        password_ready;
    wire [127:0] password;
    wire [4:0]  password_length;

    reg  [7:0]  led_reg;
    assign      led = led_reg;

    // ------------------------------------------------------------------------- 
    // UART Transmitter - Disabled for now until Comparator is built
    // ------------------------------------------------------------------------- 
    assign uart_tx_data = 8'd0;
    assign uart_tx_en   = 1'b0;

    // ------------------------------------------------------------------------- 
    // LED Debug Logic
    // ------------------------------------------------------------------------- 
    always @(posedge clk) begin
        if(!sw_0) begin
            led_reg <= 8'h00; // Start at 00, not f0
        end else if(password_ready) begin
            // Turn all LEDs ON when ENTER is pressed
            led_reg <= 8'hFF;
        end else begin
            // Show the current number of typed characters in binary
            led_reg <= {3'b000, password_length}; 
        end
    end

    // ------------------------------------------------------------------------- 
    // UART RX
    // ------------------------------------------------------------------------- 
    uart_rx #(
        .BIT_RATE(BIT_RATE),
        .PAYLOAD_BITS(PAYLOAD_BITS),
        .CLK_HZ  (CLK_HZ  )
    ) i_uart_rx(
        .clk          (clk          ), // Top level system clock input.
        .resetn       (sw_0         ), // Asynchronous active low reset.
        .uart_rxd     (uart_rxd     ), // UART Recieve pin.
        .uart_rx_en   (1'b1         ), // Recieve enable
        .uart_rx_break(uart_rx_break), // Did we get a BREAK message?
        .uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
        .uart_rx_data (uart_rx_data )  // The recieved data.
    );

    // ------------------------------------------------------------------------- 
    // Password Buffer Instance (NEW)
    // ------------------------------------------------------------------------- 
    password_buffer #(
        .MAX_LEN(16)
    ) i_password_buffer (
        .clk(clk),
        .rst(~sw_0),                 // Buffer expects active-high reset, sw_0 is active-low
        .rx_data(uart_rx_data),      // Feed UART RX data into buffer
        .rx_done(uart_rx_valid),     // Trigger on valid UART RX pulse
        .password_ready(password_ready),
        .password(password),
        .password_length(password_length)
    );

    // ------------------------------------------------------------------------- 
    // UART Transmitter module.
    // ------------------------------------------------------------------------- 
    uart_tx #(
        .BIT_RATE(BIT_RATE),
        .PAYLOAD_BITS(PAYLOAD_BITS),
        .CLK_HZ  (CLK_HZ  )
    ) i_uart_tx(
        .clk          (clk          ),
        .resetn       (sw_0         ),
        .uart_txd     (uart_txd     ),
        .uart_tx_en   (uart_tx_en   ),
        .uart_tx_busy (uart_tx_busy ),
        .uart_tx_data (uart_tx_data ) 
    );

endmodule