module DHT11(
    input wire clk,        // Entrada de reloj
    input wire rst,        // Entrada de reinicio
    input wire dht11_data, // Entrada de datos desde el sensor DHT11
    output reg [39:0] data, // Registro de 40 bits para almacenar los datos
    output wire dataReadModule // Salida del ReadModule
);

reg [3:0] state;           // Variable de estado
reg [7:0] bit_count;       // Variable de conteo de bits
reg [39:0] shift_register; // Registro de desplazamiento para almacenar 40 bits de datos
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
