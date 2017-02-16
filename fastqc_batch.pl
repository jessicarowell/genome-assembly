#!/data/home/jrowell32/perl/bin/perl

use strict;
use Getopt::Long;
use File::Basename;
use File::Temp;

my $script = basename($0); 
my ($inDir, $outDir);

if (@ARGV < 1){
	usage(); 
	exit 1;
}

GetOptions ('o=s' => \$outDir, 
			'in=s' => \$inDir);
			
die usage() unless ((defined $outDir) && (defined $inDir));
	
my @list = glob("$inDir/*.fa*");

foreach my $file (@list) {
	my $fileb = basename($file);
	print "Running FastQC on $fileb.\n";
	`fastqc -o $outDir $file 2>$outDir/fastqc.log`;
}

exit;


sub usage{
    warn <<"EOF";
USAGE
  $script -o <outdir> -in <indir> 
  
DESCRIPTION
  Runs FastQC on a directory of reads 
	and outputs statistics in the specified output directory
  See the fastqc.log file in the output directory 
  See FastQC documentation for more info
	
OPTIONS
  -in	dir		Directory with FASTQ files
  -o    dir		Directory for output files
  
EXAMPLES
  $script -o ./fastqc_results -in ../reads/
  $script -h
  
EXIT STATUS
  0     Successful completion
  >0    An error occurred

EOF
}