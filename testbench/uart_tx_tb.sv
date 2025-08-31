///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_tx_tb.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: WIP
///////////////////////////////////////////////////////////////////////////////

timeunit 1ns;
timeprecision 1ns;

module uart_tx_tb();

  localparam int DATA_WIDTH = 8;
  localparam int CLK_FREQ = 100_000_000;
  localparam int BAUD_RATE = 115_200;

  // Clock Generation:
  localparam real CLK_PERIOD = 1_000_000_000.0 / CLK_FREQ;
  logic clk, reset;

  initial clk = 0;
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Create Interface Object
  uart_if #(DATA_WIDTH) tx_if();

  // DUT Connection:
  uart_tx #(CLK_FREQ, BAUD_RATE) dut (
    .clk(clk), .tx_packet(tx_if.tx)
  );

endmodule