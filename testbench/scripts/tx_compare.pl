#!/usr/bin/env perl

###############################################################################
## PROJECT: UART Communication System with Error Detection
###############################################################################
## FILENAME: tx_compare.pl
## AUTHOR: Enrique Orozco Jr. <enrique-orozco@outlook.com>
## DESCRIPTION: WIP
###############################################################################

use strict;
use warnings;

use feature 'say';
use File::Path 'make_path';

# Check Output Directory + Destination File:
my $OUTPUT_DIR = "../outputs";
make_path($OUTPUT_DIR) unless -d $OUTPUT_DIR;
my $DEST_FILE = "../outputs/simCompare.txt";

# Open the Destination File:
open (FHW, '>', $DEST_FILE);

# Open the Simulation Output File:
my $INPUT_FILE = '../outputs/simOutput.txt';
open(FH, '<', $INPUT_FILE) or die "simOutput.txt does not exist";




