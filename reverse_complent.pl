#!/usr/bin/perl -w
die "perl $0 <input.fast> <outfile>\n" unless(@ARGV==2);
my $in=shift;
my $out=shift;

open IN,"$in" or die "$!";
open OUT,">$out" or die "$!";
$/=">";
<IN>;
while(<IN>){
	chomp;
	my ($name,$seq)=split(/\n/,$_,2);
	$seq=~ s/\s+//g;
	$seq=reverse($seq);
	$seq=~ tr/ATCG/TAGC/;
	print OUT ">$name\n$seq\n";
}
close IN;
close OUT;
