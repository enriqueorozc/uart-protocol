///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: This file details the implementation of the UART protocol
// with error detection using an even parity bit. This design instantiates
// the transmitter and receiver modules and connects the two. Subsequent data
// must wait until the previous transaction has been completed.
///////////////////////////////////////////////////////////////////////////////

module uart #(
  parameter int TX_CLK_FREQ = 100_000_000,
  parameter int RX_CLK_FREQ = 50_000_000,
  parameter int BAUD_RATE = 115_200,
  parameter int DATA_WIDTH = 8
) (
  input logic tx_clk,
  input logic rx_clk,
  uart_if.rx rx_if,
  uart_if.tx tx_if
);

  // Transmitter Connection:
  uart_tx #(TX_CLK_FREQ, BAUD_RATE) tx (
    .clk(tx_clk), .tx_packet(tx_if)
  );

  // Receiver Connection:
  uart_rx #(RX_CLK_FREQ, BAUD_RATE) rx (
    .clk(rx_clk), .rx_packet(rx_if)
  );

endmodule