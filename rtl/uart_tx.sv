///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_tx.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: This file details the implementation of the UART transmitter
// with an even parity bit. This design uses a 5-state Moore FSM to implement
// the transmitter. Subsequent data must wait until the previous transaction
// has been completed.
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

  logic [DATA_BITS-1:0] bit_index;
  logic [DATA_WIDTH-1:0] tx_shift;

  // Next-State Logic (Combinational):
  logic bitTransmitted, dataTransmitted;
  assign bitTransmitted = (cycle_counter == CYCLES_PER_BIT - 1);
  assign dataTransmitted = (bit_index == 0 && bitTransmitted);

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
    if (tx_packet.reset) currState <= IDLE;
    else currState <= nextState;
  end

  // Even-Parity Detection:
  logic parity;
  assign parity = ^tx_shift;

  // Transmitting Data:
  always_ff @(posedge clk) begin

    if (tx_packet.reset) begin
      tx_packet.TxD <= 1;
      tx_packet.busy <= 0;
      cycle_counter <= 0;
      bit_index <= 0;
      tx_shift <= 0;
    end else begin

      case (currState) 

        IDLE: begin
          tx_packet.TxD <= 1;
          tx_packet.busy <= 0;
          cycle_counter <= 0;
          bit_index <= 0;
          tx_shift <= 0;
        end

        START: begin
          tx_packet.TxD <= 0;
          tx_packet.busy <= 1;
          tx_shift <= tx_packet.TxData;
          bit_index <= DATA_WIDTH - 1;    // LSB-first
          cycle_counter <= (bitTransmitted) ? 0 : cycle_counter + 1;
        end

        DATA: begin
          tx_packet.TxD <= tx_shift[bit_index];
          tx_packet.busy <= 1;
          bit_index <= (bitTransmitted) ? bit_index - 1 : bit_index;
          cycle_counter <= (bitTransmitted) ? 0 : cycle_counter + 1;
        end

        PARITY: begin
          tx_packet.TxD <= parity;
          tx_packet.busy <= 1;
          cycle_counter <= (bitTransmitted) ? 0 : cycle_counter + 1;
        end

        STOP: begin
          tx_packet.TxD <= 1;
          tx_packet.busy <= 1;
          cycle_counter <= (bitTransmitted) ? 0 : cycle_counter + 1;
        end

      endcase
    end

  end

endmodule