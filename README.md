# 1-Wire-DHT11-FPGA-DigitaII
Creado por Davidson Camilo Acuña Romero de la Universidad Nacional de Colombia,Este es un protocolo de comunicacion 1-wire para el sensor DHT11 para una FPGA Colorlight75E

El DHT11 es un sensor de Temperatura y Humedad Digital , arroja 40 bits de datos en grupos de 8 bits, cada grupo de bits es un dato diferente el primer dato desde el bit mas significativo es HUMEDAD_PARTE_ENTERA , HUMEDAD_PARTE_DECIMAL, TEMPERATURA_PARTE_ENTERA , TEMPERATURA_PARTE_DECIMAL y BITS_PARIDAD estos ultimos son para comprobar que los datos son correctos.

Lo primero que se realizo fue un divisor de frecuencia, la FPGA tiene un reloj de frecuencia de 25M Hz, el DHT11 trabaja en terminos de micro-segundos, por lo tanto la frecuencia debe estar en 1M Hz, la simulacion la encuentran en DivisorFrecuencia.vcd 

Lo segundo fue realizar un modulo de Delay DelayModule donde se puede indicar el tiempo de delay, esto es vital porque segun el protocolo 1-Wire dependiendo los tiempos de Delay significan un dato o una accion, por ejemplo , un delay de 480 Microsegundos es para preguntar si los sensores estan listos para transmitir, un delay de 15 microsegundos significa que va a leer el dato del DHT11, La simulacion la encuentran en DelayModule.vcd

En tercer lugar se creo el modulo para poder leer los datos ReadModule esto para poder guardar bit por bit de los datos que el DHT11 envia, en este modulo se instancia DelayModule , la simulacion la encuentrar en ReadModule.vcd

En la comunicacion se adapto un modulo de puerto UART de comunicacion serial por el cual se transmiten los datos

Por ultimo se desarrollo el top DHT11 , donde tenemos una entrada de reloj (clk) , entrada de reinicio (rst) , entrada de datos desde el sensor DHT11 (dht11_data), Registro de 40 bits para almacenar los datos (data), y la salida del ReadModule (dataReadModule), en este modulo Top se manejo una maquina de 4 estados Inactivo (IDLE) , Inicio (START) , Lectura (READ) , Completado (DONE).

En Resumen el DHT11 ofrece los datos por medio de 1-Wire y este modulo los almacena en un registro de 40 bits (data), donde el usuario final podra disponer de ellos ya sea para visualizacion o para otra logica.
