#!/data/home/jrowell32/perl/bin/perl

use strict;
use Getopt::Long;
use File::Basename;
use File::Temp;

my $script = basename($0);  
my ($inDir, $outDir, $outDirF);
my ($fastqc, $quiet);

if (@ARGV < 1) { usage(); exit 1; } 	

GetOptions ('o=s' => \$outDir, 'in=s' => \$inDir, 'f' => \$fastqc, 'f_out' => \$outDirF, 'q' => \$quiet);
			
die usage() unless ((defined $outDir) && (defined $inDir));

my ($base, $i);
	
my @list = glob("$inDir/*.fa*");
for ($i = 0; $i < @list; $i += 2){
	$base = $list[$i];
	$base =~ s/_R.\.fastq\.gz//g;
	my $r1 = join('_',$base,"R1.fastq.gz");
	my $r2 = join('_',$base,"R2.fastq.gz");
	my $r1b = basename($r1);
	my $r2b = basename($r2);
	print "Trimming: $r1b and $r2b\n";
	if ($fastqc && $quiet) { quiet_fastqc($r1, $r2); }
	if ($fastqc) { fastqc($r1, $r2); }
	if ($quiet) { quiet($r1, $r2); }
	else {
		print "simple mode\n";
		`trim_galore --illumina --clip_R1 18 --clip_R2 18 --three_prime_clip_R1 5 --three_prime_clip_R2 5 --length 75 --paired $r1  $r2 -o $outDir 2>$outDir/trim_galore.log`;
	}
}

exit;

sub quiet{
	my ($r1, $r2) = ($_[0], $_[1]);
	`trim_galore --illumina --clip_R1 18 --clip_R2 18 --three_prime_clip_R1 5 --three_prime_clip_R2 5 --no_report_file --length 75 --paired $r1  $r2 -o $outDir 2>$outDir/trim_galore.log`;
	next;
}

sub fastqc{
	my ($r1, $r2) = ($_[0], $_[1]);
	`trim_galore --illumina --fastqc --fastqc_args "-o $outDirF" --clip_R1 18 --clip_R2 18 --three_prime_clip_R1 5 --three_prime_clip_R2 5 --length 75 --paired $r1  $r2 -o $outDir 2>$outDir/trim_galore.log`;
	next;
}
	
sub quiet_fastqc{
	my ($r1, $r2) = ($_[0], $_[1]);
	`trim_galore --illumina --fastqc --fastqc_args "-o $outDirF" --clip_R1 18 --clip_R2 18 --three_prime_clip_R1 5 --three_prime_clip_R2 5 --no_report_file  --length 75 --paired $r1  $r2 -o $outDir 2>$outDir/trim_galore.log`;
	next;
}
	
sub usage{
    warn <<"EOF";
USAGE
  $script -o <outdir> -in <indir> 
  
DESCRIPTION
  Runs Trim Galore! on a directory of reads 
	and outputs gzipped, trimmed reads
  The default Trim Galore! options are: 
	Illumina adapters, paired end reads, trim seq lengths < 100, 
	clip 18bp from 5' end, 5bp from 3' end

	See Trim Galore! documentation for more info
	
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
