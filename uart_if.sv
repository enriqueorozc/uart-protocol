interface uart_if;

  // Shared Inputs:
  logic clk;
  logic reset;

  // Transmitter Inputs:
  logic transmit;
  logic [7:0] TxData;

  // Transmitter Outputs:
  logic TxD;
  logic busy;

  // Receiver Outputs:
  logic [7:0] RxData;
  logic valid_rx;

endinterface