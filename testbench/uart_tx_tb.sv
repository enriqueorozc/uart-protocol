///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_tx_tb.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: This testbench uses a file-based verification method to test
// the UART transmitter. It works in conjunction with the 'generate_stimulus'
// and 'tx_compare' scripts that help generate random data vectors and compare
// the output of the DUT. To properly test the UART transmitter, run
// 'generate_stimulus', this testbench, and then 'tx_compare.'
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module uart_tx_tb();

  localparam int DATA_WIDTH = 8;
  localparam int CLK_FREQ = 100_000_000;
  localparam int BAUD_RATE = 115_200;

  localparam int CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
  localparam int FRAME_WIDTH = DATA_WIDTH + 3;  // Start, Parity, Stop
  logic [FRAME_WIDTH-1:0] tx_output;

  // Clock Generation:
  localparam real CLK_PERIOD = 1_000_000_000.0 / CLK_FREQ;
  logic clk;

  initial clk = 0;
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Create Interface Object
  uart_if #(DATA_WIDTH) tx_if();

  // DUT Connection:
  uart_tx #(CLK_FREQ, BAUD_RATE) dut (
    .clk(clk), .tx_packet(tx_if.tx)
  );

  // Simulation Parameter + File:
  integer simulation_file;
  integer end_flag = 0;

  // Data Vector File:
  integer test_points = 10;
  integer data_count = 0;
  integer stimulus_file;

  // Simulation Output Helper: Writes the data and the
  // parity bits to the simulation file for later debugging
  task automatic write_output(input [FRAME_WIDTH-1:0] data_frame);
    int data = data_frame[FRAME_WIDTH-2:2];
    int parity = data_frame[1];
    $fwrite(simulation_file, "%0d-%0d\n", data, parity);
  endtask

  initial begin

    // Open the Random Stimulus File (CHANGE AS NEEDED):
    stimulus_file = $fopen("C:/Users/Enriq/Documents/personal/uart-controller/testbench/outputs/stimulus.txt", "r");
    if (stimulus_file == 0) begin
      $fatal(1, "ERROR: Could not open stimulus.txt");
    end

    // Create the Simulation Output File (CHANGE AS NEEDED):
    simulation_file = $fopen("C:/Users/Enriq/Documents/personal/uart-controller/testbench/outputs/tx_simOutput.txt", "w");
    if (simulation_file == 0) begin
      $fatal(1, "ERROR: Could not create tx_simOutput.txt");
    end

    // Interface Connections:
    tx_if.TxData = 0;
    tx_if.transmit = 0;
    tx_if.reset = 0;

    // Transmitter Output:
    tx_output = 0;

    repeat(10) @(posedge clk);

    // Reset Transmitter:
    tx_if.reset = 1;
    @(posedge clk);
    tx_if.reset = 0;
    @(posedge clk);

    while (!end_flag) begin

      // Read Data from Stimulus:
      $fscanf(stimulus_file, "%d\n", tx_if.TxData);
      data_count++;

      tx_if.transmit = 1;
      @(posedge clk);

      tx_if.transmit = 0;
      for (int i = FRAME_WIDTH - 1; i >= 0; i--) begin
        repeat(CYCLES_PER_BIT) @(posedge clk);  
        tx_output[i] = tx_if.TxD;
      end

      @(posedge clk iff !tx_if.busy);
      write_output(tx_output);
      end_flag = (data_count == test_points);

    end

    $fclose(stimulus_file);
    $finish;
  end

endmodule