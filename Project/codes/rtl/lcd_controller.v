`timescale 1ns / 1ps

module lcd_controller (
    input  wire       clk_24mhz,
    input  wire       rst,
    input  wire       hash_valid,
    input  wire       hash_match, // 1 if password is correct, 0 if wrong

    output reg        lcd_rs,
    output wire       lcd_rw,
    output reg        lcd_en,
    output reg  [7:0] lcd_d
);

    // Write-only mode for LCD
    assign lcd_rw = 1'b0; 

    // Prompt Message (Displayed on Boot/Reset)
    wire [127:0] msg_rdy1 = "Enter Password: "; // 16 characters
    wire [127:0] msg_rdy2 = "                "; // Blank line 2

    // Authentication Status Messages (Displayed after pressing Enter)
    wire [127:0] msg_row1 = "Auth Status:    ";
    wire [127:0] msg_pass = "ACCESS GRANTED  ";
    wire [127:0] msg_fail = "ACCESS DENIED   ";

    // Timing constants for 24 MHz Clock
    localparam DELAY_20MS = 20 * 24000;
    localparam DELAY_2MS  = 2  * 24000;
    localparam DELAY_50US = 50 * 24;

    // FSM States
    localparam S_START       = 0;
    localparam S_INIT_1      = 1;
    localparam S_INIT_2      = 2;
    localparam S_INIT_3      = 3;
    localparam S_INIT_4      = 4;

    // Boot Prompt Message States
    localparam S_RDY_ROW1    = 5;
    localparam S_WR_RDY_ROW1 = 6;
    localparam S_RDY_ROW2    = 7;
    localparam S_WR_RDY_ROW2 = 8;

    // Verification Display States
    localparam S_IDLE        = 9;
    localparam S_SET_ROW1    = 10;
    localparam S_WRITE_ROW1  = 11;
    localparam S_SET_ROW2    = 12;
    localparam S_WRITE_ROW2  = 13;
    localparam S_DONE        = 14;

    // Sub-states for pulsing the EN pin
    localparam S_PULSE_HIGH  = 20;
    localparam S_PULSE_LOW   = 21;
    localparam S_DELAY       = 22;

    reg [5:0]  state;
    reg [5:0]  return_state;
    reg [23:0] timer;
    reg [23:0] timer_target;
    reg [4:0]  char_idx;
    reg [7:0]  data_buffer;
    reg        rs_buffer;

    always @(posedge clk_24mhz) begin
        if (rst) begin
            state        <= S_START;
            lcd_rs       <= 0;
            lcd_en       <= 0;
            lcd_d        <= 0;
            char_idx     <= 0;
            timer        <= 0;
        end else begin
            case (state)
                S_START: begin
                    // Wait 20ms for LCD power-up
                    timer_target <= DELAY_20MS;
                    return_state <= S_INIT_1;
                    state        <= S_DELAY;
                end

                // --- Initialization Sequence ---
                S_INIT_1: begin
                    data_buffer  <= 8'h38; // 8-bit mode, 2 lines, 5x8 font
                    rs_buffer    <= 0;     // Command
                    timer_target <= DELAY_2MS;
                    return_state <= S_INIT_2;
                    state        <= S_PULSE_HIGH;
                end
                S_INIT_2: begin
                    data_buffer  <= 8'h0C; // Display ON, Cursor OFF
                    rs_buffer    <= 0;
                    timer_target <= DELAY_2MS;
                    return_state <= S_INIT_3;
                    state        <= S_PULSE_HIGH;
                end
                S_INIT_3: begin
                    data_buffer  <= 8'h01; // Clear Display
                    rs_buffer    <= 0;
                    timer_target <= DELAY_2MS;
                    return_state <= S_INIT_4;
                    state        <= S_PULSE_HIGH;
                end
                S_INIT_4: begin
                    data_buffer  <= 8'h06; // Entry Mode: Increment
                    rs_buffer    <= 0;
                    timer_target <= DELAY_2MS;
                    return_state <= S_RDY_ROW1; // Jump to prompt message display
                    state        <= S_PULSE_HIGH;
                end

                // --- Write Boot Prompt ("Enter Password:") ---
                S_RDY_ROW1: begin
                    data_buffer  <= 8'h80; // Row 1
                    rs_buffer    <= 0;     // Command
                    timer_target <= DELAY_2MS;
                    return_state <= S_WR_RDY_ROW1;
                    state        <= S_PULSE_HIGH;
                end
                S_WR_RDY_ROW1: begin
                    data_buffer  <= msg_rdy1[((15 - char_idx) * 8) +: 8];
                    rs_buffer    <= 1;     // Data
                    timer_target <= DELAY_50US;
                    if (char_idx == 15) begin
                        return_state <= S_RDY_ROW2;
                        char_idx     <= 0;
                    end else begin
                        return_state <= S_WR_RDY_ROW1;
                        char_idx     <= char_idx + 1;
                    end
                    state <= S_PULSE_HIGH;
                end
                S_RDY_ROW2: begin
                    data_buffer  <= 8'hC0; // Row 2
                    rs_buffer    <= 0;     // Command
                    timer_target <= DELAY_2MS;
                    return_state <= S_WR_RDY_ROW2;
                    state        <= S_PULSE_HIGH;
                end
                S_WR_RDY_ROW2: begin
                    data_buffer  <= msg_rdy2[((15 - char_idx) * 8) +: 8];
                    rs_buffer    <= 1;     // Data
                    timer_target <= DELAY_50US;
                    if (char_idx == 15) begin
                        return_state <= S_IDLE;
                        char_idx     <= 0;
                    end else begin
                        return_state <= S_WR_RDY_ROW2;
                        char_idx     <= char_idx + 1;
                    end
                    state <= S_PULSE_HIGH;
                end

                // --- Wait for Password Hash ---
                S_IDLE: begin
                    if (hash_valid) begin
                        state    <= S_SET_ROW1;
                        char_idx <= 0;
                    end
                end

                // --- Write Row 1 ("Auth Status: ") ---
                S_SET_ROW1: begin
                    data_buffer  <= 8'h80; // DDRAM Address 0x00 (Row 1)
                    rs_buffer    <= 0;     // Command
                    timer_target <= DELAY_2MS;
                    return_state <= S_WRITE_ROW1;
                    state        <= S_PULSE_HIGH;
                end
                S_WRITE_ROW1: begin
                    data_buffer  <= msg_row1[((15 - char_idx) * 8) +: 8];
                    rs_buffer    <= 1; // Data
                    timer_target <= DELAY_50US;

                    if (char_idx == 15) begin
                        return_state <= S_SET_ROW2;
                        char_idx     <= 0;
                    end else begin
                        return_state <= S_WRITE_ROW1;
                        char_idx     <= char_idx + 1;
                    end
                    state <= S_PULSE_HIGH;
                end

                // --- Write Row 2 ("ACCESS GRANTED" / "ACCESS DENIED") ---
                S_SET_ROW2: begin
                    data_buffer  <= 8'hC0; // DDRAM Address 0x40 (Row 2)
                    rs_buffer    <= 0;     // Command
                    timer_target <= DELAY_2MS;
                    return_state <= S_WRITE_ROW2;
                    state        <= S_PULSE_HIGH;
                end
                S_WRITE_ROW2: begin
                    if (hash_match)
                        data_buffer <= msg_pass[((15 - char_idx) * 8) +: 8];
                    else
                        data_buffer <= msg_fail[((15 - char_idx) * 8) +: 8];

                    rs_buffer    <= 1; // Data
                    timer_target <= DELAY_50US;

                    if (char_idx == 15) begin
                        return_state <= S_DONE;
                    end else begin
                        return_state <= S_WRITE_ROW2;
                        char_idx     <= char_idx + 1;
                    end
                    state <= S_PULSE_HIGH;
                end

                S_DONE: begin
                    if (hash_valid) begin
                        state    <= S_SET_ROW1;
                        char_idx <= 0;
                    end
                end

                // --- Shared Pulse Sub-Routines ---
                S_PULSE_HIGH: begin
                    lcd_rs <= rs_buffer;
                    lcd_d  <= data_buffer;
                    lcd_en <= 1;
                    state  <= S_PULSE_LOW;
                end
                S_PULSE_LOW: begin
                    lcd_en <= 0;
                    timer  <= 0;
                    state  <= S_DELAY;
                end
                S_DELAY: begin
                    if (timer >= timer_target) begin
                        state <= return_state;
                    end else begin
                        timer <= timer + 1;
                    end
                end

                default: state <= S_START;
            endcase
        end
    end
endmodule