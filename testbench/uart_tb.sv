///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_tb.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: This testbench uses a directed verification approach to
// test the UART protocol communication between the transmitter and the
// receiver. It clocks a string (message) into the transmitter and compares 
// it to what is output by the receiver (RxData).
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module uart_tb();

  // Clock Parameters:
  localparam int TX_CLK_FREQ = 100_000_000;
  localparam int RX_CLK_FREQ = 50_000_000;
  localparam int BAUD_RATE = 115_200;

  // Data Packet Parameters + Array:
  byte message[7] = {"E", "N", "R", "I", "Q", "U", "E"};
  localparam int DATA_WIDTH = 8;

  // Clock Generation:
  localparam real TX_CLK_PERIOD = 1_000_000_000.0 / TX_CLK_FREQ;
  localparam real RX_CLK_PERIOD = 1_000_000_000.0 / RX_CLK_FREQ;
  logic tx_clk, rx_clk;

  initial tx_clk = 0;
  always #(TX_CLK_PERIOD / 2) tx_clk = ~tx_clk;

  initial rx_clk = 0;
  always #(RX_CLK_PERIOD / 2) rx_clk = ~rx_clk;

  // Create Interface Object:
  uart_if #(DATA_WIDTH) uart_interface();

  // DUT Connection:
  uart #(TX_CLK_FREQ, RX_CLK_FREQ, BAUD_RATE, DATA_WIDTH) dut (
    .tx_clk(tx_clk), .rx_clk(rx_clk), 
    .rx_if(uart_interface.rx),
    .tx_if(uart_interface.tx)
  );

  initial begin

    // Interface Connection:
    uart_interface.transmit = 0;
    uart_interface.reset = 0;
    uart_interface.TxData = 0;

    repeat(10) @(posedge tx_clk);

    // Reset TX/RX:
    uart_interface.reset = 1;
    @(posedge rx_clk);
    uart_interface.reset = 0;
    repeat(10) @(posedge rx_clk);

    for (int i = 0; i < 7; i++) begin
      uart_interface.TxData = message[i];
      uart_interface.transmit = 1;
      @(posedge tx_clk)
      #90000;

      @(negedge tx_clk iff !uart_interface.busy);
      assert(uart_interface.RxData && message[i]);     
    end

    $finish;
  end

endmodule