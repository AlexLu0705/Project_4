`default_nettype none

// Simple mux selector, used for control logic in procesor implementation
module EX_MEM_reg(

    input wire clk,

    input wire [31:0] PC,

    input wire [31:0] alu_result,

    input wire [31:0] mem_data,

    input wire [31:0] write_dest,

    input wire [2:0] func_3,

    input wire [31:0] read_data_1,

    input wire [31:0] read_data_2,

    input wire [31:0] instruction,


    // Control Signal

    input wire mem_read,

    input wire mem_write,

    input wire mem_to_reg,

    input wire jump,
    
    input wire reg_write,

    input wire dependency,

    //OUTPUT-------------------------

    output reg [31:0] PC_out,

    output reg [31:0] alu_result_out,

    output reg [31:0] mem_data_out,

    output reg [31:0] write_dest_out,

    output reg [2:0] func_3_out,

    output reg [31:0] read_data_1_out,

    output reg [31:0] read_data_2_out,

    output reg [31:0] instruction_out,

    // Control Signal

    output reg mem_read_out,

    output reg mem_write_out,

    output reg mem_to_reg_out,

    output reg jump_out,
    
    output reg reg_write_out,
    
    output reg dependency_out

);

    always @(posedge clk) begin
        PC_out <= PC;
        alu_result_out <= alu_result;
        mem_data_out <= mem_data;
        write_dest_out <= write_dest;
        func_3_out <= func_3;
        read_data_1_out <= read_data_1;
        read_data_2_out <= read_data_2;
        instruction_out <= instruction;
        jump_out <= jump;
        mem_read_out <= mem_read;
        mem_write_out <= mem_write;
        mem_to_reg_out <= mem_to_reg;
        reg_write_out <= reg_write;
        dependency_out <= dependency;
    end

endmodule

`default_nettype wire