module DivisorFrecuencia (
  input wire clk,
  input wire reset,
  output wire out
);
  reg clk_1M = 0;
  reg [31:0] cntr_1M = 32'b0;
  parameter period_1M = 25;
  always @ (posedge clk) begin
        /* generate 1M Hz clock */
        cntr_1M <= cntr_1M + 1;
        if (cntr_1M == period_1M) begin
            clk_1M <= ~clk_1M;
            cntr_1M <= 32'b0;
        end
  end

  assign out = clk_1M;

endmodule