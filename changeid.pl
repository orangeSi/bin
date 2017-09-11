#!/usr/bin/perl -w
die "perl $0 <r1 or r2 fq.gz> <out.fq.gz> change new read id to old id\n" if(@ARGV!=2);
my $in=shift;
my $out=shift;

open IN,"gzip -dc $in|" or die "$!";
open OUT,"|gzip >$out" or die "$!";
while(<IN>){
	chomp;
	if($_=~ /\/[12]$/){
		print "already new id~\n";
		exit
	}
	$_=~ /^(\S+)\s+(\S+)$/;
	my ($prefix,$tail)=($1,$2);
	if($tail=~ /^1:.*:([ATCG]+)$/){
		$tail="#$1/1"
	}elsif($tail=~ /^2:.*:([ATCG]+)$/){
		$tail="#$1/2"
	}elsif($tail=~ /^1/){
		$tail="#ATCG/1"
	}elsif($tail=~ /^2/){
		$tail="#ATCG/2"
		
	}else{
		die "not valid format:$_~\n";
	}
	print OUT "$prefix$tail\n";
	my $seq=<IN>;chomp $seq;
	my $tag=<IN>;chomp $tag;
	my $qv=<IN>;chomp $qv;
	print OUT "$seq\n$tag\n$qv\n";
}
close IN;
close OUT;

