`default_nettype none


module address_aligner(
    // Function 3 for bit length of instruction
    input wire [2:0] func_3,

    // Address of value to be read/written to
    input wire [31:0] address,

    // mask for alignment, used by hart
    output wire [3:0] mask,

    output wire [31:0] aligned_address
);
    // 0 = word, 1 = half-word, 2 = byte
    reg [2:0] bit_length;
    assign bit_length = (func_3 == 3'b000 | func_3 == 3'b100) ? 3'b100 : // byte
                        (func_3 == 3'b001 | func_3 == 3'b101) ? 3'b010 : // half word
                        (func_3 == 3'b010) ? 3'b001 : // word
                        3'b001;


    assign mask = (bit_length == 3'b001) ? 4'b1111 :
                  (bit_length == 3'b010 && (address[3:0] == 4'h0 | address[3:0] == 4'h4 | address[3:0] == 4'h8 | address[3:0] == 4'hC)) ? 4'b0011 :   // lower half word
                  (bit_length == 3'b010 && (address[3:0] == 4'h2 | address[3:0] == 4'h6 | address[3:0] == 4'hA | address[3:0] == 4'hE)) ? 4'b1100 :   // upper half word
                  (bit_length == 3'b100 && (address[3:0] == 4'h0 | address[3:0] == 4'h4 | address[3:0] == 4'h8 | address[3:0] == 4'hC)) ? 4'b0001 :   // lowest byte
                  (bit_length == 3'b010 && (address[3:0] == 4'h1 | address[3:0] == 4'h5 | address[3:0] == 4'h9 | address[3:0] == 4'hD)) ? 4'b0010 :   // second lowest byte
                  (bit_length == 3'b010 && (address[3:0] == 4'h2 | address[3:0] == 4'h6 | address[3:0] == 4'hA | address[3:0] == 4'hE)) ? 4'b0100 :   // second highest byte
                  (bit_length == 3'b010 && (address[3:0] == 4'h3 | address[3:0] == 4'h7 | address[3:0] == 4'hB | address[3:0] == 4'hF)) ? 4'b1000 :
                   4'b1111;  // highest byte

    assign aligned_address = (address[3:0] == 4'h1 | address[3:0] == 4'h2 | address[3:0] == 4'h3) ? {address[31:4], 4'h0} :
                             (address[3:0] == 4'h5 | address[3:0] == 4'h6 | address[3:0] == 4'h7) ? {address[31:4], 4'h4} :
                             (address[3:0] == 4'h9 | address[3:0] == 4'hA | address[3:0] == 4'hB) ? {address[31:4], 4'h8} :
                             (address[3:0] == 4'hD | address[3:0] == 4'hE | address[3:0] == 4'hF) ? {address[31:4], 4'hC} :
                             address;

endmodule

`default_nettype wire