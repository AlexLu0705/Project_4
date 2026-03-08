`default_nettype none

// This decoder takes the full instruction word as input and outputs the instruction type/format as specified by the instruction in a one hot encoded format
module instruction_type_decoder(
    // opcode
    input wire [6:0] opcode,

    // Instruction format, determined by the instruction decoder based on the
    // opcode. This is one-hot encoded according to the following format:
    // [0] R-type
    // [1] I-type
    // [2] S-type
    // [3] B-type
    // [4] U-type
    // [5] J-type
    output wire [5:0] instruction_format
);

    assign instruction_format = (opcode == 7'b011_0011) ? 6'b00_0001 : // R-type
                                (opcode == 7'b001_0011 | opcode == 7'b000_0011 | opcode == 7'b110_0111) ? 6'b00_0010 : // I-type
                                (opcode == 7'b010_0011) ? 6'b00_0100 : // S-type
                                (opcode == 7'b110_0011) ? 6'b00_1000 : // B-type
                                (opcode == 7'b011_0111 | opcode == 7'b001_0111) ? 6'b01_0000 : // U-type
                                6'b10_0000; // J-type
endmodule

`default_nettype wire