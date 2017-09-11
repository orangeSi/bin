#!/usr/bin/perl -w

use Getopt::Long;
use PerlIO::gzip;

my ($blast,$query,$ref,$indentity,$coverage_q,$coverage_r,$prefix,$outdir,$pvalue);
GetOptions(
	"blast:s" =>\$blast,
	"query:s" =>\$query,
	"ref:s" =>\$ref,
	"indentity:f" =>\$indentity,
	"coverage_q:f" =>\$coverage_q,
	"coverage_r:f" =>\$coverage_r,
	"pvalue:f"	=>\$pvalue,
	"prefix:s" =>\$prefix,
	"outdir:s" =>\$outdir,
);
my $usage="
perl $0 
	--blast		<blast.m6 or gz> 
	--query		<query.fa or gz> 
	--ref		<ref.fa or gz> 
	--indentity	<identity:0-100>
	--pvalue	<p_value ,ex 1e-5>
	--coverage_q	<coverage ratio in query:0-100> 
	--coverage_r	<coverage ratio in ref:0-100>
	--prefix
	--outdir

writed by myth 2016-11-29
";

die "$usage\n" if(!$blast || !$indentity || !$indentity || (not defined $coverage_q) || (not defined $coverage_r) || (not defined $pvalue));
$coverage_q =$coverage_q /100;
$coverage_r =$coverage_r /100;

my %len;
if($query){
	die "error:query need coverage_q\n" if(! defined $coverage_q);
	print "coverage_q is $coverage_q\n";
	open QU,"<:gzip(autopop)","$query" or die "$!";
	$/=">";<QU>;
	while(<QU>){
		chomp;
		my @arr=split(/\n/,$_,2);
		$arr[0]=~ /^(\S+)/;
		my $id=$1;
		$arr[1]=~ s/\s+//g;
		$len{'q'}{"$id"}=length $arr[1];
	}
	close QU;
	$/="\n";
}



if($ref){
	die "error:ref nedd coverage_r\n" if(! defined $coverage_r);
	print "coverage_r is $coverage_r\n";
	open QU,"<:gzip(autopop)","$ref" or die "$!";
	$/=">";<QU>;
	while(<QU>){
		chomp;
		my @arr=split(/\n/,$_,2);
		$arr[0]=~ /^(\S+)/;
		my $id=$1;
		$arr[1]=~ s/\s+//g;
		$len{'r'}{"$id"}=length $arr[1];
	}
	close QU;
	$/="\n";
}



open M6,"<:gzip(autopop)","$blast" or die "$!";
open OUT,">$outdir/$prefix\_filter_indentity$indentity\_covq$coverage_q\_covr$coverage_r.evalue$pvalue.m6" or die "$!";

while(<M6>){
	chomp;
	next if($_=~ /^#/);
	my @arr=split(/\t/,$_);
	next if($arr[2]<$indentity || $arr[10]>$pvalue);
	my $q_cov=($query)? (abs($arr[6]-$arr[7]))/$len{'q'}{$arr[0]}:0;
	my $r_cov=($ref)? (abs($arr[8]-$arr[9]))/$len{'r'}{$arr[1]}:0;
	next if(($query && ($q_cov<$coverage_q)) || ($ref && ($r_cov< $coverage_r)));
	
	print OUT "$_\t$q_cov\t$r_cov\n";
}
close M6;
close OUT;
