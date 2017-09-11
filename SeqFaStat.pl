#!/usr/bin/perl -w
use strict;
use File::Path;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';
use FindBin qw($Bin);
use lib "$Bin/";
use ToolKit;

#================ Getopt::Long =======================
my ($sample,$fasta,$output,$cutoff);
GetOptions(
	"sample:s"		=>\$sample,
	"fasta:s"		=>\$fasta,
	"cutoff:s"		=>\$cutoff,
	"output:s"		=>\$output,
);
my $usage=<<USAGE;
Description:

       Fasta Seq Stat Model

Usage: perl $0 [options]
	--sample<str>		Specify sample name
	--fasta<str>		Specify fasta file.
	--cutoff<number>	Specify not stat scaffold length less than this,default 500.
        --output<str>		Specify Stat file.
USAGE
die $usage if (!$fasta);
#=======================================================
$sample ||= "Seq";
$cutoff ||= 500;
$output ||= "$ENV{'PWD'}/SeqStat"; 
open OUT, ">$output" or die "Can't write file $output ~~~~\n";
print OUT "Sample Name\tTotal Number (#)\tTotal Length (bp)\tN50 Length (bp)\tN90 Length (bp)\tAverage Length (bp)\tMax Length (bp)\tMin Length (bp)\tGC Content (%)\n";
die "Fasta file $fasta not exists ~~~\n" unless -e $fasta;
&SeqStat($sample,$fasta,*OUT);

#================ Sub  Code =============================

sub SeqStat{
	my ($sample,$fasta) = @_;
	my ($length,$all_seq,$all_length,$num,%seq,%length,$GC,$AT,$GC_rate,@Stat,$IDLength);
	open FA,"$fasta" or die "Can't open file $fasta ~~~ \n";
	$/ = ">";<FA>;
	while(<FA>){
		chomp;
		my @line = split /\n/,$_;
		my $id = (split /\s+/,$line[0])[0];
		shift @line;
		my $seq = join '',@line;
		$length = length $seq;
		if($length <$cutoff){next}
		$seq{$id} = $seq;
		$length{$id} = $length;
		$all_seq .= $seq;
	}
	$all_length = length $all_seq;
	my $temp = $all_seq;
	$GC = $temp =~ tr/AT//c;
	$AT = $temp =~ tr/GC//c;
	$GC_rate = $GC / ($GC + $AT) * 100;
	($GC_rate) = ToolKit::DecimalPlaces("2",$GC_rate);
	my @StatLength = &StatLength(\%length,$all_length);
	print OUT "$sample\t";
	foreach my $temp (@StatLength){
		print OUT "$temp\t";
	}
	print OUT "$GC_rate\n";
}

#================== Sub code ==================
sub StatLength{
	my (%length,$all_length,$num,$N50,$N90,$average,$max,$min,$temp_length,$control_N50,$control_N90,@StatLength,$IDLength);
	%length =  %{$_[0]};
	$all_length = $_[1];
	$num = scalar (keys %length);
	($max,$min,$temp_length,$control_N50,$control_N90) = (0,$all_length,0,1,1);
	foreach my $id (sort {$length{$b}<=>$length{$a}} keys %length){
		$max = $length{$id} if $length{$id} >= $max;
		$min = $length{$id} if $length{$id} <= $min;
		$temp_length += $length{$id};
		if($temp_length > (0.5 * $all_length) && $control_N50){
			$N50 = $length{$id};
			$control_N50 = 0;
		}
		if($temp_length > (0.9 * $all_length) && $control_N90){
			$N90 = $length{$id};
			$control_N90 = 0;
		}
	}
	($average) = ToolKit::DecimalPlaces("2",$all_length/$num);
	push @StatLength,($num,$all_length,$N50,$N90,$average,$max,$min);
	@StatLength = ToolKit::Thousands(@StatLength);
	return @StatLength;
}

