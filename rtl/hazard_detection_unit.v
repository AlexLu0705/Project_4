`default_nettype none

// Detect hazard, stop PC, insert NOP
module hazard_detection_unit (
    input wire [4:0] EX_rd,
    input wire [4:0] MEM_rd,

    input wire [4:0] ID_rs,
    input wire [4:0] ID_rt,
    
    input wire branch,

    // Output wire to driving result
    output reg nop,
    output reg nop_branch
);

    /**always @(posedge clk) begin
        // First check data hazard
        if(EX_rd == ID_Rs | EX_rd == ID_rt | MEM_rd == ID_Rs | MEM_rd == ID_rt) begin
            nop <= 1'b1;
            nop_branch <= 1'b0;
        end
        // Then check branches
        else if(branch) begin
            nop <= 1'b0;
            nop_branch <= 1'b1;
        end
        // Default
        else begin
            nop <= 1'b0;
            nop_branch <= 1'b0;
        end
    end**/

    assign nop = (EX_rd == ID_Rs | EX_rd == ID_rt | MEM_rd == ID_Rs | MEM_rd == ID_rt) ? 1'b1 : 1'b0;
    assign nop_branch = (!nop & branch) ? 1'b1 : 1'b0;



endmodule

`default_nettype wire