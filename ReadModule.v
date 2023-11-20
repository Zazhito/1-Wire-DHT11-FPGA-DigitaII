module ReadModule (
  input wire clk,          // Señal de reloj
  input wire rst,          // Señal de reinicio
  input wire in_data,      // Entrada de datos
  output reg out_data      // Salida de datos
);

  reg [0:0] D1, D2, D;      // Variables para almacenar datos
  wire out_delay;          // Señal de salida del DelayModule
  reg [8:0] delay1 = 10;    // Delay de 10 ciclos para 1 microsegundo
  reg [8:0] delay2 = 600;   // Delay de 600 ciclos para 60 microsegundos

  // Instancia del DelayModule
  DelayModule delay_module (
    .clk(clk),
    .rst(rst),
    .delay(delay1),
    .out_delay(out_delay)
  );

  // Proceso principal
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reiniciar variables en caso de reinicio
      D1 <= 0;
      D2 <= 0;
      D <= 0;
      out_data <= 0;
    end else begin
      // Activar salida durante el primer delay
      if (out_delay) begin
        // Guardar el bit de entrada en D1
        D1 <= in_data;
      end

      // Activar salida durante el segundo delay
      if (out_delay) begin
        // Guardar el bit de entrada en D2
        D2 <= in_data;
      end

      // Comparar D1 y D2
      if (D1 == D2) begin
        // Si son iguales, guardar D1 en D
        D <= D1;
        out_data <= D;
      end else begin
        // Si son diferentes, imprimir "ERROR"
        $display("ERROR");
      end
    end
  end

endmodule
