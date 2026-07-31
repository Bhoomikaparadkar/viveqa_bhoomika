module padding #(
    parameter MAX_LEN = 16
)(
    input  wire [8*MAX_LEN-1:0] password,
    input  wire [4:0]           length,
    output reg  [511:0]         block
);

integer i;
integer bit_len;

always @(*) begin

    block = 512'd0;

    // Copy password bytes
    for(i = 0; i < MAX_LEN; i = i + 1) begin
        if(i < length)
            block[511-(i*8)-:8] = password[8*(MAX_LEN-1-i)+:8];
    end

    // Append 0x80
    block[511-(length*8)-:8] = 8'h80;

    // Message length in bits
    bit_len = length * 8;

    block[63:0] = bit_len;

end

endmodule