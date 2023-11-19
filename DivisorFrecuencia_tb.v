module DivisorFrecuencia_tb;

  reg clk;
  reg reset;
  wire out;

  DivisorFrecuencia uut (
    .clk(clk),
    .reset(reset),
    .out(out)
  );

  initial begin
    clk = 0;
    reset = 0;

    // Inicialización de la simulación
    $dumpfile("DivisorFrecuencia.vcd");
    $dumpvars(0, DivisorFrecuencia_tb);

    // Generación de pulsos de reloj
    repeat (200) begin
      #5 clk = ~clk;
    end

    // Aplicación de reset
    reset = 1;
    #10 reset = 0;

    // Ejecución de la simulación
    repeat (400) begin
      #5 clk = ~clk;
    end

    // Fin de la simulación
    $finish;
  end

endmodule
