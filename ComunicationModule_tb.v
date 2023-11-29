`timescale 1us/1us

module ComunicationModule_tb;

    // Parameters
    parameter CLK_PERIOD = 100; // Clock period in ns

    // Signals
    reg clk;
    reg [7:0] txbyte;
    reg senddata;
    wire txdone;
    wire tx;

    // Instantiate the ComunicationModule
    ComunicationModule uut (
        .clk(clk),
        .txbyte(txbyte),
        .senddata(senddata),
        .txdone(txdone),
        .tx(tx)
    );

    // Clock generation
    initial begin
     clk = 0;
     forever #5 clk = ~clk;
    end

    // Initial block
    initial begin
        // Initialize inputs
        clk = 0;
        txbyte = 8'b11011010; // Example data
        senddata = 0;

        // Dump VCD file
        $dumpfile("ComunicationModule.vcd");
        $dumpvars(0, ComunicationModule_tb);

        // Apply stimulus
        #5 senddata = 1; // Trigger transmission

        // Monitor output
        $monitor("Time=%t, tx=%b, txdone=%b", $time, tx, txdone);

        // Run simulation for a while
        #100 $stop;
    end

endmodule
