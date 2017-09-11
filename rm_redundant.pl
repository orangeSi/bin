#!/usr/bin/perl -w
die "perl $0 <self2self.blast.m6> <self.fasta> <prefix of output> <identity;default 96> <cov;default:0.4>\n" if(@ARGV<3);

use File::Basename;
use Math::Complex;
use List::Util qw (max);

my $blast=shift;
my $genome=shift;
my $prefix=shift;
my $indentity=shift;
my $cov=shift;
$cov ||=0.4;
$indentity ||=96;
my $outdir=dirname($prefix);
my %length;
my %unkeep;
my %blast;
`fastalength $genome >$outdir/genome.len`;
foreach my $k(`cat $outdir/genome.len`){
	my ($len,$id)=split(/\s+/,$k);
	$length{$id}=$len;
}

open M6,"$blast" or die "$!";
while(<M6>){
	chomp;
	my @arr=split(/\s+/,$_);
	next if($arr[2]< $indentity);
	#print "i is $indentity,is $arr[2]\n";
	my $qId=$arr[0];
	my $tId=$arr[1];
	next if($qId eq $tId);
	my $qMatchLen=abs($arr[6]-$arr[7]);
	my $tMatchLen=abs($arr[8]-$arr[9]);
	$blast{$qId.$tId}{qid}=$qId;
	push @{$blast{$qId.$tId}{MatchLen}},$qMatchLen;

}
close M6;

my %keep;
foreach my $k(keys %blast){
	my $max=max(@{$blast{$k}{MatchLen}});
	my $ratio=$max/$length{$blast{$k}{qid}};
	if($ratio > $cov){
		$unkeep{$blast{$k}{qid}}=$ratio;
#		print "$blast{$k}{qid} not keep;$k\n";

	}else{
		$keep{$blast{$k}{qid}}=$ratio;		
	}
#	print "$k $ratio\n";

}
open KEEP,">$outdir/$prefix.keep.list" or die "$!";
open UNKEEP,">$outdir/$prefix.unkeep.list" or die "$!";
foreach my $k(keys %length){
	if(!exists $unkeep{$k}){
		$keep{$k}=0 if(!exists $keep{$k});
		print KEEP $k,"\t$keep{$k}\n";
	}else{
		print UNKEEP $k,"\t$unkeep{$k}\n";
		
	}
}

close KEEP;
close UNKEEP;
