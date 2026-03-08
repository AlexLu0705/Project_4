`default_nettype none

// The register file is effectively a single cycle memory with 32-bit words
// and depth 32. It has two asynchronous read ports, allowing two independent
// registers to be read at the same time combinationally, and one synchronous
// write port, allowing a register to be written to on the next clock edge.
// The register `x0` is hardwired to zero, and writes to it are ignored.
module rf #(
    // When this parameter is set to 1, "RF bypass" mode is enabled. This
    // allows data at the write port to be observed at the read ports
    // immediately without having to wait for the next clock edge. This is
    // a common forwarding optimization in a pipelined core (project 5), but
    // will cause a single-cycle processor to behave incorrectly.
    //
    // You are required to implement and test both modes. In project 3 and 4,
    // you will set this to 0, before enabling it in project 5.
    parameter BYPASS_EN = 0
) (
    // Global clock.
    input  wire        i_clk,
    // Synchronous active-high reset.
    input  wire        i_rst,
    // Both read register ports are asynchronous (zero-cycle). That is, read
    // data is visible combinationally without having to wait for a clock.
    //
    // Register read port 1, with input address [0, 31] and output data.
    input  wire [ 4:0] i_rs1_raddr,
    output wire [31:0] o_rs1_rdata,
    // Register read port 2, with input address [0, 31] and output data.
    input  wire [ 4:0] i_rs2_raddr,
    output wire [31:0] o_rs2_rdata,
    // The register write port is synchronous. When write is enabled, the
    // write data is visible after the next clock edge.
    //
    // Write register enable, address [0, 31] and input data.
    input  wire        i_rd_wen,
    input  wire [ 4:0] i_rd_waddr,
    input  wire [31:0] i_rd_wdata
);
    // TODO: Fill in your implementation here.
    // Declaring 2D array memory
    reg [31:0] memory [31:0];

    // loop counter for reset logic
    integer loop_counter;

    // Synchronous write logic
    always @(posedge i_clk) begin
        // Always set x0 register to 0 every clk cycle
        memory[0] <= 32'b0;
        // if reset, set all reg to 0;
        if(i_rst) begin
            memory[0]  = 32'b0;
            memory[1]  = 32'b0;
            memory[2]  = 32'b0;
            memory[3]  = 32'b0;
            memory[4]  = 32'b0;
            memory[5]  = 32'b0;
            memory[6]  = 32'b0;
            memory[7]  = 32'b0;
            memory[8]  = 32'b0;
            memory[9]  = 32'b0;
            memory[10] = 32'b0;
            memory[11] = 32'b0;
            memory[12] = 32'b0;
            memory[13] = 32'b0;
            memory[14] = 32'b0;
            memory[15] = 32'b0;
            memory[16] = 32'b0;
            memory[17] = 32'b0;
            memory[18] = 32'b0;
            memory[19] = 32'b0;
            memory[20] = 32'b0;
            memory[21] = 32'b0;
            memory[22] = 32'b0;
            memory[23] = 32'b0;
            memory[24] = 32'b0;
            memory[25] = 32'b0;
            memory[26] = 32'b0;
            memory[27] = 32'b0;
            memory[28] = 32'b0;
            memory[29] = 32'b0;
            memory[30] = 32'b0;
            memory[31] = 32'b0;
        end
        // Write to destination register unless address is x0
        else begin
            if(i_rd_wen && (i_rd_waddr != 5'b00000)) begin
                memory[i_rd_waddr] <= i_rd_wdata;
            end
        end
    end

    // Asychronous read logic
    generate 
        if(BYPASS_EN) begin  : generate_block
            // Do for both read port 1 and 2
            assign o_rs1_rdata = (i_rs1_raddr == 5'b00000 || (i_rd_wen && i_rd_waddr == 5'b00000)) ? 32'b0 :
                (i_rd_wen && (i_rd_waddr == i_rs1_raddr)) ? i_rd_wdata : 
                memory[i_rs1_raddr];
            assign o_rs2_rdata = (i_rs2_raddr == 5'b00000 || (i_rd_wen && i_rd_waddr == 5'b00000)) ? 32'b0 :
                (i_rd_wen && (i_rd_waddr == i_rs2_raddr)) ? i_rd_wdata : 
                memory[i_rs2_raddr];
        end
        // No bypass simple read assign, assign 0 if address 0
        else begin : dont_generate_block
            assign o_rs1_rdata = (i_rs1_raddr == 5'b00000) ? 32'b0 : memory[i_rs1_raddr];
            assign o_rs2_rdata = (i_rs2_raddr == 5'b00000) ? 32'b0 : memory[i_rs2_raddr];
        end
    endgenerate
endmodule

`default_nettype wire
