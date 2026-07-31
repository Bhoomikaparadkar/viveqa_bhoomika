`timescale 1ns / 1ps

module sha256_wrapper(
    input wire clk,
    input wire rst,
    
    // Inputs from the password_buffer
    input wire password_ready,
    input wire [127:0] password,
    input wire [4:0] password_length,

    // Outputs to the comparator
    output wire [255:0] hash_out,
    output wire hash_valid
);

    //-----------------------------------------------------
    // 1. Padding Logic: Create the 512-bit block
    //-----------------------------------------------------
    reg [511:0] padded_block;
    
    always @(*) begin
        // Start by filling the entire 512-bit block with zeros
        padded_block = 512'd0;
        
        // The last 64 bits must contain the length of the password in BITS.
        // Since each character is 8 bits (1 byte), we multiply length by 8.
        padded_block[63:0] = {59'd0, password_length, 3'd0}; // Equivalent to password_length * 8
        
        // Insert the password and the required '0x80' padding byte directly after it
        case(password_length)
            1:  padded_block[511:496] = {password[127:120], 8'h80};
            2:  padded_block[511:488] = {password[127:112], 8'h80};
            3:  padded_block[511:480] = {password[127:104], 8'h80};
            4:  padded_block[511:472] = {password[127:96],  8'h80};
            5:  padded_block[511:464] = {password[127:88],  8'h80};
            6:  padded_block[511:456] = {password[127:80],  8'h80};
            7:  padded_block[511:448] = {password[127:72],  8'h80};
            8:  padded_block[511:440] = {password[127:64],  8'h80};
            9:  padded_block[511:432] = {password[127:56],  8'h80};
            10: padded_block[511:424] = {password[127:48], 8'h80};
            11: padded_block[511:416] = {password[127:40], 8'h80};
            12: padded_block[511:408] = {password[127:32], 8'h80};
            13: padded_block[511:400] = {password[127:24], 8'h80};
            14: padded_block[511:392] = {password[127:16], 8'h80};
            15: padded_block[511:384] = {password[127:8],  8'h80};
            16: padded_block[511:376] = {password[127:0],  8'h80};
            default: padded_block[511:496] = {8'h80, 8'h00}; // If length is 0 (Just Enter pressed)
        endcase
    end

    //-----------------------------------------------------
    // 2. Instantiate the Secworks SHA-256 Core
    //-----------------------------------------------------
    wire core_ready;

    sha256_core core_inst (
        .clk(clk),
        .reset_n(~rst),           // The secworks core uses an active-low reset, so we invert your active-high 'rst'
        .init(password_ready),    // Trigger the core when the buffer says Enter was pressed
        .next(1'b0),              // We only ever send one block, so next is always 0
        .mode(1'b1),              // Mode 1 sets the engine to SHA-256 instead of SHA-224
        .block(padded_block),     // Feed it our perfectly formatted 512-bit block
        
        .ready(core_ready),       
        .digest(hash_out),        // The final 256-bit hash
        .digest_valid(hash_valid) // Flag that tells the comparator the hash is ready
    );

endmodule