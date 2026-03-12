`default_nettype none

// Simple mux selector, used for control logic in procesor implementation
module IF_ID_reg(

    input wire clk,

    input wire rst,

    input wire [31:0] PC,

    input wire [31:0] PC_4,

    input wire [31:0] instruction,
    
    output reg [31:0] PC_out,

    output reg [31:0] PC_4_out,

    output reg [31:0] instruction_out
);

    always @(posedge clk) begin
        if(rst) begin
            PC_out <= 32'bx;
            PC_4_out <= 32'bx;
            instruction_out <= 32'bx;
        end
        else begin
            PC_out <= PC;
            PC_4_out <= PC_4;
            instruction_out <= instruction;
        end
    end

endmodule

`default_nettype wire