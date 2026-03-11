`default_nettype none

// Simple mux selector, used for control logic in procesor implementation
module MEM_WB_reg(

    input wire clk,

    input wire [31:0] PC,

    input wire [31:0] alu_result,

    input wire [31:0] read_data_1,

    input wire [31:0] read_data_2,

    input wire [31:0] write_dest,

    input wire [31:0] instruction,
    
    input wire jump,
    
    input wire mem_to_reg,

    input wire reg_write,

    input wire dependency,

    // OUTPUT------------------------

    output reg [31:0] PC_out,

    output reg [31:0] alu_result_out,

    output reg [31:0] read_data_1_out,

    output reg [31:0] read_data_2_out,

    output reg [31:0] write_dest_out,

    output reg [31:0] instruction_out,

    output reg jump_out,
    
    output reg mem_to_reg_out,

    output reg reg_write_out,

    output reg dependency_out

);

    always begin
        @(posedge clk);
        PC_out <= PC;
        alu_result_out <= alu_result;
        read_data_1_out <= read_data_1;
        read_data_2_out <= read_data_2;
        write_dest_out <= write_dest;
        instruction_out <= instruction;
        jump_out <= jump;
        mem_to_reg_out <= mem_to_reg;
        reg_write_out <= reg_write;
        dependency_out <= dependency;
    end

endmodule

`default_nettype wire