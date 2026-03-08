`default_nettype none

module data_aligner(
    // Operands
    input wire [31:0] data,
    
    input wire [3:0] mask,

    // Function 3 for bit length of instruction
    input wire [2:0] func_3,

    output wire [31:0] data_output
);
    wire sign_bit = (func_3 == 3'b100 | func_3 == 3'b101) ? 1'b0 : // unsigned
                   (mask == 4'b0001) ? data[7] :
                   (mask == 4'b0010 | mask == 4'b0011) ? data[15] :
                   (mask == 4'b0100) ? data[23] :
                   (mask == 4'b1000 | mask == 4'b1100) ? data[31] :
                   1'b0;



    assign data_output = (mask == 4'b1111) ? data :
                         (mask == 4'b0011) ? {{16{sign_bit}}, data[15:0]} :
                         (mask == 4'b1100) ? {{16{sign_bit}}, data[31:16]} :
                         (mask == 4'b0001) ? {{24{sign_bit}}, data[7:0]} :
                         (mask == 4'b0010) ? {{24{sign_bit}}, data[15:8]} :
                         (mask == 4'b0100) ? {{24{sign_bit}}, data[23:16]} :
                         (mask == 4'b1000) ? {{24{sign_bit}}, data[31:24]} : data;

endmodule

`default_nettype wire