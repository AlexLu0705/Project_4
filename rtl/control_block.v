// This block controls the signals required for proper datapath control for all instructions in the RISC-V ISA derived from the opcode
module control_block(
    input wire [2:0] counter,
    // 7-bit opcode from instruction word
    input wire [6:0] opcode,
    
    // 7-bit function
    input wire [6:0] func_7,

    // 3-bit function
    input wire [2:0] func_3,

    
    // ALU Signals -------------------------------------------

    // When asserted, addition operations should subtract instead.
    // This is only used for `i_opsel == 3'b000` (addition/subtraction).
    output wire i_sub,

    // When asserted, comparison operations should be treated as unsigned.
    // This is used for branch comparisons and set less than unsigned. For
    // b ranch operations, the ALU result is not used, only the comparison
    // results.
    output wire i_unsigned,

    // When asserted, right shifts should be treated as arithmetic instead of
    // logical. This is only used for `i_opsel == 3'b101` (shift right).
    output wire i_arith,


    // Register File Signals ---------------------------------

    // determines whether to write write to register file
    output wire reg_write,


    // Data Memory Signals -----------------------------------

    // determines whether to read from data memory
    output wire mem_read,

    // determines whether to write to data memory
    output wire mem_write,


    // Mux control signals -----------------------------------
    // determines whether or not instruction is branch or jump
    output wire branch_or_jump,

    // determines whether to take branch address
    output wire branch,

    // determines whether to drive signal from data memory or ALU
    output wire mem_to_reg,

    // determines whether instruction is AUIPC
    output wire AUIPC,

    // determines whether instruction is jump
    output wire jump,

    // determines whether instruction is JALR specifically
    output wire JALR,
    
    // determines whether to drive signal from read data 2 or immediate
    output wire ALU_src,

    // determines whether instruction is LUI
    output wire LUI,

    // Used for asserting the ebreak instruction for testing purposes
    output wire halt,

    // Operation Selection for ALU
    output wire [2:0] ALU_opsel

);

    assign AUIPC = (opcode == 7'b001_0111) ? 1 : 0;

    assign LUI = (opcode == 7'b011_0111) ? 1 : 0;

    assign halt = (opcode == 7'b111_0011) ? 1 : 0;

    // Checks if instruction is arithmetic, otherwise uses 0, which is add
    assign ALU_opsel = (opcode == 7'b011_0011 | opcode == 7'b001_0011) ? func_3 : 3'b000;

    // If not branch or store
    assign reg_write = ((opcode != 7'b010_0011) && (opcode != 7'b110_0011)) ? 1 : 0;

    // If load
    assign mem_read = (opcode == 7'b000_0011) ? 1 : 0;

    // If store
    assign mem_write = (opcode == 7'b010_0011) ? 1 : 0;

    // If branch
    assign branch = (opcode == 7'b110_0011) ? 1 : 0;

    // If load
    assign mem_to_reg = (opcode == 7'b000_0011) ? 1 : 0;

    // If jal or jalr
    assign jump = (opcode == 7'b110_1111 | opcode == 7'b110_0111) ? 1 : 0;

    assign branch_or_jump = (counter < 3) ? 1'b0 : (branch | jump) ? 1 : 0;

    assign JALR = (opcode == 7'b110_0111) ? 1 : 0;

    // If R-type, B-Type, else 0
    assign ALU_src = (opcode == 7'b011_0011 | opcode == 7'b110_0011) ? 1 : 0;

    assign i_sub = (opcode == 7'b011_0111 | opcode == 7'b001_0111) ? 0 :
            (func_7 == 7'b010_0000) ? 1 : 0;

    // If branch bltu or bgeu or func_3 is 011
    assign i_unsigned = ((opcode == 7'b110_0011 & (func_3 == 3'b110 | func_3 == 3'b111)) | func_3 == 3'b011) ? 1 : 0;

    assign i_arith = (func_7 == 7'b010_0000 & (opcode == 7'b011_0011 | opcode == 7'b001_0011)) ? 1 : 0;
endmodule