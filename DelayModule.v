module DelayModule (
  input wire clk,          // Señal de reloj
  input wire rst,          // Señal de reinicio
  input wire [8:0] delay,   // Valor de delay de 9 bits
  output reg out_delay     // Salida de delay
);

  reg [8:0] count;          // Contador de delay

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      count <= 0;           // Reiniciar contador en caso de reinicio
      out_delay <= 0;       // Reiniciar salida en caso de reinicio
    end else begin
      if (count == delay) begin
        out_delay <= 1;     // Activar salida después del delay
        count <= 0;         // Reiniciar contador después del delay
      end else begin
        count <= count + 1; // Incrementar contador si no se alcanza el delay
        out_delay <= 0;     // Desactivar salida durante el delay
      end
    end
  end

endmodule
