// Detect hazard, stop PC, insert NOP
module hazard_detection_unit (
    input wire [4:0] EX_rd,
    input wire [4:0] MEM_rd,

    input wire [4:0] ID_rs,
    input wire [4:0] ID_rt,
    
    input wire branch,

    input wire [2:0] counter,

    // Output wire to driving result
    output wire dependency,

    output wire PC_enable
    
);

    assign dependency = (counter < 3) ? 1'b0 : 
                        (EX_rd == 32'b0 | MEM_rd == 32'b0) ? 1'b0 :
                        (EX_rd == ID_rs | EX_rd == ID_rt | MEM_rd == ID_rs | MEM_rd == ID_rt) ? 1'b1 : 1'b0;

    assign PC_enable = (counter < 3) ? 1'b1 : ((branch == 1'b1 | dependency == 1'b1) ? 1'b0 : 1'b1);

endmodule