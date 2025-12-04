module nzp_reg (
    input  clk,
    input  reset,
    input  we,      // write enable for flags (from control unit)
    input  N_in,
    input  Z_in,
    input  P_in,
    output reg N,
    output reg Z,
    output reg P
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset: Z = 1, N = P = 0 (value considered 0)
            N <= 1'b0;
            Z <= 1'b1;
            P <= 1'b0;
        end else if (we) begin
            N <= N_in;
            Z <= Z_in;
            P <= P_in;
        end
    end
endmodule
