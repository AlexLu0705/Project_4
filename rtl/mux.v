`default_nettype none

// Simple mux selector, used for control logic in procesor implementation
module mux(
    // Operands
    input wire [31:0] operand_0,
    input wire [31:0] operand_1,

    // Select signal to choose between operands
    input wire select,
    
    // Output wire to driving operand selected
    output wire [31:0] result
);

    assign result = select ? operand_1 : operand_0;

endmodule

`default_nettype wire