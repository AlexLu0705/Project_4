module hart #(
    // After reset, the program counter (PC) should be initialized to this
    // address and start executing instructions from there.
    parameter RESET_ADDR = 32'h00000000
) (
    // Global clock.
    input  wire        i_clk,
    // Synchronous active-high reset.
    input  wire        i_rst,
    // Instruction fetch goes through a read only instruction memory (imem)
    // port. The port accepts a 32-bit address (e.g. from the program counter)
    // per cycle and combinationally returns a 32-bit instruction word. This
    // is not representative of a realistic memory interface; it has been
    // modeled as more similar to a DFF or SRAM to simplify phase 3. In
    // later phases, you will replace this with a more realistic memory.
    //
    // 32-bit read address for the instruction memory. This is expected to be
    // 4 byte aligned - that is, the two LSBs should be zero.
    output wire [31:0] o_imem_raddr,
    // Instruction word fetched from memory, available on the same cycle.
    input  wire [31:0] i_imem_rdata,
    // Data memory accesses go through a separate read/write data memory (dmem)
    // that is shared between read (load) and write (stored). The port accepts
    // a 32-bit address, read or write enable, and mask (explained below) each
    // cycle. Reads are combinational - values are available immediately after
    // updating the address and asserting read enable. Writes occur on (and
    // are visible at) the next clock edge.
    //
    // Read/write address for the data memory. This should be 32-bit aligned
    // (i.e. the two LSB should be zero). See `o_dmem_mask` for how to perform
    // half-word and byte accesses at unaligned addresses.
    output wire [31:0] o_dmem_addr,
    // When asserted, the memory will perform a read at the aligned address
    // specified by `i_addr` and return the 32-bit word at that address
    // immediately (i.e. combinationally). It is illegal to assert this and
    // `o_dmem_wen` on the same cycle.
    output wire        o_dmem_ren,
    // When asserted, the memory will perform a write to the aligned address
    // `o_dmem_addr`. When asserted, the memory will write the bytes in
    // `o_dmem_wdata` (specified by the mask) to memory at the specified
    // address on the next rising clock edge. It is illegal to assert this and
    // `o_dmem_ren` on the same cycle.
    output wire        o_dmem_wen,
    // The 32-bit word to write to memory when `o_dmem_wen` is asserted. When
    // write enable is asserted, the byte lanes specified by the mask will be
    // written to the memory word at the aligned address at the next rising
    // clock edge. The other byte lanes of the word will be unaffected.
    output wire [31:0] o_dmem_wdata,
    // The dmem interface expects word (32 bit) aligned addresses. However,
    // WISC-25 supports byte and half-word loads and stores at unaligned and
    // 16-bit aligned addresses, respectively. To support this, the access
    // mask specifies which bytes within the 32-bit word are actually read
    // from or written to memory.
    //
    // To perform a half-word read at address 0x00001002, align `o_dmem_addr`
    // to 0x00001000, assert `o_dmem_ren`, and set the mask to 0b1100 to
    // indicate that only the upper two bytes should be read. Only the upper
    // two bytes of `i_dmem_rdata` can be assumed to have valid data; to
    // calculate the final value of the `lh[u]` instruction, shift the rdata
    // word right by 16 bits and sign/zero extend as appropriate.
    //
    // To perform a byte write at address 0x00002003, align `o_dmem_addr` to
    // `0x00002000`, assert `o_dmem_wen`, and set the mask to 0b1000 to
    // indicate that only the upper byte should be written. On the next clock
    // cycle, the upper byte of `o_dmem_wdata` will be written to memory, with
    // the other three bytes of the aligned word unaffected. Remember to shift
    // the value of the `sb` instruction left by 24 bits to place it in the
    // appropriate byte lane.
    output wire [ 3:0] o_dmem_mask,
    // The 32-bit word read from data memory. When `o_dmem_ren` is asserted,
    // this will immediately reflect the contents of memory at the specified
    // address, for the bytes enabled by the mask. When read enable is not
    // asserted, or for bytes not set in the mask, the value is undefined.
    input  wire [31:0] i_dmem_rdata,
	// The output `retire` interface is used to signal to the testbench that
    // the CPU has completed and retired an instruction. A single cycle
    // implementation will assert this every cycle; however, a pipelined
    // implementation that needs to stall (due to internal hazards or waiting
    // on memory accesses) will not assert the signal on cycles where the
    // instruction in the writeback stage is not retiring.
    //
    // Asserted when an instruction is being retired this cycle. If this is
    // not asserted, the other retire signals are ignored and may be left invalid.
    output wire        o_retire_valid,
    // The 32 bit instruction word of the instrution being retired. This
    // should be the unmodified instruction word fetched from instruction
    // memory.
    output wire [31:0] o_retire_inst,
    // Asserted if the instruction produced a trap, due to an illegal
    // instruction, unaligned data memory access, or unaligned instruction
    // address on a taken branch or jump.
    output wire        o_retire_trap,
    // Asserted if the instruction is an `ebreak` instruction used to halt the
    // processor. This is used for debugging and testing purposes to end
    // a program.
    output wire        o_retire_halt,
    // The first register address read by the instruction being retired. If
    // the instruction does not read from a register (like `lui`), this
    // should be 5'd0.
    output wire [ 4:0] o_retire_rs1_raddr,
    // The second register address read by the instruction being retired. If
    // the instruction does not read from a second register (like `addi`), this
    // should be 5'd0.
    output wire [ 4:0] o_retire_rs2_raddr,
    // The first source register data read from the register file (in the
    // decode stage) for the instruction being retired. If rs1 is 5'd0, this
    // should also be 32'd0.
    output wire [31:0] o_retire_rs1_rdata,
    // The second source register data read from the register file (in the
    // decode stage) for the instruction being retired. If rs2 is 5'd0, this
    // should also be 32'd0.
    output wire [31:0] o_retire_rs2_rdata,
    // The destination register address written by the instruction being
    // retired. If the instruction does not write to a register (like `sw`),
    // this should be 5'd0.
    output wire [ 4:0] o_retire_rd_waddr,
    // The destination register data written to the register file in the
    // writeback stage by this instruction. If rd is 5'd0, this field is
    // ignored and can be treated as a don't care.
    output wire [31:0] o_retire_rd_wdata,
    // The current program counter of the instruction being retired - i.e.
    // the instruction memory address that the instruction was fetched from.
    output wire [31:0] o_retire_pc,
    // the next program counter after the instruction is retired. For most
    // instructions, this is `o_retire_pc + 4`, but must be the branch or jump
    // target for *taken* branches and jumps.
    output wire [31:0] o_retire_next_pc

`ifdef RISCV_FORMAL
    ,`RVFI_OUTPUTS,
`endif
);   

    // Program Counter (PC)
    reg [31:0] PC;
    

    // Intermediate wires control signals
    wire i_sub;
    wire i_unsigned;
    wire i_arith;
    wire reg_write;
    wire control_signal_branch;
    wire mem_to_reg;
    wire AUIPC;
    wire jump;
    wire LUI;
    wire [2:0] ALU_opsel;
    wire ALU_src;
    wire JALR;

    // Branch Control output wire
    wire branch;

    // Register File Input and Output Wires
    wire [31:0] write_not_jump;
    wire [31:0] write_back;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    // Immediate Decoder output wire
    wire [31:0] immediate_output;

    // Instruction Decoder output wire
    wire [5:0] instruction_format;

    // ALU input and output wires
    wire [31:0] alu_input_1;
    wire [31:0] alu_input_2;
    wire [31:0] alu_result;
    wire alu_eq;
    wire alu_slt;

    // Program Counter (PC) wire connections
    wire [31:0] PC_4;
    wire [31:0] PC_immediate;
    wire [31:0] PC_4_immediate;

    // Mux intermediate wires
    wire [31:0] LUI_AUIPC_intermediate;
    wire [31:0] branch_jump_intermediate;
    wire [31:0] jump_adder_immediate;

    wire [31:0] aligned_data;
    wire [3:0] mask;

    always @(posedge i_clk) begin
        if(i_rst) begin
            PC <= RESET_ADDR;
        end
        else begin
            PC <= o_retire_next_pc;
        end
    end

    //****************************** DECLARATION OF ALL MODULES AND SIGNAL CONNECTIONS *******************************//

    //---------------------------------------------Start of Register File---------------------------------------------//
    rf rf (
        .i_clk(i_clk), // clock
        .i_rst(i_rst), // reset
        .i_rs1_raddr(i_imem_rdata[19:15]), // read register 1, rs
        .i_rs2_raddr(i_imem_rdata[24:20]), // read register 2, rt
        .i_rd_wen(reg_write), // write enable
        .i_rd_waddr(i_imem_rdata[11:7]), // write register, rd
        .i_rd_wdata(write_back), // data to write to write register
        .o_rs1_rdata(read_data_1), // read data from register 1
        .o_rs2_rdata(read_data_2) // read data from register 2
    );
    //----------------------------------------------End of Register File----------------------------------------------//

    //---------------------------------------------Start of Control Block---------------------------------------------//
    control_block control_block (
        .opcode(i_imem_rdata[6:0]),
        .func_7(i_imem_rdata[31:25]),
        .func_3(i_imem_rdata[14:12]),
        .i_sub(i_sub), 
        .i_unsigned(i_unsigned),
        .i_arith(i_arith),
        .reg_write(reg_write),
        .mem_read(o_dmem_ren),
        .mem_write(o_dmem_wen),
        .branch(control_signal_branch),
        .mem_to_reg(mem_to_reg),
        .AUIPC(AUIPC),
        .jump(jump),
        .LUI(LUI),
        .ALU_src(ALU_src),
        .halt(o_retire_halt),
        .ALU_opsel(ALU_opsel),
        .JALR(JALR)
    );
    //---------------------------------------------End of Control Block----------------------------------------------//

    //---------------------------------------Start of Instruction-Type Decoder---------------------------------------//
    instruction_type_decoder instruction_type_decoder (
        .opcode(i_imem_rdata[6:0]),
        .instruction_format(instruction_format)
    );
    //-----------------------------------------End of Instruction-Type Decoder----------------------------------------//

    //-------------------------------------------Start of Immediate Decoder-------------------------------------------//
    imm imm (
        .i_inst(i_imem_rdata),
        .i_format(instruction_format),
        .o_immediate(immediate_output)
    );
    //-------------------------------------------End of Immediate Decoder--------------------------------------------//

    //--------------------------------------------Start of Branch Control--------------------------------------------//
    branch_control branch_control (
        .zero(alu_eq),
        .slt(alu_slt),
        .control_signal_branch(control_signal_branch),
        .func_3(i_imem_rdata[14:12]),
        .branch(branch)
    );
    //---------------------------------------------End of Branch ControlL---------------------------------------------//

    //--------------------------------------------------Start of ALU--------------------------------------------------//
    alu alu (
        .i_opsel(ALU_opsel),
        .i_sub(i_sub),
        .i_unsigned(i_unsigned),
        .i_arith(i_arith),
        .i_op1(alu_input_1),
        .i_op2(alu_input_2),
        .o_result(alu_result),
        .o_eq(alu_eq),
        .o_slt(alu_slt)
    );
    //---------------------------------------------------End of ALU--------------------------------------------------//

    //-------------------------------------------------Start of Adder------------------------------------------------//
    // PC + 4 adder
    adder adder_PC (
        .operand_1(PC), // PC address
        .operand_2(32'h0000_0004), // 4
        .result(PC_4)
    );

    // PC + 4 + Immediate for jump
    adder adder_jump (
        .operand_1(jump_adder_immediate), 
        .operand_2(immediate_output), 
        .result(PC_4_immediate)
    );

    // PC + Immediate
    adder adder_branch (
        .operand_1(PC), 
        .operand_2(immediate_output), 
        .result(PC_immediate)
    );
    //-------------------------------------------------End of Adder-------------------------------------------------//

    //-------------------------------------------------Start of Mux-------------------------------------------------//

    // Determines whether instruction is LUI
    mux mux_LUI (
        .operand_1(32'h0000_0000),
        .operand_0(read_data_1),
        .select(LUI),
        .result(LUI_AUIPC_intermediate)
    );

    // Determines whether to use PC or read data 1 to use as ALU input 1
    mux mux_AUIPC (
        .operand_1(PC),
        .operand_0(LUI_AUIPC_intermediate),
        .select(AUIPC),
        .result(alu_input_1)
    );

    // Determines whether to use immediate or read data 2 to use as ALU input 2
    mux mux_ALUSrc (
        .operand_1(read_data_2),
        .operand_0(immediate_output),
        .select(ALU_src),
        .result(alu_input_2)
    );

    // Determines data to write back to register
    mux mux_mem_to_reg (
        .operand_1(aligned_data),
        .operand_0(alu_result),
        .select(mem_to_reg),
        .result(write_not_jump)
    );

    // Determines branch address or next instruction to jump to
    mux mux_branch (
        .operand_1(PC_immediate),
        .operand_0(PC_4),
        .select(branch),
        .result(branch_jump_intermediate)
    );

    // Determines address to write to PC
    mux mux_jump (
        .operand_1(PC_4_immediate),
        .operand_0(branch_jump_intermediate),
        .select(jump),
        .result(o_retire_next_pc)
    );

    // Determines address to write to PC
    mux mux_jump_write (
        .operand_1(PC_4),
        .operand_0(write_not_jump),
        .select(jump),
        .result(write_back)
    );

    mux mux_JALR (
        .operand_1(read_data_1),
        .operand_0(PC_4),
        .select(JALR),
        .result(jump_adder_immediate)
    );
    //--------------------------------------------------End of Mux-------------------------------------------------//

    //--------------------------------------------------Start of Address Alignment-------------------------------------------------//

    address_aligner address_aligner1 (
        .func_3(i_imem_rdata[14:12]),
        .address(alu_result),
        .mask(mask),
        .aligned_address(o_dmem_addr)
    );

    //--------------------------------------------------End of Address Alignment-------------------------------------------------//

    data_aligner data_aligner1 (
        .data(i_dmem_rdata),
        .mask(mask),
        .func_3(i_imem_rdata[14:12]),
        .data_output(aligned_data)
    );

    //*************************** END DECLARATION OF ALL MODULES AND SIGNAL CONNECTIONS ****************************//

    //********************************* ASSIGNMENT OF ALL OUTPUT SIGNALS IN HART **********************************//

    assign o_retire_pc = PC;

    assign o_retire_valid = 1;
    assign o_imem_raddr = PC;
    assign o_retire_inst = i_imem_rdata;
    assign o_retire_rs1_raddr = i_imem_rdata[19:15];
    assign o_retire_rs2_raddr = i_imem_rdata[24:20];
    assign o_retire_rs1_rdata = read_data_1;
    assign o_retire_rs2_rdata = read_data_2;
    assign o_retire_rd_waddr = (instruction_format == 6'b01_0000 | instruction_format == 6'b00_0010 | instruction_format == 6'b00_0001 | instruction_format == 6'b10_0000) ? i_imem_rdata[11:7] : 0;
    assign o_retire_rd_wdata = write_back;

    assign o_dmem_wdata = read_data_2;
    assign o_dmem_mask = mask;

    // Assigns instruction to be retired
    assign o_retire_inst = i_imem_rdata;


endmodule

`default_nettype wire
