module BETA (
  input wire CLK,                      // Reloj de la FPGA Colorlight.
  input wire RESET,                    // Resetea el proceso de adquisición, el reset es asíncrono y activo en alto.
  input wire ENABLE,                   // Habilitador, inicia el proceso de adquisición cuando se pone a '1'.
  inout wire DATA,                     // Puerto bidireccional de datos.
  output ftdi_tx
);
  reg clk_9600;
  reg [7:0] uart_txbyte = 1'b0;
  reg uart_send = 1'b1;
  wire uart_txed;
  reg clk_1 = 0;
  reg dataInterna;		// registro interno para data
  reg ERROR;                   // Bit que indica si hubo algún error al verificar el Checksum.
  reg FIN;                      // Bit que indica fin de adquisición.
  parameter CLK_FPGA = 25000000;  // Valor de la frecuencia de reloj en Hertz.
  parameter MAX_CONTA = CLK_FPGA * 2;      // Define el valor máximo de "cont" para un retardo de 2 segundos.
  parameter MAX_RANGO = CLK_FPGA - 1;      // Define el valor máximo de "cont2".
  parameter MAX_18MS = CLK_FPGA / 55;      // Constante para retardo de 18ms.
  parameter RANGO_1 = CLK_FPGA / 13888;    // Constante para definir el rango mínimo para determinar si se registro un '0' o '1' lógico.
  parameter RANGO_2 = CLK_FPGA / 12500;    // Constante para definir el rango máximo para determinar si se registro un '0' o '1' lógico.
  reg enable_cont = 1'b0;                    // Bandera que habilita el proceso del contador "cont".
  reg flanco_bajada = 1'b0;                  // Bandera que indica cuándo se ha detectado un flanco de bajada.
  reg [3:0] reg1 = 4'b0000;                 // Registro para la detección de flancos.
  reg [39:0] reg1_total = 40'b0000000000;    // Registro donde se almacenan los 40 bits de información que manda el sensor DHT11.
  reg [7:0] sum = 8'b00000000;               // Señal que almacena el resultado de la sumatoria para el Checksum.
  reg [31:0] cont = 0;                        // Contador para diferentes retardos.
  reg [31:0] cont2 = 0;                       // Señal que guarda el tiempo de duración en '0' para determinar si se recibió un '0' o '1'.
  reg [3:0] estados = 0;                      // Señal para máquina de estados.
  reg [5:0] i = 6'b101000;                    // Señal que indica el bit que se almacenará en "reg_total".
  reg [7:0] RH;                 // Valor de la humedad relativa.
  reg [7:0] TEMP;               // Valor de la temperatura.
  assign DATA=dataInterna;

//Instancia del ComunicationModule
  ComunicationModule comunication_module(
    .clk(clk_9600),
    .txbyte (uart_txbyte),
    .senddata (uart_send),
    .txdone (uart_txed),
    .tx (ftdi_tx)
  );

// Instancia del DivisorFrecuencia_9600
  DivisorFrecuencia_9600 divisorFrecuencia_9600 (
    .CLK(CLK),
    .clk_9600(clk_9600)
  );


  // Proceso que inicia el conteo cuando se activa "enable_cont" --
  always @(posedge CLK) begin
    if (enable_cont) begin
      cont <= cont + 1;
    end else begin
      cont <= 0;
    end
  end

  // Proceso que se encarga de la adquisición de datos --
  always @(posedge CLK or posedge RESET) begin
    if (RESET) begin  // Resetea la máquina de estados.
      estados <= 0;
    end else if (ENABLE) begin
      case (estados)
        0: begin  // Espera a que este activo "ENABLE" para iniciar el proceso de adquisición.
          FIN <= 1'b0;
          ERROR <= 1'b0;
          if (ENABLE) begin
            estados <= 1;
          end else begin
            estados <= 0;
          end
        end
        1: begin  // Tiempo de espera de 18 milisegundos necesarios según las especificaciones de la tarjeta con un '0' en "DATA".
          dataInterna <= 1'b0;
          enable_cont <= 1'b1;
          if (cont == MAX_18MS) begin
            enable_cont <= 1'b0;
            estados <= 2;
          end else begin
            estados <= 1;
          end
        end
        2: begin  // Se pone el puerto "DATA" para leer
          if (DATA == 1'b0) begin
            estados <= 3;
          end else begin
            estados <= 2;
          end
        end
        3: begin  // Espera a que el sensor responda con un flanco de bajada y después vuelve a mandar un '1'.
          if (flanco_bajada == 1'b1) begin
            estados <= 4;
          end else begin
            estados <= 3;
          end
        end
        4: begin  // Espera los flancos de bajada de cada uno de los bits a reconocer.
          enable_cont <= 1'b1;
          if (flanco_bajada == 1'b1) begin
            cont2 <= cont;
            estados <= 5;
            enable_cont <= 1'b0;
          end else begin
            estados <= 4;
          end
        end
        5: begin  // Compara los tiempos de adquisición para definir si es un '0' o '1' lógico y se almacenan en "reg_total".
          if (cont2 > RANGO_1 && cont2 < RANGO_2) begin
            reg1_total[i] <= 1'b0;
            i <= i - 1;
            if (i == 6'b000000) begin
              estados <= 6;
              i <= 6'b101000;
            end else begin
              estados <= 4;
            end
          end else begin
            reg1_total[i] <= 1'b1;
            i <= i - 1;
            if (i == 6'b000000) begin
              estados <= 6;
              i <= 6'b101000;
            end else begin
              estados <= 4;
            end
          end
        end
        6: begin  // Realiza la sumatoria de los datos para verificar el Checksum según las especificaciones del sensor.
          sum <= reg1_total[39:32] + reg1_total[31:24] + reg1_total[23:16] + reg1_total[15:8];
          estados <= 7;
        end
        7: begin  // Se compara el Checksum con el valor de "sum", si es igual la trasferencia fue exitosa y se mandan los valores por "RH" y "TEMP" sino se manda error y se deberá resetear el proceso.
          if (sum == reg1_total[7:0]) begin
            RH <= reg1_total[39:32];
  	    uart_txbyte <= RH;
            TEMP <= reg1_total[23:16];
	    uart_txbyte <= TEMP;
            estados <= 8;
          end else begin
            estados <= 12;
          end
        end
        8: begin  // Tiempo de espera de 2 segundos para la próxima adquisición.
          enable_cont <= 1'b1;
          if (cont == MAX_CONTA) begin
            enable_cont <= 1'b0;
            estados <= 9;
          end else begin
            estados <= 8;
          end
        end
        9: begin  // Se activa la bandera "FIN".
          FIN <= 1'b1;
          estados <= 10;
        end
        10: begin  // Se desactiva la bandera "FIN".
          FIN <= 1'b0;
          estados <= 11;
        end
        11: begin  // Estado dummy.
          estados <= 0;
        end
        default: begin  // Se manda el error en caso de que el Checksum no coincida.
          ERROR <= 1'b1;
        end
      endcase
    end
  end

  // Proceso que hace la detección de flancos mediante un registro de corrimiento.
  always @(posedge CLK) begin
    reg1 <= {reg1[2:0], dataInterna};
    if (reg1 == 4'b1100) begin
      flanco_bajada <= 1'b1;
    end else begin
      flanco_bajada <= 1'b0;
    end
  end

endmodule
