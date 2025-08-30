///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// AUTHORS: Enrique Orozco Jr. <enrique-orozco@outlook.com>
///////////////////////////////////////////////////////////////////////////////

module uart_tx(uart_if uart);

  parameter int CLK_FREQ = 100_000_000;
  parameter int BAUD_RATE = 115_200;

  localparam int CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
  localparam int COUNTER_WIDTH = $clog2(CYCLES_PER_BIT);

  logic [COUNTER_WIDTH-1:0] cycle_counter;
 

endmodule