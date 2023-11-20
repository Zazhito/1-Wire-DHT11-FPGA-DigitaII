`timescale 1us/1us

module DelayModule_tb;
  reg clk, rst;
  reg [8:0] delay;
  wire out_delay;

  // Instancia del módulo
  DelayModule uut (
    .clk(clk),
    .rst(rst),
    .delay(delay),
    .out_delay(out_delay)
  );

  // Generador de clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Testbench
  initial begin
    // Inicialización de señales
    rst = 1;
    delay = 6;
    
    // Esperar un poco antes de desactivar el reset
    #10 rst = 0;

    // Simular durante 1000 unidades de tiempo
    #1000 $finish;
  end

  // Dumpfile y Dumpvars
  initial begin
    $dumpfile("DelayModule.vcd");
    $dumpvars(0, DelayModule_tb);
  end

endmodule
