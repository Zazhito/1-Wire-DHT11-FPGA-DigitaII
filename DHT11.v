module DHT11(
    input wire clk,        // Entrada de reloj
    input wire rst,        // Entrada de reinicio
    input wire dht11_data, // Entrada de datos desde el sensor DHT11
    output ftdi_tx
);
wire dataReadModule;
reg [39:0] data;
reg clk_9600 = 0;
reg [31:0] cntr_9600 = 32'b0;
parameter period_9600 = 1302;
parameter ASCII_0 = 8'd48;
parameter ASCII_1 = 8'd49;
//parameter ASCII_2 = 8'd50;
//parameter ASCII_3 = 8'd51;
//parameter ASCII_4 = 8'd52;
//parameter ASCII_5 = 8'd53;
//parameter ASCII_6 = 8'd54;
//parameter ASCII_7 = 8'd55;
//parameter ASCII_8 = 8'd56;
//parameter ASCII_9 = 8'd57;
reg [7:0] uart_txbyte = ASCII_0;
reg uart_send = 1'b1;
wire uart_txed;
reg [3:0] state;           // Variable de estado
reg [7:0] bit_count;       // Variable de conteo de bits
reg [39:0] shift_register; // Registro de desplazamiento para almacenar 40 bits de datos
reg [0:0] D1, D2, D;      // Variables para almacenar datos
wire out_delay;          // Señal de salida del DelayModule
reg [8:0] delay1 = 10;    // Delay de 10 ciclos para 1 microsegundo
reg [8:0] delay2 = 600;   // Delay de 600 ciclos para 60 microsegundos



  //Instancia del ComunicationModule
  ComunicationModule comunication_module(
    .clk(clk_9600),
    .txbyte (uart_txbyte),
    .senddata (uart_send),
    .txdone (uart_txed),
    .tx (ftdi_tx),
  );
  // Instancia del DelayModule
  DelayModule delay_module (
    .clk(clk),
    .rst(rst),
    .delay(delay1),
    .out_delay(out_delay)
  );

  // Instancia del ReadModule
  ReadModule read_module (
    .clk(clk),
    .rst(rst),
    .in_data(dht11_data),
    .out_data(dataReadModule)
  );

// Definir estados
parameter IDLE = 4'b0000;
parameter START = 4'b0001;
parameter READ = 4'b0010;
parameter DONE = 4'b0011;

 always @ (posedge hwclk) begin
        /* generate 9600 Hz clock */
        cntr_9600 <= cntr_9600 + 1;
        if (cntr_9600 == period_9600) begin
            clk_9600 <= ~clk_9600;
            cntr_9600 <= 32'b0;
        end
 end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        bit_count <= 8'b0;
        shift_register <= 40'b0;
    end else begin
        case (state)
            IDLE: begin
                if (dht11_data == 1'b0) begin
                    state <= START;
                    bit_count <= 8'b0;
                end
            end
            START: begin
                state <= READ;
            end
            READ: begin
                if (bit_count < 8) begin
                    shift_register[bit_count] <= dht11_data;
                    uart_txbyte <= dht11_data;
                        if (uart_txbyte == ASCII_1) begin
                            uart_txbyte <= ASCII_0;
                        end else begin
                            uart_txbyte <= uart_txbyte + 1;
                        end
                    bit_count <= bit_count + 1;
                end else begin
                    state <= DONE;
                end
            end
            DONE: begin
                // Procesar los 40 bits de datos 
                data <= shift_register;
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

endmodule
