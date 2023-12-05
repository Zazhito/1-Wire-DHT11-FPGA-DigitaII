module DHT11_tb;
  reg clk;
  reg rst;
  reg dht11_data;
  wire ftdi_tx;

  DHT11 uut (
    .clk(clk),
    .rst(rst),
    .dht11_data(dht11_data),
    .ftdi_tx(ftdi_tx)
  );

  initial begin
    $dumpfile("DHT11.vcd");
    $dumpvars(0, DHT11_tb);

    clk = 0;
    rst = 1;
    dht11_data = 1'b0;

    #10 rst = 0;  
    #50 rst = 1;
    #200 rst = 0;


    #20 dht11_data = 1'b1;  
    #30 dht11_data = 1'b0;
    #40 dht11_data = 1'b1;
    #100 dht11_data = 1'b0;  
    #500 dht11_data = 1'b1;
    #700 dht11_data = 1'b0;

    #1000 $finish;  
  end

  always begin
    #5 clk = ~clk;  
  end

endmodule
