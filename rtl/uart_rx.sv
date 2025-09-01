///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_rx.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: WIP
///////////////////////////////////////////////////////////////////////////////

module uart_rx #(
  parameter int CLK_FREQ = 50_000_000,
  parameter int BAUD_RATE = 115_200
) (
  input logic clk,
  uart_if.rx rx_packet
);

  // Timing Parameters (Oversampling):
  localparam int OVERSAMPLE_RATE = 16;
  localparam int CYCLES_PER_TICK = CLK_FREQ / (BAUD_RATE * OVERSAMPLE_RATE);
  localparam int CYCLE_COUNTER_WIDTH = $clog2(CYCLES_PER_TICK);
  localparam int TICK_COUNTER_WIDTH = $clog2(OVERSAMPLE_RATE);

  logic [CYCLE_COUNTER_WIDTH-1:0] cycle_counter;
  logic [TICK_COUNTER_WIDTH-1:0] tick_counter;

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
  localparam int DATA_WIDTH = rx_packet.DATA_WIDTH;
  localparam int DATA_BITS = $clog2(DATA_WIDTH);
  logic [DATA_BITS:0] bits_received;

  // Next-State Logic (Combinational):
  logic tickAdvancement, bitReceived, dataReceived;
  assign tickAdvancement = (cycle_counter == CYCLES_PER_TICK - 1);
  assign bitReceived = (tick_counter == OVERSAMPLE_RATE - 1 && tickAdvancement);
  assign dataReceived = (bits_received == bits_received);

  always_comb begin
    case (currState)
      IDLE: nextState = (!rx_packet.TxD) ? START : IDLE;
      START: nextState = (bitReceived) ? DATA : START;
      DATA: nextState = (dataReceived) ? PARITY : DATA;
      PARITY: nextState = (bitReceived) ? STOP : PARITY;
      STOP: nextState = (bitReceived) ? IDLE : STOP;
      default: nextState = IDLE;
    endcase
  end

  // Next-State Logic (Sequential):
  always_ff @(posedge clk) begin
    if (rx_packet.reset) currState <= IDLE;
    else currState <= nextState;
  end

  // Even-Parity Generation (Valid Rx):
  logic parity_received, parity;
  assign parity = ^(rx_packet.RxData);
  assign valid_rx = (currState == STOP && parity == parity_received);

  // Receiving Data:
  always_ff @(posedge clk) begin

    if (rx_packet.reset) begin
      rx_packet.RxData <= 0;
      cycle_counter <= 0;
      tick_counter <= 0;
      bits_received <= 0;
    end else begin
      case (currState)

        

      endcase
    end

  end

endmodule