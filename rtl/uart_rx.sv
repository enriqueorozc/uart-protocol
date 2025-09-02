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
  localparam int OVERSAMPLE_RATE = 16;    // DO NOT CHANGE
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
  logic tickAdvancement, bitReceived, dataReceived, halfAligned, resetTick;
  
  assign tickAdvancement = (cycle_counter == CYCLES_PER_TICK - 1);
  assign bitReceived = (tick_counter == OVERSAMPLE_RATE - 1 && tickAdvancement);
  assign resetTick = (tick_counter == 6 && tickAdvancement && !halfAligned);
  assign dataReceived = (bits_received == DATA_WIDTH);

  always_comb begin
    case (currState)
      IDLE: nextState = (!rx_packet.TxD) ? START : IDLE;
      START: nextState = (halfAligned) ? DATA : START;
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
  assign rx_if.valid_rx = (currState == STOP && parity == parity_received);

  // Receiving Data:
  always_ff @(posedge clk) begin

    if (rx_packet.reset) begin
      rx_packet.RxData <= 0;
      cycle_counter <= 0;
      tick_counter <= 0;
      bits_received <= 0;
      halfAligned <= 0;
      parity_received <= 0;
    end else begin
      case (currState)

        IDLE: begin
          bits_received <= 0;
          halfAligned <= 0;
        end

        START: begin
          cycle_counter <= (tickAdvancement) ? 0 : cycle_counter + 1;
          
          // No Longer Need to Reset Counter Halfway
          if (resetTick) begin
            halfAligned <= 1;
          end

          // Properly Align 'tick_counter':
          tick_counter <= (bitReceived || resetTick) ? 0 : 
            (tickAdvancement) ? tick_counter + 1 : tick_counter;

        end

        DATA: begin
          cycle_counter <= (tickAdvancement) ? 0 : cycle_counter + 1;
          bits_received <= (bitReceived) ? bits_received + 1 : bits_received;
          tick_counter <= (bitReceived) ? 0 :
            (tickAdvancement) ? tick_counter + 1 : tick_counter;
          
          // Shift-in LSB First:
          if (bitReceived) begin
            rx_packet.RxData <= {rx_packet.TxD, rx_packet.RxData[DATA_WIDTH-1:1]};
          end

        end

        PARITY: begin
          cycle_counter <= (tickAdvancement) ? 0 : cycle_counter + 1;
          tick_counter <= (bitReceived) ? 0 :
            (tickAdvancement) ? tick_counter + 1 : tick_counter;

          if (bitReceived) begin
            parity_received <= rx_packet.TxD;
          end

        end

        STOP: begin
          cycle_counter <= (tickAdvancement) ? 0 : cycle_counter + 1;
          tick_counter <= (bitReceived) ? 0 :
            (tickAdvancement) ? tick_counter + 1 : tick_counter;
        end

      endcase
    end

  end

endmodule