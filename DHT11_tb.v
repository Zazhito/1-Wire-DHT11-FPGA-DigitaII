`timescale 1us/1us

module DHT11_tb;

  reg clk;
  reg rst;
  reg dht11_data;
  wire [39:0] data;

  // Instancia del módulo DHT11
  DHT11 uut (
    .clk(clk),
    .rst(rst),
    .dht11_data(dht11_data),
    .data(data)
  );

  // Generar un reloj
  always #5 clk = ~clk;

  // Inicialización de señales
  initial begin
    clk = 0;
    rst = 1;
    dht11_data = 1'b1;

    // Aplicar reset
    #10 rst = 0;

    // Simular operación normal
    #10 dht11_data = 1'b0; // Simular inicio de datos
    #100 dht11_data = 1'b1; // Simular fin de datos

    // Agregar más transiciones de datos según sea necesario

    #1000 $stop; // Detener la simulación después de un tiempo suficiente
  end
   // Dumpfile y Dumpvars
    initial begin
     	$dumpfile("DHT11.vcd");
    	$dumpvars(0, DHT11_tb);
     end
endmodule
