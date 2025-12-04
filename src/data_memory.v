`include "defines.vh"

module data_memory (
    input clk,
    input we, // write enable (from control unit)
    input [15:0]  addr, // word address (from ALU result)
    input [15:0]  wdata, // data to store
    output [15:0]  rdata // data to load
);
    // 1KiB memory = 8192 bits = 512 words
    // Address range: 0..511 (9 bits)
    reg [15:0] mem [0:511];

    // Asynchronous read (combinational)
    assign rdata = mem[addr[9:0]];

    // Synchronous write
    always @(posedge clk) begin
        if (we) begin
            mem[addr[8:0]] <= wdata;
        end
    end

endmodule
