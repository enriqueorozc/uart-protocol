#!/usr/bin/env perl

###############################################################################
## PROJECT: UART Communication System with Error Detection
###############################################################################
## FILENAME: generate_stimulus.pl
## AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
## DESCRIPTION: This script generates a random data vector to be utilized
## as stimulus for the UART transmitter and receiver.
###############################################################################

use strict;
use warnings;

use feature 'say';
use File::Path 'make_path';

# Check Output Directory + Destination File:
my $OUTPUT_DIR = "../outputs";
make_path($OUTPUT_DIR) unless -d $OUTPUT_DIR;
my $DEST_FILE = "../outputs/stimulus.txt";

# Test Configuration Parameters (CHANGE THESE):
my $TEST_POINTS = 10;
my $DATA_WIDTH = 8;

# Create Range from DATA_WIDTH:
my $MAX_VALUE = (2**$DATA_WIDTH);
my @DATA_RANGE = (0 .. $MAX_VALUE - 1);

# Open Destination file:
open(FHW, '>', $DEST_FILE);

# Generating the Data Points:
for (my $count = 0; $count < $TEST_POINTS; $count++) {
  my $index_bit = int(rand($MAX_VALUE));

  # Ensure Clean .txt Output:
  if ($count == $TEST_POINTS - 1) {
    print FHW $DATA_RANGE[$index_bit];
  } else {
    say FHW $DATA_RANGE[$index_bit];
  }
}

# Closing the Destination file:
close(FHW);