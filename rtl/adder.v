`default_nettype none

// Simple adder, used calculating branch address and incrementing PC. Logic for arithmetic overflow is not included
module adder(
    // Operands
    input wire [31:0] operand_1,
    input wire [31:0] operand_2,

    // Output wire to driving result
    output wire [31:0] result
);

    // Intermediate wires to calculate correct 2's complement value
    wire [31:0] twos_complement_operand_1;
    wire [31:0] twos_complement_operand_2;

    assign twos_complement_operand_1 = operand_1[31] ? ((~operand_1) + 1) : operand_1;
    assign twos_complement_operand_2 = operand_2[31] ? ((~operand_2) + 1) : operand_2;

    assign result = twos_complement_operand_1 + twos_complement_operand_2;

endmodule

`default_nettype wire