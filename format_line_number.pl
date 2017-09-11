#!/usr/bin/perl -w
die "perl $0 <input.fa> <words of one line> <output>\n" if (@ARGV!=3);
my $in=shift;
my $limit=shift;
my $pre=shift;

open IN,"$in" or die "$!";
open OUT,">$pre" or die "$!";

$/=">";<IN>;
while(<IN>){
	chomp;
	my @arr=split(/\n/,$_,2);
	$arr[1]=~ s/\s+//g;
	$arr[1]=~ s/(.{$limit})/$1\n/g;
	print OUT ">$arr[0]\n$arr[1]\n";

}
close IN;
close OUT;
