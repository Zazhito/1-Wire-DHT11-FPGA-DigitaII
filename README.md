# 1-Wire-DHT11-FPGA-DigitaII
Creado por Davidson Camilo Acuña Romero de la Universidad Nacional de Colombia,Este es un protocolo de comunicacion 1-wire para el sensor DHT11 para una FPGA Colorlight75E

El DHT11 es un sensor de Temperatura y Humedad Digital , arroja 40 bits de datos en grupos de 8 bits, cada grupo de bits es un dato diferente el primer dato desde el bit mas significativo es HUMEDAD_PARTE_ENTERA , HUMEDAD_PARTE_DECIMAL, TEMPERATURA_PARTE_ENTERA , TEMPERATURA_PARTE_DECIMAL y BITS_PARIDAD estos ultimos son para comprobar que los datos son correctos.

Lo primero que se realizo fue un divisor de frecuencia, la FPGA tiene un reloj de frecuencia de 25M Hz, el DHT11 trabaja en terminos de micro-segundos, por lo tanto la frecuencia debe estar en 1M Hz, la simulacion la encuentran en DivisorFrecuencia.vcd 
