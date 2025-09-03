# UART Communication System with Error Detection

## Overview:
A UART Communication System with Oversampling and Error Detection through a even-parity bit. This project implements the UART communication protocol as implemented with a receiver (rx) and transmitter (tx) that are interconnected. This UART communication system is parameterized by:
- **BAUD_RATE**: The agreement between the tx and rx that specifies the rate to send bits
- **DATA_WIDTH**: The bit-width of the data being transmitted between the tx and rx
- **TK_CLK_FREQ**: The clock frequency at which the transmitter will be operating at
- **RX_CLK_FREQ**: The clock frequency at which the receiver will be operating at

## Output Behavior:
This UART communication system has two primary outputs, defined as:
- **RxData**: The data received by the rx as sent from the tx
- **valid_rx**: The parity flags that checks for an error

The intended behavior of this UART is to clock data into the transmitter, where one must then wait until the busy flag of the transmitter
is no longer high, only then can another transaction occur between the tx and rx. The receiver then oversamples the serial line at a oversampling
rate of 16, once it receives the DATA_WIDTH number of bits, it generates a parity flag and compares it to the parity flag that will be transmitted from the tx. If the generated parity flag from the receiver doesn't match the one received from the serial line, valid_rx will be 0.

## Testing Methodology:
For unit testing, I took a file-based verification method approach to target general cases that would be encountered until normal operation. These unit tests work in conjunction with perl scripts that help generate random stimulus for both the rx and tx, and that compared the output generated from simulation to what was inputted into the modules. 

For end-to-end testing, I took a more directed verification approach as I wanted to see a couple general transactions between the two modules. Since characters are typically 8 bits, I created an array of characters and sent that into the transmitter, and ensure that what was output by the receiver was the same array of characters with correct valid_rx flags.