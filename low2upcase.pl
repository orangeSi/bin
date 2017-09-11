#!/usr/bin/perl -w

die "perl $0 <input.fasta> <output>\n" if(@ARGV!=2);

my $in=shift;
my $out=shift;

open IN,"$in" or die "$!";
open OUT,">$out" or die "$!";
$/=">";
<IN>;
while(<IN>){
	chomp;
	my @arr=split(/\n/,$_,2);
	$arr[1]=~ tr/atcg/ATCG/;
	print OUT ">$arr[0]\n$arr[1]\n";
}
close IN;
close OUT;


