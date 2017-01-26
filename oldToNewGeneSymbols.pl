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


# Get file handles 
my $queryFh   = getFh("<", $query);
my $outFh     = getFh(">", $outFile);
my $symbolsFh = getFh("<", "Homo_sapiens.gene_info");


# Get the symbols hash reference 
# key: symbols 
# values: symbols to be transformed to
my $symbolsHashRef = createSymbolsHash($symbolsFh);

# Now we are going to print out the latest symbols 
printSymbols($symbolsHashRef, $queryFh, $outFh);


################################################################################
# scalar = getFh($symbol, $file);
################################################################################
# Returns the filehandle for the file
# '<' used for reading, '>' for writing, '>>' for appending
################################################################################
 
sub getFh{
    my ($symbol, $file) = @_; 

    my $fh; 
    
    # Check to see if the write symbol is given 
    if ($symbol ne '>' && $symbol ne '<' && $symbol ne '>>'){
	die "Can't use this symbol '", $symbol, "'";
    }

    # Do not open a directory 
    if (-d $file){
	die "The file you provided is a directory";
    }

    # Opening the file 
    unless (open ($fh, $symbol, $file)){
	die "Can't open ", $!; 
    }

    return ($fh);

}


################################################################################
# scalar = createSymbolsHash($filehandle)
################################################################################
# Creates a look up hash that will have symbols as keys and the values are the 
# symbols that they will be transformed into.
# We want it to be case insensitive so we set the keys to be all upper case
# Returns a hash reference
################################################################################
sub createSymbolsHash{
    my ($fh) = @_;

    my %hash;

    # Go through the file line by line
    while (<$fh>){
	chomp;

        my $line = $_;
	
	# Splitting the line and storing into an array 
        # The indexes we are interested in are the 2 (latest symbols)
	# and 4 (old symbols) 
        my @array = split/\t/,$line;
        
	# Storing the values we are interested in 
        my $latestSym = $array[2];
        my $oldSym    = $array[4];
    
        # We don't want to store the header so we skip it 
        if ($latestSym eq 'Symbol'){
	    next;
	} 
        
	# We want to have new symbol as a key and value 
	# the latest symbol can potentially be in the query file 
	$hash{uc($latestSym)} = $latestSym;
         
        # We need to separate the old symbols which could be separated by |
	my @oldSymArray = split/\|/,$oldSym;
	
        # For loop to go through the array and set the gene symbol to the 
	# latest symbol	in the hash 
	# Skip over '-'
 	for my $geneSym (@oldSymArray){
	    if ($geneSym eq '-'){
		next;
	    } else { 
		$hash{uc($geneSym)} = $latestSym;
	    }
	}

    }
    
    return(\%hash);
}


################################################################################
# printSymbols($lookupHash, $queryFh, $outFh)
################################################################################
# The subroutine will look at the query file one line at a time and check to see
# if it exists in the lookup hash. They query gene symbol is made uppercase 
# because we wanted it to be case insensitive matching.
# The results will be printed to an output file.
################################################################################
sub printSymbols{
    my ($hashRefSym, $fhQuery, $fhOut) = @_;

    # Going line by line through the query file 
    while (<$fhQuery>){
	chomp; 
	my $queryGene = uc($_);
	exists $hashRefSym->{$queryGene} ? 
	    say $fhOut $hashRefSym->{$queryGene} :
	    say $fhOut "Latest gene symbol for ", $_, " could not be found";
    }

}



