`timescale 1us/1us  // Definición de la escala de tiempo

module ReadModule_tb;

  reg clk;
  reg rst;
  reg in_data;
  wire out_data;

  // Instancia del módulo bajo prueba
  ReadModule uut (
    .clk(clk),
    .rst(rst),
    .in_data(in_data),
    .out_data(out_data)
  );

  // Generación de un pulso de reloj
  always #5 clk = ~clk;

  // Inicialización de señales
  initial begin
    clk = 0;
    rst = 1;
    in_data = 0;

    // Esperar un poco antes de desactivar el reset
    #10 rst = 0;

    // Simular durante 1000 unidades de tiempo
    #1000 $finish;
  end

    // Dumpfile y Dumpvars
    initial begin
     	$dumpfile("ReadModule.vcd");
    	$dumpvars(0, ReadModule_tb);
     end



endmodule
