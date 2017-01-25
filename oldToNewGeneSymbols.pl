#!/usr/bin/perl 
use warnings; 
use strict; 
use feature qw(say); 
use Getopt::Long; 
use Pod::Usage; 

################################################################################
# 
# File		: oldToNewGeneNames.pl
#
################################################################################
# 
# The program takes an input file and a string for the output file. The input
# file ($query) should be a file of gene symbols (one symbol per line) to be 
# converted to the latest symbols, which is based on 
# ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz
# The results will be printed to an output file with the name stored in $outFile.
#
#
################################################################################

my ($query, $outFile); 

# Command Line Options
my $usage = "\n$0 [options]\n\n
Options: 

    -query         Give the file of gene symbols(one symbol per line) to convert
    -outFile	   Give the name of the outfile to store the output
    -help          Show this message

";

GetOptions(
    'query=s'		=>\$query,
    'outFile=s'		=>\$outFile,
    help		=> sub {pod2usage($usage);},
) or pod2usage(2); 

# Check to see if user gave values for the variables 
unless ($query){
    die "\nDying...Make sure to give a query file\n", $usage;
}

unless ($outFile){
    die "\nDying...Make sure to give a name for the outfile\n", $usage;
}


