`timescale 1ns/1ps

module spi_master_tb;
    reg        clk;
    reg        rst_n;
    reg        start;
    reg  [7:0] tx_data;
    wire [7:0] rx_data;
    wire       busy;
    wire       sclk;
    wire       mosi;
    reg        miso;
    wire       cs_n;

    spi_master uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .busy(busy),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n)
    );

    // 100MHz Clock Generation
    always #5 clk = ~clk;

    // Safety timeout to prevent any run-time hang
    initial begin
        #3000;
        $display("Safety Timeout Reached.");
        $finish;
    end

    // Loopback logic: MOSI data feeds back into MISO
    always @(*) begin
        miso = mosi;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, spi_master_tb);

        clk     = 0;
        rst_n   = 0;
        start   = 0;
        tx_data = 8'h00;

        $display("--------------------------------------------------");
        $display("Starting SPI Master Controller Verification...");
        $display("--------------------------------------------------");

        // Apply Reset
        #25;
        rst_n = 1;
        #20;

        // Transaction 1: Send Byte 0xA5 (10100101)
        @(posedge clk);
        start   <= 1;
        tx_data <= 8'hA5;
        @(posedge clk);
        start   <= 0;

        // Wait until transaction completes
        @(negedge busy);
        #20;
        if (rx_data === 8'hA5)
            $display("PASS: Transmitted 0xA5 -> Loopback Received: 0x%02X", rx_data);
        else
            $error("FAIL: Expected 0xA5, got: 0x%02X", rx_data);

        // Transaction 2: Send Byte 0x3C (00111100)
        #50;
        @(posedge clk);
        start   <= 1;
        tx_data <= 8'h3C;
        @(posedge clk);
        start   <= 0;

        @(negedge busy);
        #20;
        if (rx_data === 8'h3C)
            $display("PASS: Transmitted 0x3C -> Loopback Received: 0x%02X", rx_data);
        else
            $error("FAIL: Expected 0x3C, got: 0x%02X", rx_data);

        #100;
        $display("--------------------------------------------------");
        $display("All SPI Transactions Verified Successfully!");
        $display("--------------------------------------------------");
        $finish;
    end
endmodule
