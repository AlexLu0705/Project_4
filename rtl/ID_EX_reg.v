`default_nettype none

// Simple mux selector, used for control logic in procesor implementation
module ID_EX_reg(

    // Wires

    input wire clk,

    input wire [31:0] Jump_address,

    input wire [31:0] immediate,

    input wire [31:0] PC,

    input wire [31:0] PC_4,

    input wire [2:0] func_3,

    input wire [31:0] read_data_1,

    input wire [31:0] read_data_2,

    input wire [31:0] write_dest,

    // Control Signals

    input wire jump,

    input wire LUI,

    input wire ALU_src,

    input wire AUIPC,

    input wire sub,

    input wire arith,

    input wire uns,

    // Later stage control signals

    input wire mem_read,

    input wire mem_write,

    input wire mem_to_reg,

    input wire reg_write,

    // OUTPUTS--------------------
    // Wires

    output reg [31:0] Jump_address_out,

    output reg [31:0] immediate_out,

    output reg [31:0] PC_out,

    output reg [31:0] PC_4_out,

    output reg [2:0] func_3_out,

    output reg [31:0] read_data_1_out,

    output reg [31:0] read_data_2_out,

    output reg [31:0] write_dest_out,

    // Control Signals

    output reg jump_out,

    output reg LUI_out,

    output reg ALU_src_out,

    output reg AUIPC_out,

    output reg sub_out,

    output reg arith_out,

    output reg uns_out,

    // Later stage control signals

    output reg mem_read_out,

    output reg mem_write_out,

    output reg mem_to_reg_out,

    output reg reg_write_out
);

    always @(posedge clk) begin
        
        Jump_address_out <= Jump_address;
        immediate_out <= immediate;
        PC_out <= PC;
        PC_4_out <= PC_4;
        func_3_out <= func_3;
        read_data_1_out <= read_data_1;
        read_data_2_out <= read_data_2;
        write_dest_out <= write_dest;
        jump_out <= jump;
        LUI_out <= LUI;
        ALU_src_out <= ALU_src;
        AUIPC_out <= AUIPC;
        sub_out <= sub;
        arith_out <= arith;
        uns_out <= uns;
        mem_read_out <= mem_read;
        mem_write_out <= mem_write;
        mem_to_reg_out <= mem_to_reg;
        reg_write_out <= reg_write;
        
    end

endmodule

`default_nettype wire