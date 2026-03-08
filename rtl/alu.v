`default_nettype none

// The arithmetic logic unit (ALU) is responsible for performing the core
// calculations of the processor. It takes two 32-bit operands and outputs
// a 32 bit result based on the selection operation - addition, comparison,
// shift, or logical operation. This ALU is a purely combinational block, so
// you should not attempt to add any registers or pipeline it.
module alu (
    // NOTE: Both 3'b010 and 3'b011 are used for set less than operations and
    // your implementation should output the same result for both codes. The
    // reason for this will become clear in project 3.
    //
    // Major operation selection.
    // 3'b000: addition/subtraction if `i_sub` asserted
    // 3'b001: shift left logical
    // 3'b010,
    // 3'b011: set less than/unsigned if `i_unsigned` asserted
    // 3'b100: exclusive or
    // 3'b101: shift right logical/arithmetic if `i_arith` asserted
    // 3'b110: or
    // 3'b111: and
    input  wire [ 2:0] i_opsel,
    // When asserted, addition operations should subtract instead.
    // This is only used for `i_opsel == 3'b000` (addition/subtraction).
    input  wire        i_sub,
    // When asserted, comparison operations should be treated as unsigned.
    // This is used for branch comparisons and set less than unsigned. For
    // b ranch operations, the ALU result is not used, only the comparison
    // results.
    input  wire        i_unsigned,
    // When asserted, right shifts should be treated as arithmetic instead of
    // logical. This is only used for `i_opsel == 3'b101` (shift right).
    input  wire        i_arith,
    // First 32-bit input operand.
    input  wire [31:0] i_op1,
    // Second 32-bit input operand.
    input  wire [31:0] i_op2,
    // 32-bit output result. Any carry out should be ignored.
    output wire [31:0] o_result,
    // Equality result. This is used externally to determine if a branch
    // should be taken.
    output wire        o_eq,
    // Set less than result. This is used externally to determine if a branch
    // should be taken.
    output wire        o_slt
);
    // TODO: Fill in your implementation here.
    // take care of the flags first
    // signed compare
    // extract sign bit first
    wire sign1 = i_op1[31];
    wire sign2 = i_op2[31];

    // if same sign, do the actual comparison
    wire slt_signed = (sign1 & ~sign2) | (~(sign1 ^ sign2) & (i_op1 < i_op2));

    // unsigned compare
    wire slt_unsigned = (i_op1 < i_op2);

    // assign these 2 flags
    assign o_eq  = (i_op1 == i_op2);
    assign o_slt = i_unsigned ? slt_unsigned : slt_signed;

    // get the shift amount from op2
    wire [4:0] shamt = i_op2[4:0];

    // assign add/sub
    wire [31:0] addsub = i_sub ? (i_op1 - i_op2) : (i_op1 + i_op2);

    // assign logical shift left MANUALLY
    wire [31:0] sll = (shamt == 0) ? i_op1 :
                  (shamt == 1) ? {i_op1[30:0], 1'b0} :
                  (shamt == 2) ? {i_op1[29:0], 2'b0} :
                  (shamt == 3) ? {i_op1[28:0], 3'b0} :
                  (shamt == 4) ? {i_op1[27:0], 4'b0} :
                  (shamt == 5) ? {i_op1[26:0], 5'b0} :
                  (shamt == 6) ? {i_op1[25:0], 6'b0} :
                  (shamt == 7) ? {i_op1[24:0], 7'b0} :
                  (shamt == 8) ? {i_op1[23:0], 8'b0} :
                  (shamt == 9) ? {i_op1[22:0], 9'b0} :
                  (shamt == 10) ? {i_op1[21:0],10'b0} :
                  (shamt == 11) ? {i_op1[20:0], 11'b0} :
                  (shamt == 12) ? {i_op1[19:0], 12'b0} :
                  (shamt == 13) ? {i_op1[18:0], 13'b0} :
                  (shamt == 14) ? {i_op1[17:0], 14'b0} :
                  (shamt == 15) ? {i_op1[16:0], 15'b0} :
                  (shamt == 16) ? {i_op1[15:0], 16'b0} :
                  (shamt == 17) ? {i_op1[14:0], 17'b0} :
                  (shamt == 18) ? {i_op1[13:0], 18'b0} :
                  (shamt == 19) ? {i_op1[12:0], 19'b0} :
                  (shamt == 20) ? {i_op1[11:0], 20'b0} :
                  (shamt == 21) ? {i_op1[10:0],21'b0} :
                  (shamt == 22) ? {i_op1[9:0], 22'b0} :
                  (shamt == 23) ? {i_op1[8:0], 23'b0} :
                  (shamt == 24) ? {i_op1[7:0], 24'b0} :
                  (shamt == 25) ? {i_op1[6:0], 25'b0} :
                  (shamt == 26) ? {i_op1[5:0], 26'b0} :
                  (shamt == 27) ? {i_op1[4:0], 27'b0} :
                  (shamt == 28) ? {i_op1[3:0], 28'b0} :
                  (shamt == 29) ? {i_op1[2:0], 29'b0} :
                  (shamt == 30) ? {i_op1[1:0], 30'b0} :
                  (shamt == 31) ? {i_op1[0],   31'b0} : 32'b0;
                    
    // assign set less than, just use the flag as the last bit
    wire [31:0] slt = {31'b0, o_slt};

    // assign xor
    wire [31:0] ex_or = (i_op1 ^ i_op2);

    // assign logical right shift MANUALLY
    wire [31:0] srl = (shamt == 0)  ? i_op1 :
                  (shamt == 1) ? { 1'b0, i_op1[31:1]} :
                  (shamt == 2) ? { 2'b0, i_op1[31:2]} :
                  (shamt == 3) ? { 3'b0, i_op1[31:3]} :
                  (shamt == 4) ? { 4'b0, i_op1[31:4]} :
                  (shamt == 5) ? { 5'b0, i_op1[31:5]} :
                  (shamt == 6) ? { 6'b0, i_op1[31:6]} :
                  (shamt == 7) ? { 7'b0, i_op1[31:7]} :
                  (shamt == 8) ? { 8'b0, i_op1[31:8]} :
                  (shamt == 9) ? { 9'b0, i_op1[31:9]} :
                  (shamt == 10) ? {10'b0,i_op1[31:10]} :
                  (shamt == 11) ? {11'b0, i_op1[31:11]} :
                  (shamt == 12) ? {12'b0, i_op1[31:12]} :
                  (shamt == 13) ? {13'b0, i_op1[31:13]} :
                  (shamt == 14) ? {14'b0, i_op1[31:14]} :
                  (shamt == 15) ? {15'b0, i_op1[31:15]} :
                  (shamt == 16) ? {16'b0, i_op1[31:16]} :
                  (shamt == 17) ? {17'b0, i_op1[31:17]} :
                  (shamt == 18) ? {18'b0, i_op1[31:18]} :
                  (shamt == 19) ? {19'b0, i_op1[31:19]} :
                  (shamt == 20) ? {20'b0, i_op1[31:20]} :
                  (shamt == 21) ? {21'b0, i_op1[31:21]} :
                  (shamt == 22) ? {22'b0, i_op1[31:22]} :
                  (shamt == 23) ? {23'b0, i_op1[31:23]} :
                  (shamt == 24) ? {24'b0, i_op1[31:24]} :
                  (shamt == 25) ? {25'b0, i_op1[31:25]} :
                  (shamt == 26) ? {26'b0, i_op1[31:26]} :
                  (shamt == 27) ? {27'b0, i_op1[31:27]} :
                  (shamt == 28) ? {28'b0, i_op1[31:28]} :
                  (shamt == 29) ? {29'b0, i_op1[31:29]} :
                  (shamt == 30) ? {30'b0, i_op1[31:30]} :
                  (shamt == 31) ? {31'b0, i_op1[31]} : 32'b0;

    //  assign arithmetic right shift MANUALLY
    // extract the sign bit first
    wire sign_bit = i_op1[31];
    wire [31:0] sra = (shamt == 0)  ? i_op1 :
                  (shamt == 1) ? {{1{sign_bit}}, i_op1[31:1]} :
                  (shamt == 2) ? {{2{sign_bit}}, i_op1[31:2]} :
                  (shamt == 3) ? {{3{sign_bit}}, i_op1[31:3]} :
                  (shamt == 4) ? {{4{sign_bit}}, i_op1[31:4]} :
                  (shamt == 5) ? {{5{sign_bit}}, i_op1[31:5]} :
                  (shamt == 6) ? {{6{sign_bit}}, i_op1[31:6]} :
                  (shamt == 7) ? {{7{sign_bit}}, i_op1[31:7]} :
                  (shamt == 8) ? {{8{sign_bit}}, i_op1[31:8]} :
                  (shamt == 9)  ? {{9{sign_bit}}, i_op1[31:9]} :
                  (shamt == 10) ? {{10{sign_bit}}, i_op1[31:10]} :
                  (shamt == 11) ? {{11{sign_bit}}, i_op1[31:11]} :
                  (shamt == 12) ? {{12{sign_bit}}, i_op1[31:12]} :
                  (shamt == 13) ? {{13{sign_bit}}, i_op1[31:13]} :
                  (shamt == 14) ? {{14{sign_bit}}, i_op1[31:14]} :
                  (shamt == 15) ? {{15{sign_bit}}, i_op1[31:15]} :
                  (shamt == 16) ? {{16{sign_bit}}, i_op1[31:16]} :
                  (shamt == 17) ? {{17{sign_bit}}, i_op1[31:17]} :
                  (shamt == 18) ? {{18{sign_bit}}, i_op1[31:18]} :
                  (shamt == 19) ? {{19{sign_bit}}, i_op1[31:19]} :
                  (shamt == 20) ? {{20{sign_bit}}, i_op1[31:20]} :
                  (shamt == 21) ? {{21{sign_bit}}, i_op1[31:21]} :
                  (shamt == 22) ? {{22{sign_bit}}, i_op1[31:22]} :
                  (shamt == 23) ? {{23{sign_bit}}, i_op1[31:23]} :
                  (shamt == 24) ? {{24{sign_bit}}, i_op1[31:24]} :
                  (shamt == 25) ? {{25{sign_bit}}, i_op1[31:25]} :
                  (shamt == 26) ? {{26{sign_bit}}, i_op1[31:26]} :
                  (shamt == 27) ? {{27{sign_bit}}, i_op1[31:27]} :
                  (shamt == 28) ? {{28{sign_bit}}, i_op1[31:28]} :
                  (shamt == 29) ? {{29{sign_bit}}, i_op1[31:29]} :
                  (shamt == 30) ? {{30{sign_bit}}, i_op1[31:30]} :
                  (shamt == 31) ? {{31{sign_bit}}, i_op1[31]} : 32'b0;

    // assign or
    wire [31:0] or_bitwise = (i_op1 | i_op2);

    // assign and
    wire [31:0] and_bitwise = (i_op1 & i_op2);

    assign o_result = (i_opsel == 3'b000) ? addsub :
                    (i_opsel == 3'b001) ? sll :
                    (i_opsel == 3'b010) ? slt :
                    (i_opsel == 3'b011) ? slt :
                    (i_opsel == 3'b100) ? ex_or :
                    (i_opsel == 3'b101) ? (i_arith ? sra : srl) :
                    (i_opsel == 3'b110) ? or_bitwise :
                    (i_opsel == 3'b111) ? and_bitwise : 32'b0;
endmodule

`default_nettype wire