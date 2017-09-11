#!/usr/bin/perl -w

die "perl $0 <PanGene.matrix> <cov limit> <prefix of output>" if(@ARGV!=3);
my $pan=shift;
my $cov=shift;
my $prefix=shift;

open IN,"$pan" or die "$!";
open OUT,">PanGene.matrix.$prefix" or die "$!";

my $head=<IN>;
$head=~ s/\s*$//g;
$head="Group$head\n";
print OUT "$head";
while(<IN>){
	chomp;
	$_=~ s/\s*$//g;
	my @arr=split(/\t/,$_);
	my $pan_gene_id=shift @arr;
	my $line="$pan_gene_id";
	foreach my $k(@arr){
		if($k<$cov){
			$line.="\t0"
		}else{
			$line.="\t$k"
			
		}
	}
	$line.="\n";
	print OUT "$line";
}
close IN;
