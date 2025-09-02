///////////////////////////////////////////////////////////////////////////////
// PROJECT: UART Communication System with Error Detection
///////////////////////////////////////////////////////////////////////////////
// FILENAME: uart_rx_tb.sv
// AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
// DESCRIPTION: This testbench uses a file-based verification method to test
// the UART receiver. It works in conjunction with the 'generate_stimulus'
// and 'rx_compare' scripts that help generate random data vectors and compare
// the output of the DUT. To properly test the UART receiver, run
// 'generate_stimulus', this testbench, and then 'rx_compare.'
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module uart_rx_tb();

  localparam int DATA_WIDTH = 8;
  localparam int CLK_FREQ = 50_000_000;
  localparam int BAUD_RATE = 115_200;

  localparam int CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
  logic [DATA_WIDTH-1:0] rx_data;

  // Clock Generation:
  localparam real CLK_PERIOD = 1_000_000_000.0 / CLK_FREQ;
  logic clk;

  initial clk = 0;
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Create Interface Object:
  uart_if #(DATA_WIDTH) rx_if();

  // DUT Connection:
  uart_rx #(CLK_FREQ, BAUD_RATE) dut (
    .clk(clk), .rx_packet(rx_if.rx)
  );

  // Simulation Parameter + File:
  integer simulation_file;
  integer end_flag = 0;

  // Data Vector File:
  integer test_points = 10;
  integer data_count = 0;
  integer stimulus_file;
  
  // UART Transaction Helper: Writes the data sequentially to the
  // TxD line in accordance to the UART protocol
  task send_data(input logic [DATA_WIDTH-1:0] data);

    // Initiate UART Sequence:
    rx_if.TxD = 0;
    repeat(CYCLES_PER_BIT) @(posedge clk);

    // Send Data Bits (LSB-first):
    for (int i = 0; i < DATA_WIDTH; i++) begin
      rx_if.TxD = data[i];
      repeat(CYCLES_PER_BIT) @(posedge clk);
    end

    // Send Parity Bit:
    rx_if.TxD = ^data;
    repeat(CYCLES_PER_BIT) @(posedge clk);

    // Send Stop Bit:
    rx_if.TxD = 1;
    repeat(CYCLES_PER_BIT / 4) @(posedge clk);

    // Write the Output:
    $fwrite(simulation_file, "%0d-%0d\n", rx_if.RxData, rx_if.valid_rx);

    repeat(3 * CYCLES_PER_BIT / 4) @(posedge clk);

  endtask

  initial begin

    // Open the Random Stimulus File (CHANGE AS NEEDED):
    stimulus_file = $fopen("C:/Users/Enriq/Documents/personal/uart-controller/testbench/outputs/stimulus.txt", "r");
    if (stimulus_file == 0) begin
      $fatal(1, "ERROR: Could not open stimulus.txt");
    end

    // Create the Simulation Output File (CHANGE AS NEEDED):
    simulation_file = $fopen("C:/Users/Enriq/Documents/personal/uart-controller/testbench/outputs/rx_simOutput.txt", "w");
    if (simulation_file == 0) begin
      $fatal(1, "ERROR: Could not create rx_simOutput.txt");
    end

    // Interface Connection:
    rx_if.TxD = 1;
    rx_if.reset = 0;

    repeat(10) @(posedge clk);

    // Reset Receiver:
    rx_if.reset = 1;
    @(posedge clk);
    rx_if.reset = 0;
    @(posedge clk);

    while (!end_flag) begin

      // Read Data from Stimulus:
      $fscanf(stimulus_file, "%d\n", rx_data);
      data_count++;

      // Send the Data (Parallel):
      send_data(rx_data);
      end_flag = (data_count == test_points);

    end

    $finish;
  end

endmodule