module DivisorFrecuencia (
  input wire clk,
  input wire reset,
  output wire out
);

  reg [7:0] count;
  reg toggle;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      count <= 8'b0;
      toggle <= 1'b0;
    end else begin
      if (count == 8'd124) begin  // Contador para 125 (125 = 2^3 * 5^3) para lograr la división de frecuencia
        count <= 8'b0;
        toggle <= ~toggle;
      end else begin
        count <= count + 1;
      end
    end
  end

  assign out = toggle;

endmodule