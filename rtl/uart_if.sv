///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_if.sv
// AUTHORS: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: This file describes the encapsulation of all the wires 
// that will be utilized in the UART communication system.
///////////////////////////////////////////////////////////////////////////////

interface uart_if
  #(parameter DATA_WIDTH = 8);

  // Shared Input:
  logic reset;

  // Transmitter Inputs:
  logic [DATA_WIDTH-1:0] TxData;
  logic transmit;

  // Transmitter Outputs:
  logic TxD;
  logic busy;

  // Receiver Outputs:
  logic [DATA_WIDTH-1:0] RxData;
  logic valid_rx;

  modport tx (
    input TxData,
    input transmit,
    input reset,
    output TxD,
    output busy
  );

  modport rx (
    input TxD,
    input reset,
    output RxData,
    output valid_rx
  );

endinterface