///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_tx.sv
// AUTHORS: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: WIP
///////////////////////////////////////////////////////////////////////////////

module uart_tx #(
  parameter int CLK_FREQ = 100_000_000,
  parameter int BAUD_RATE = 115_200
) (
  input logic clk,
  uart_if.tx tx_packet
);
  
  // Timing Parameters:
  localparam int CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
  localparam int COUNTER_WIDTH = $clog2(CYCLES_PER_BIT);
  logic [COUNTER_WIDTH-1:0] cycle_counter;

  // FSM Enum + Parameters:
  typedef enum logic [2:0] {
    IDLE,
    START,
    DATA,
    PARITY,
    STOP
  } statetype;

  statetype currState, nextState;

  // Transmission Parameters:
  localparam int DATA_WIDTH = tx_packet.DATA_WIDTH;
  localparam int DATA_BITS = $clog2(DATA_WIDTH);

  logic [DATA_WIDTH-1:0] tx_shift;
  logic [DATA_BITS-1:0] bit_index;
  logic sending;

  // Next-State Logic (Combinational):
  logic bitTransmitted, dataTransmitted;
  assign bitTransmitted = (cycle_counter == CYCLES_PER_BIT - 1);
  assign dataTransmitted = (bit_index == DATA_WIDTH - 1 && bitTransmitted);

  always_comb begin
    case (currState)
      IDLE: nextState = (tx_packet.transmit) ? START : IDLE;
      START: nextState = bitTransmitted ? DATA : START;
      DATA: nextState = dataTransmitted ? PARITY : DATA;
      PARITY: nextState = bitTransmitted ? STOP : PARITY;
      STOP: nextState = bitTransmitted ? IDLE : STOP;
      default: nextState = IDLE;
    endcase
  end

  // Next-State Logic (Sequential):
  always_ff @(posedge clk) begin
    if (reset) currState <= IDLE;
    else currState <= nextState;
  end

endmodule