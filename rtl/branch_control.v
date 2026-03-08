`default_nettype none

// determines whether or not to take the branch address depending on input from ALU and control block; outputs branch control signal for mux
module branch_control(
    // ALU signal zero flag, for beq and bne instructions
    input wire zero,

    // ALU set less than flag, for blt instructions
    input wire slt,

    // control block signal to determine if branch instruction
    input wire control_signal_branch,

    // 3-bit function
    input wire [2:0] func_3,

    // determines branch control signal for mux
    output wire branch
);
    
    assign branch = (!control_signal_branch) ? 0 : // always 0 if not branch instruction
                    (func_3 == 3'b000) ? zero : // beq
                    (func_3 == 3'b001) ? !zero : // bne
                    (func_3 == 3'b100) ? slt : // blt
                    (func_3 == 3'b101) ? !slt : // bge
                    (func_3 == 3'b110) ? slt : // bltu
                    (func_3 == 3'b111) ? !slt : // bgeu
                    0;

endmodule

`default_nettype wire