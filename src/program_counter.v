`include "defines.vh"

module program_counter (
    input clk,
    input reset,
    input pc_write,   // Enable signal from control unit
    input [15:0] pc_next,  // Next PC value (e.g., PC+1 or branch target)
    output reg [15:0] pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 16'b0;  // start at address 0
        else if (pc_write)
            pc_out <= pc_next;
    end
endmodule
