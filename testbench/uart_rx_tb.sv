///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_rx_tb.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: WIP
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module uart_rx_tb();

  localparam int DATA_WIDTH = 8;
  localparam int CLK_FREQ = 50_000_000;
  localparam int BAUD_RATE = 115_200;

  // Clock Generation:
  localparam real CLK_PERIOD = 1_000_000_000.0 / CLK_FREQ;
  logic clk, reset;

  initial clk = 0;
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Create Interface Object:
  uart_if #(DATA_WIDTH) rx_if();

  // DUT Connection:
  uart_rx #(CLK_FREQ, BAUD_RATE) dut (
    .clk(clk), .rx_packet(rx_if.rx)
  );

  initial begin

    // Interface Connection:
    rx_if.TxD = 1;
    rx_if.reset = 0;

    repeat(10) @(posedge clk);

    // Reset Receiver:
    rx_if.reset = 1;
    @(posedge clk);
    rx_if.reset = 0;
    @(posedge clk);

    $finish;
  end

endmodule