`default_nettype none

// Simple mux selector, used for control logic in procesor implementation
module MEM_WB_reg(

    input wire clk,

    input wire [31:0] PC,

    input wire [31:0] alu_result,

    input wire [31:0] read_data,
    
    input wire jump,
    
    input wire mem_to_reg,

    input wire reg_write,

    // OUTPUT------------------------

    output reg [31:0] PC_out,

    output reg [31:0] alu_result_out,

    output reg [31:0] read_data_out,
    
    output reg jump_out,
    
    output reg mem_to_reg_out,

    output reg reg_write_out

);

    always begin
        @(posedge clk);
        PC_out <= PC;
        alu_result_out <= alu_result;
        read_data_out <= read_data;
        jump_out <= jump;
        mem_to_reg_out <= mem_to_reg;
        reg_write_out <= reg_write;
    end

endmodule

`default_nettype wire